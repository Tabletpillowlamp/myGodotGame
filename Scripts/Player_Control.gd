extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32.0
const SLOPE_THRESHOLD = deg2rad(60)

var loop = 0
var speed : int = 170
var air_speed : int = 120
var jump_speed : int = 400
var gravity : int = 950

var velocity = Vector2()
var snapVector = SNAP_DIRECTION * SNAP_LENGTH

var direction = 1 # 1 = right, -1 = left
var landing = false
var bigFall = false
var ducking = false
var ducked = false
var duckingReleased = false
var jumpHold = 0
var attacking = false
var atkAir = false
var doubleJumped = false
var wallJumped = false

var timerTest = 0	#Debugging Purposes

onready var ani = $Aurelia_Ani
onready var aniSpear = $Spear_Ani
onready var aniSword = $Sword_Ani
onready var interface = get_node("Interface")

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
		snapVector = Vector2()
		if (is_on_floor()):
			velocity.y = -jump_speed
		elif Global.canWallJump and (is_on_wall()):
			velocity.y = -jump_speed
			direction *= -1
			wallJumped = true
		elif Global.canDoubleJump and !doubleJumped:
			velocity.y = -jump_speed
			wallJumped = false
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
		if !(is_on_floor()):
			#Animation must be here to prevent falling animation to be played while
			#atkAir is on creating a yield loop.
			atkAir = true
			readyWeapon(1)

	if Input.is_action_just_pressed("scroll_left"):
		if !attacking: interface.weaponSwitch(false)

	if Input.is_action_just_pressed("scroll_right"):
		if !attacking: interface.weaponSwitch()

	#gravity
	velocity.y += gravity * delta
	if snapVector != Vector2():
		velocity.y = move_and_slide_with_snap(velocity,snapVector,FLOOR_NORMAL
			,true,4,SLOPE_THRESHOLD).y 
	else:
		velocity.y = move_and_slide(velocity,FLOOR_NORMAL).y
	if (is_on_floor()) and snapVector == Vector2():
		reset_snap()

	if velocity.y > 0 and !(is_on_floor()) and !landing: landing = true
	if velocity.y > 500 and !(is_on_floor()) and !bigFall: bigFall = true

func animate_player():
	if (is_on_floor()):	#On the Ground

		doubleJumped = false
		wallJumped = false

		if attacking:
			if !ducked: #Grounded Attack
				if !atkAir:
					readyWeapon(0)
					useWeapon()
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
			else:		#Ducked Attack
				readyWeapon(2)
				useWeapon(true)
				Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
			atkAir = false
			bigFall = false
			attacking = false

		if landing:
			landing = false
		if bigFall:
			ani.play("Landing_Right") if direction == 1 else ani.play("Landing_Left")
			Global.canInput = false; yield(ani, "animation_finished"); Global.canInput = true
			bigFall = false
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

	else:	#On the Air

		if atkAir: #Air Attack
			useWeapon()
			yield(ani, "animation_finished")
			atkAir = false
			attacking = false
		if (is_on_wall()) and Global.canWallJump:
			ani.play("Clinging_Right") if direction == 1 else ani.play("Clinging_Left")
		elif velocity.y <= 0:
			ani.play("Jumping_Right") if direction == 1 else ani.play("Jumping_Left")
		else:
			ani.play("Falling_Right") if direction == 1 else ani.play("Falling_Left")

func readyWeapon(type):
	if Global.weaponType == 0:
		if type == 0:
			ani.play("Spear_Right") if direction == 1 else ani.play("Spear_Left")
		elif type == 1:
			ani.play("Spear_Jump_Right") if direction == 1 else ani.play("Spear_Jump_Left")
		else:
			ani.play("Spear_Duck_Right") if direction == 1 else ani.play("Spear_Duck_Left")
	if Global.weaponType == 1:
		if type == 0:
			ani.play("Sword_Right") if direction == 1 else ani.play("Sword_Left")
		elif type == 1:
			ani.play("Sword_Jump_Right") if direction == 1 else ani.play("Sword_Jump_Left")
		else:
			ani.play("Sword_Duck_Right") if direction == 1 else ani.play("Sword_Duck_Left")

func useWeapon(ducked=false):
	if Global.weaponType == 0:
		if !ducked:
			aniSpear.play("Swing_Normal_Right") if direction == 1 else aniSpear.play("Swing_Normal_Left")
		else:
			aniSpear.play("Duck_Normal_Right") if direction == 1 else aniSpear.play("Duck_Normal_Left")
	elif Global.weaponType == 1:
		if !ducked:
			aniSword.play("Slash_Normal_Right") if direction == 1 else aniSword.play("Slash_Normal_Left")
		else:
			aniSword.play("Duck_Normal_Right") if direction == 1 else aniSword.play("Duck_Normal_Left")

func reset_snap():
	snapVector = SNAP_DIRECTION * SNAP_LENGTH

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
