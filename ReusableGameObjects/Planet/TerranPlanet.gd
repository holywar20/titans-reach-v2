extends MeshInstance

onready var animationPlayer = get_node("AnimationPlayer");

func setupScene():
	# TODO Set rotation based on x.
	pass 

func _ready():
	animationPlayer.play("Rotation");
