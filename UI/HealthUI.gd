extends Control

onready var heart_full = $HeartUIFull
onready var heart_empty = $HeartUIEmpty

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heart_full != null:
		heart_full.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min (hearts, max_hearts)
	if heart_empty != null:
		heart_empty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("healt_change", self, "set_hearts")
	PlayerStats.connect("max_health_change", self, "set_max_hearts")
