extends Node

@warning_ignore_start("unused_signal")

# --- Day / Night ---
signal day_started(day_number: int)
signal night_started()
signal time_of_day_changed(normalized: float) # 0.0 = midnight, 0.5 = noon

# --- Player ---
signal player_health_changed(current: int, maximum: int)
signal player_died()
signal player_location_changed(is_inside: bool)
signal player_light_status_changed(has_light: bool)

# --- World / Entities ---
signal enemy_spawned(enemy: Node2D)
signal interactable_used(type: String, position: Vector2)
signal relic_proximity_updated(normalized_distance: float) # 0.0=far, 1.0=on top

# --- Inventory ---
signal inventory_changed()
signal hotbar_slot_changed(slot_index: int)

# --- Game Flow ---
signal scene_transition_requested(map_name: String, entry_point: String)
signal game_win_requested()
signal game_lose_requested()
