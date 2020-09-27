extends KinematicBody2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

var stats = PlayerStats

var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		animation_tree.set("parameters/attack/blend_position", input_vector)
		animation_tree.set("parameters/roll/blend_position", input_vector)
		animation_state.travel("run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("ui_roll"):
		state = ROLL

func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("attack")
	
func finished_attack():
	state = MOVE

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("roll")
	velocity = move_and_slide(velocity)
	
func finished_roll():
	velocity = Vector2.ZERO
	state = MOVE

func _on_Hurtbox_area_entered(_area):
	stats.health -= 1
