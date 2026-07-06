extends Node

@warning_ignore_start("unused_signal")

signal scene_progress_changed(progress)
signal scene_load_finished

signal map_changed(map: Map)

signal time_tick(day: int, hour: int, minute: int)

signal player_health_changed(current_health: float)
signal player_weapon_equipped(item: WeaponItem)
#signal player_state_changed(state: PlayerState)

enum Map {HOUSE, OUTSIDE}
