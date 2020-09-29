extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

onready var timer = $Timer
onready var collision_shape = $CollisionShape2D

signal invincible_started
signal invincible_ended

func set_invincible(duration):
	emit_signal("invincible_started")
	timer.start(duration)

func _on_Hurtbox_area_entered(_area):
	set_invincible(0.5)
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func _on_Timer_timeout():
	emit_signal("invincible_ended")

func _on_Hurtbox_invincible_started():
	collision_shape.set_deferred("disabled", true)
	
func _on_Hurtbox_invincible_ended():
	collision_shape.disabled = false
