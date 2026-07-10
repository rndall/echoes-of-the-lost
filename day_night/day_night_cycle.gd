extends CanvasModulate

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

@export var gradient: GradientTexture1D
@export var ingame_speed = 1.0
@export var initial_hour = 12:
	set(h):
		initial_hour = h
		time = INGAME_TO_REAL_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR

var time: float = 0.0
var past_minute: float = -1.0


func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR


func _process(delta: float) -> void:
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * ingame_speed
	var value = (sin(time - PI / 2) + 1.0) / 2.0
	color = gradient.gradient.sample(value)
	
	_recalculate_time()


func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(float(total_minutes) / MINUTES_PER_DAY)
	
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	
	var hour = int(float(current_day_minutes) / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_minute = minute
		GameManager.day = day + 1
		Events.time_tick.emit(day, hour, minute)
		_update_game_phase(hour)


func _update_game_phase(hour: int) -> void:
	# Define day from 6:00 AM (6) to 6:00 PM (18)
	var current_phase: GameManager.PHASE
	if hour >= 6 and hour < 18:
		current_phase = GameManager.PHASE.DAY
	else:
		current_phase = GameManager.PHASE.NIGHT
	
	if GameManager.phase != current_phase:
		GameManager.phase = current_phase
		print("Phase changed to: ", "DAY" if current_phase == GameManager.PHASE.DAY else "NIGHT")


func reset() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR
	past_minute = -1.0

	var value = (sin(time - PI / 2) + 1.0) / 2.0
	color = gradient.gradient.sample(value)

	_recalculate_time()


# ---------------------------------------------------------------------------
# Save / Load
# ---------------------------------------------------------------------------

## `time` alone fully determines day/hour/minute/phase/color (they're all
## derived from it in _process()/_recalculate_time()), so it's the only
## value SaveManager needs to persist for the clock to resume correctly.
func get_save_data() -> Dictionary:
	return {"time": time}


## Restores the saved clock and immediately re-derives color/phase/day from
## it, rather than waiting for the next _process() frame — otherwise the
## loaded scene would flash the default initial_hour lighting for a frame,
## and GameManager.phase/day could briefly disagree with the restored time.
func load_save_data(data: Dictionary) -> void:
	time = data.get("time", time)

	# Force _recalculate_time() to treat this as a fresh minute so it
	# re-emits Events.time_tick and re-syncs GameManager.day/phase instead
	# of silently no-opping because past_minute already equals the new
	# minute by coincidence.
	past_minute = -1.0

	var value = (sin(time - PI / 2) + 1.0) / 2.0
	color = gradient.gradient.sample(value)

	_recalculate_time()
