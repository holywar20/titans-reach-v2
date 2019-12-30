extends Panel

var eventBus

onready var statusLabel = get_node("Label")

func setupScene( eBus : EventBus ):
	eventBus = eBus

func _ready():
	pass # Replace with function body.

func setStatus( status = null ):
	if( status ):
		statusLabel.set_text( status )
		show()
	else:
		hide()
		statusLabel.set_text("")


