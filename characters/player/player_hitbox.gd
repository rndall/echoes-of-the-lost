extends HitboxComponent


func _ready() -> void:
	Events.player_weapon_equipped.connect(_on_player_weapon_equipped)


func _on_player_weapon_equipped(item: WeaponItem) -> void:
	attack_damage = item.damage
