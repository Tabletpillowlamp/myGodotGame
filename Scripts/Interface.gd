extends CanvasLayer

onready var wIcon = $Weapon_Panel/Weapon_Icon
var icon = ""

func setWeaponIcon(type):
	if type == 0: icon = "res://Assets/Graphics/Interface/Weapon_Spear.png"
	if type == 1: icon = "res://Assets/Graphics/Interface/Weapon_Sword.png"
	wIcon.set_texture(load(icon))
	

func weaponSwitch(forward=true):
	if forward:
		if Global.weaponType == 0:
			Global.weaponType = 1
		elif Global.weaponType == 1:
			Global.weaponType = 0
	else:
		if Global.weaponType == 0:
			Global.weaponType = 1
		elif Global.weaponType == 1:
			Global.weaponType = 0
	setWeaponIcon(Global.weaponType)
	
func _ready():
	setWeaponIcon(Global.weaponType)
