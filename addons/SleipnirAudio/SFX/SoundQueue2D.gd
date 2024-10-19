@tool
class_name SoundQueue2D
extends Node2D
## Workaround para lidar com polyfonia no godot (só que em 2D)
##
## Cria AudioStreamPlayer para ser usado como polifonia


@export var Count : int = 1: ## Quantos AudioStreamPlayer vai ter
	get:
		return Count
	set(value):
		update_configuration_warnings() #NOTE eu devia mesmo chamar isso aqui, aqui?
		Count = clamp(value,0,16) # Limite passivo de 16

var _next : int = 0 ## Variável que vai ser usada para navegar na lista de AudioStreamPlayers
var _audioStreamPlayers : Array[AudioStreamPlayer2D] ## Faz uma lista que só aceita AudioStreamPlayers

func _ready() -> void:                      # Logo quando entra
	if get_child_count() == 0:              # Se o Node n tiver nenhuma child
		return                              # Manda pro Log que não tem, e retorna cedo
	#                                       # TODO Colocar um logger aqui
	var child = get_child(0)                # Pega a primeira child
	if child is AudioStreamPlayer2D:        # Se ela for AudioStreamPlayer
		_audioStreamPlayers.append(child)   # Bota na Lista
		for i in range(0,Count-1):          # Duplica o AudioStreamPlayer de acordo com o Count
			var child_duplicate = child.duplicate() as AudioStreamPlayer2D
			add_child(child_duplicate)
			_audioStreamPlayers.append(child_duplicate)

## método para pegar polifonia maxima da soundqueue
func get_polyphony() -> int: return Count

func _get_configuration_warnings() -> PackedStringArray: # Manda Notificação Direto no Node:
	if get_child_count() == 0:                           # Se n tem nenhuma Child
		return ["No children found. Expected AudioStreamPlayer2D child."]
	if not(get_child(0) is AudioStreamPlayer2D):           # Se a primeira Child não é AudioStreamPlayer
		return ["Expected first child to be an AudioStreamPlayer2D."]
	return []


func play_sound() -> void:   ## Toca a SoundQueue    
	if !_audioStreamPlayers[_next].playing: # Se o som da child _next não estiver tocando:
		AudioManager.currently_playing_audiostreams.append(_audioStreamPlayers[_next])
		_audioStreamPlayers[_next].play() # Ele vai tocar nela
		
		# cria uma variavels
		var audio_playing := get_node(get_path_to(_audioStreamPlayers[_next])) 
		audio_playing.connect("finished",func(): _on_audio_finished(audio_playing)) 
		# conecta um sinal a ela pra saber quando acaba
		_next = _next + 1                    # E passa pro proximo AudioStreamPlayer na lista	
	if _next == _audioStreamPlayers.size(): _next = 0  # Quando Chega no Final Reseta pra 0, criando um ciclo

func stop_sound() -> void:
	for audio_index in Count:
		if _audioStreamPlayers[audio_index].playing:
			_audioStreamPlayers[audio_index].stop()

func _on_audio_finished(audio_playing) -> void: 
	AudioManager.currently_playing_audiostreams.erase(audio_playing)