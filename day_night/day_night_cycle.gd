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
	Events.sleep_requested.connect(_on_sleep_requested)


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


func _on_sleep_requested(wake_hour: int) -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var current_hour = int(float(current_day_minutes) / MINUTES_PER_HOUR)

	var minutes_to_add = 0

	if current_hour < wake_hour:
		minutes_to_add = (wake_hour * MINUTES_PER_HOUR) - current_day_minutes
	else:
		var minutes_left_today = MINUTES_PER_DAY - current_day_minutes
		var minutes_tomorrow = wake_hour * MINUTES_PER_HOUR
		minutes_to_add = minutes_left_today + minutes_tomorrow
	
	time += minutes_to_add * INGAME_TO_REAL_MINUTE_DURATION

	_recalculate_time()

	var value = (sin(time - PI / 2) + 1.0) / 2.0
	color = gradient.gradient.sample(value)
