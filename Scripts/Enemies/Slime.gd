extends KinematicBody2D

const FLOOR_NORMAL = Vector2.UP
var velocity = Vector2()
var gravity : int = 950
var rng = RandomNumberGenerator.new()
var direction = 1
var time = 0
var paused = false

var damage = 0
var tDamage = 0

var maxHP : int = 32
var defense : int = 5
var attack : int = 5
var speed : int = 30

const slimeEffect = preload("res://Scenes/Effects/Slime_Particle.tscn")
const damageNum = preload("res://Scenes/Effects/Damage_Number.tscn")
var cDamage =  load("res://Scripts/Damage_Calculation.gd").new()

onready var ani = $Slime_Ani
onready var slimeSprite = $Slime_Normal
onready var walkPause = get_node("Walk_Pause_Time")

func slimeMoveNormal(delta):
	if !paused:
		velocity.x = speed * direction
	else:
		velocity.x = 0
	velocity.y += gravity * delta
	velocity.y = move_and_slide(velocity,FLOOR_NORMAL).y

func directionChange():
	if tDamage < maxHP:
		if direction == 1:
			slimeSprite.flip_h = true
		else:
			slimeSprite.flip_h = false
	
func slimeAni():
	ani.play("Idle")
	
func _on_Walk_Pause_Time_timeout():
	if !paused:
		paused = true
		setRandomTimer(2,4)
	else:
		paused = false
		direction *= -1
		directionChange()
		setRandomTimer(1,3)

func setRandomTimer(start,end):
	rng.randomize()
	time = rng.randi_range(start,end)
	walkPause.set_wait_time(time)
	walkPause.start()

func _ready():
	rng.randomize()
	direction = rng.randi_range(1,2)
	if direction == 2: direction = -1
	setRandomTimer(1,3)
	directionChange()

func _physics_process(delta):
	if tDamage < maxHP:
		slimeMoveNormal(delta)
		slimeAni()
	else:	#enemy dies
		ani.play("Death")
		
var spearLag = false

func _on_Slime_Area_area_entered(area):
	
	if area.is_in_group("Player"):
		Global.targetAtk = attack

	if !spearLag and area.is_in_group("Weapon"):

		if area.is_in_group("Spear"):
			damage = cDamage.dSpear(defense)
		if area.is_in_group("Tip"):
			damage = cDamage.dSpear(defense,true)
		if area.is_in_group("Sword"):
			damage = cDamage.dSword(defense)
			
		spearLag = true

		createSlimeDmg()

func createSlimeDmg():
	var effect = slimeEffect.instance()
	add_child(effect)
	effect.global_position.x = position.x
	effect.global_position.y = position.y + 10
	effect.start()

	var dNum = damageNum.instance()
	dNum.amount = damage
	add_child(dNum)
	dNum.dmgPopup()
	
	tDamage += damage 

func _on_Slime_Area_area_exited(_area):
	spearLag = false

func _on_Slime_Ani_animation_finished(_anim_name):
	self.queue_free()
