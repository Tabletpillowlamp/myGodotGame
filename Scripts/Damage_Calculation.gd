extends Node

var pStat =  load("res://Scripts/Player_Stats.gd").new()
var damage = 0

#Weapon Stats
var spearAtk			= 5
var swordAtk			= 4

func damagePlayer(targetAtk):
	damage = (targetAtk * 4) - pStat.defense * 2
	return damage

func dSpear(targetDef,tipper=false):
	damage = (pStat.attack + spearAtk * 4) - targetDef * 2
	if tipper:
		damage *= 1.5
		damage = round(damage)
	return damage

func dSword(targetDef):
	damage = (pStat.attack + swordAtk * 4) - targetDef * 2
	return damage
