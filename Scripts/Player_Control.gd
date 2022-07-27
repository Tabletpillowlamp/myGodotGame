extends KinematicBody2D

var speed : int = 170
var air_speed : int = 120
var jump_speed : int = 400
var gravity : int = 950
var velocity = Vector2()
var direction = 1 # 1 = right, -1 = left
var landing = false
var bigFall = false
var ducking = false
var ducked = false
var duckingReleased = false
var jumpHold = 0
var attacking = false
var doubleJumped = false


var wallJumped = false
var wallJumpFrames = 0

onready var ani = $AnimationPlayer
onready var aniSpear = $AnimationSpear

func get_input(delta):
	velocity.x = 0

	if Input.is_action_pressed("move_left") and !wallJumped:
		if !attacking: direction = -1
		if Global.canMoveLeftRight:
			moveGrounded()

	if Input.is_action_pressed("move_right") and !wallJumped:
		if !attacking: direction = 1
		if Global.canMoveLeftRight:
			moveGrounded()

	if Input.is_action_just_pressed("jump"):
		if (is_on_floor()):
			velocity.y -= jump_speed
		elif Global.canWallJump and (is_on_wall()):
			direction *= -1
			wallJumped = true
			velocity.y = -jump_speed
		elif Global.canDoubleJump and !doubleJumped:
			wallJumped = false
			velocity.y = -jump_speed
			doubleJumped = true
		if ducked:
			relaseDuckingPosition()

	if wallJumped:
		velocity.x += direction * (speed)

	if Input.is_action_just_released("jump"):
		if velocity.y < -200:
			velocity.y += jump_speed * 0.25

	if Input.is_action_pressed("duck"):
		if (is_on_floor()):
			if !ducked:
				ducking = true
	elif ducked:
		duckingReleased = true
	if Input.is_action_just_released("duck"):
		duckingReleased = true
	if Input.is_action_just_pressed("attack"):
		attacking = true

	#gravity
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	if velocity.y > 0 and !(is_on_floor()):
		landing = true
		if velocity.y > 500: bigFall = true

func animate_player():
	if (is_on_floor()):

		doubleJumped = false
		wallJumped = false

		if attacking:
			if !ducked: #Grounded Attack
				aniSpear.play("Swing_Normal_Right") if direction == 1 else aniSpear.play("Swing_Normal_Left")
				ani.play("Spear_Right") if direction == 1 else ani.play("Spear_Left")
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
			else:		#Ducked Attack
				ani.play("Spear_Duck_Right") if direction == 1 else ani.play("Spear_Duck_Left")
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
			attacking = false
			bigFall = false

		if landing:
			#attacking = false
			if bigFall:
				ani.play("Landing_Right") if direction == 1 else ani.play("Landing_Left")
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
				bigFall = false
				landing = false
				relaseDuckingPosition()

		if !ducking and !ducked:
			if velocity.x == 0 or (is_on_wall()):
				ani.play("Idle_Right") if direction == 1 else ani.play("Idle_Left")
			else:
				ani.play("Walk_Right") if velocity.x > 1 else ani.play("Walk_Left")
		else:
			if duckingReleased:
				if ducked:
					ani.play("GettingUp_Right") if direction == 1 else ani.play("GettingUp_Left")
					Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
				relaseDuckingPosition()
			elif ducking:
				ani.play("Ducking_Right") if direction == 1 else ani.play("Ducking_Left")
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
				Global.canMoveLeftRight = false
				ducked = true
			if ducked:
				ani.play("Duck_Right") if direction == 1 else ani.play("Duck_Left")
				Global.canMoveLeftRight = false
			ducking = false

	else:
		if attacking: #Air Attack
			aniSpear.play("Swing_Normal_Right") if direction == 1 else aniSpear.play("Swing_Normal_Left")
			ani.play("Spear_Jump_Right") if direction == 1 else ani.play("Spear_Jump_Left")
			yield(ani, "animation_finished")
			attacking = false
		if (is_on_wall()) and Global.canWallJump:
			ani.play("Clinging_Right") if direction == 1 else ani.play("Clinging_Left")
		elif velocity.y <= 0:
			ani.play("Jumping_Right") if direction == 1 else ani.play("Jumping_Left")
		else:
			ani.play("Falling_Right") if direction == 1 else ani.play("Falling_Left")

func moveGrounded():
	if (is_on_floor()):
		velocity.x += direction * speed
	else:
		velocity.x += direction * air_speed

func relaseDuckingPosition():
	ducking = false
	ducked = false
	duckingReleased = false
	Global.canMoveLeftRight = true

func _physics_process(delta):
	if Global.canInput: get_input(delta)
	animate_player()
