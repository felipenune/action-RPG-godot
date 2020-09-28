extends KinematicBody2D

export var ACCELARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_RANGE_POSITION = 10

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var animated_sprite = $AnimatedSprite
onready var detection_zone = $DetectionZone
onready var soft_collider = $SoftCollider
onready var wander_controller = $WanderController

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wander_controller.time_left() == 0:
				update_state()

		WANDER:
			seek_player()
			
			if wander_controller.time_left() == 0:
				update_state()
			
			move_toward_point(wander_controller.target_position, delta)
			
			if global_position.distance_to(wander_controller.target_position) <= WANDER_RANGE_POSITION:
				update_state()

		CHASE:
			var player = detection_zone.player
			if player != null:
				move_toward_point(player.global_position, delta)
			else:
				state = IDLE
			
	if soft_collider.is_colliding():
		velocity += soft_collider.get_push_vector() * delta * 400
	
	velocity = move_and_slide(velocity)

func move_toward_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
	animated_sprite.flip_h = velocity.x < 0

func update_state():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(rand_range(1, 3))

func seek_player():
	if detection_zone.can_see_player():
		state = CHASE
		
func pick_random_state(states):
	states.shuffle()
	return states.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120


func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()
