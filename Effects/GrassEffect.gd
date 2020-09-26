extends Node2D

onready var anim_sprite = $AnimatedSprite

func _ready():
	anim_sprite.play("destroy")


func _on_AnimatedSprite_animation_finished():
	queue_free()
