extends Node3D

@export var Emotes : Dictionary

func DisplayEmote(key : String):
	if(Emotes.has(key)):
		$BG/emote.texture = Emotes[key]
	else:
		print("Bubble display couldn't find the emote ", key)
