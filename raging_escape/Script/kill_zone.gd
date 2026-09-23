extends Area2D

var killzone_damage := -1000

@export var player: CharacterBody2D

# Deal damage to the player when they fall off the map
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player.update_health(killzone_damage)
