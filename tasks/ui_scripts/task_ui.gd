extends Panel

class_name TaskUI

@onready var checkbox = $NinePatchRect/Panel/AnimatedSprite2D
@onready var label = $NinePatchRect/Label
@onready var progress_bar = $NinePatchRect/ProgressBar if has_node("NinePatchRect/ProgressBar") else null

var task: Task = null

func _ready() -> void:
	if task:
		update_display()

func set_task(new_task: Task) -> void:
	task = new_task
	if is_node_ready():
		update_display()

func update_display() -> void:
	if not task:
		return
	
	# Update label with task name and progress
	var progress_text = "%s (%d/%d)" % [task.task_name, task.current_progress, task.target_amount]
	label.text = progress_text
	
	# Update checkbox animation state
	if task.is_completed:
		checkbox.play("done")
		label.add_theme_color_override("font_color", Color.GREEN)
	else:
		checkbox.play("default")
	
	# Update progress bar if it exists
	if progress_bar:
		progress_bar.value = task.get_progress_percent() * 100.0

func on_task_completed() -> void:
	if task:
		update_display()
		# Optional: Play a completion animation or sound
		print("[TaskUI] %s completed!" % task.task_name)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if task and task.is_completed and not task.reward_claimed:
			DailyTaskManager.claim_reward(task.task_id)
			update_display()
