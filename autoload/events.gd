extends Node

@warning_ignore_start("unused_signal")

signal scene_progress_changed(progress)
signal scene_load_finished

signal map_changed(map: Map)

enum Map {HOUSE, OUTSIDE}
