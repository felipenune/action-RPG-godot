extends KinematicBody2D

export var ACCELARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var animated_sprite = $AnimatedSprite
onready var detection_zone = $DetectionZone

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			var player = detection_zone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
				animated_sprite.flip_h = velocity.x < 0
			else:
				state = IDLE
				
	velocity = move_and_slide(velocity)

func seek_player():
	if detection_zone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120


func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()
