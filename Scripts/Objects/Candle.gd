extends Area2D

var damage = 0
onready var ani = $Candle_Ani

func _physics_process(delta):
	ani.play("Idle")

func _on_Candle_area_entered(area):
	if !Global.spearLag and area.is_in_group("Weapon"):
		if area.is_in_group("Spear"):
			damage += 1
		if area.is_in_group("Tip"):
			damage += 2
			print("Tip")
		print(damage)
		Global.spearLag = true

func _on_Candle_area_exited(area):
	Global.spearLag = false
