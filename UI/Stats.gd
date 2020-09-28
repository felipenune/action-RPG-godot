extends Node

export var max_health = 1 setget set_max_health
var health = max_health setget set_health

signal no_health
signal healt_change(value)
signal max_health_change(value)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_change", max_health)

func set_health(value):
	health = value
	emit_signal("healt_change", health)
	if health <= 0:
		emit_signal("no_health")
		
func _ready():
	self.health = max_health
