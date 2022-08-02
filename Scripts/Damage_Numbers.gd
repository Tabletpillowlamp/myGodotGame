extends Position2D


onready var ani = $dmgNum_Ani
onready var numAmount = get_node("num_Amount")
var amount = 0

func _ready():
	numAmount.set_text(str(amount))
	ani.play("Popup")

func _on_dmgNum_Ani_animation_finished(anim_name):
	self.queue_free()
