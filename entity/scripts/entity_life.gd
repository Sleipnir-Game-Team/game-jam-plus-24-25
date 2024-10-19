extends Node

@export var max_life := 3
var entity_life 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_life = max_life


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage():
	if entity_life > 0:
		entity_life -= 1
		
	if entity_life == 0:
		defeat()
	
func recover():
	if entity_life < max_life and entity_life > 0:
		entity_life += 1
	elif entity_life >= max_life:
		print("vida cheia")
	elif entity_life <= 0:
		print("Já perdeu")
	
func defeat():
	print("Derrotado")
