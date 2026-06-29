extends Control

class_name TaskListUI

@onready var grid_container = $NinePatchRect/GridContainer
@onready var label = $NinePatchRect/Label
@onready var refresh_timer_label = $NinePatchRect/refresh_timer

var task_ui_prefab: PackedScene = preload("res://tasks/scenes/task_ui.tscn")
var task_ui_instances: Array[TaskUI] = []

# Timer tracking
var current_day: int = 0
var current_hour: int = 0
var current_minute: int = 0

func _ready() -> void:
	# Initialize the task manager
	if not DailyTaskManager.daily_tasks_initialized:
		DailyTaskManager.initialize_tasks()
	
	# Connect to task manager signals
	DailyTaskManager.task_updated.connect(_on_task_updated)
	DailyTaskManager.task_completed.connect(_on_task_completed)
	DailyTaskManager.tasks_reset.connect(_on_tasks_reset)
	
	# Connect to time tick for countdown updates
	Events.time_tick.connect(_on_time_tick)
	
	# Populate UI with tasks
	_setup_task_uis()

func _setup_task_uis() -> void:
	var all_tasks = DailyTaskManager.get_all_tasks()
	
	for i in range(grid_container.get_child_count()):
		var task_ui = grid_container.get_child(i) as TaskUI
		if task_ui and i < all_tasks.size():
			task_ui.set_task(all_tasks[i])
			task_ui_instances.append(task_ui)
		elif task_ui:
			task_ui.queue_free()

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	current_day = day
	current_hour = hour
	current_minute = minute
	_update_countdown_timer()

func _on_task_updated(task: Task) -> void:
	for task_ui in task_ui_instances:
		if task_ui.task == task:
			task_ui.update_display()
			break

func _on_task_completed(task: Task) -> void:
	for task_ui in task_ui_instances:
		if task_ui.task == task:
			task_ui.on_task_completed()
			break
	print("[TaskListUI] Task completed: %s" % task.task_name)

func _on_tasks_reset() -> void:
	_setup_task_uis()

func _update_countdown_timer() -> void:
	# Calculate time remaining until next day (midnight / 00:00)
	var hours_until_reset = 24 - current_hour - 1
	var minutes_until_reset = 60 - current_minute
	
	# Handle the edge case where we're at minute 59
	if minutes_until_reset == 60:
		minutes_until_reset = 0
		hours_until_reset += 1
	
	# Format as HH:MM
	var timer_text = "Refresh in: %02d:%02d" % [hours_until_reset, minutes_until_reset]
	refresh_timer_label.text = timer_text
