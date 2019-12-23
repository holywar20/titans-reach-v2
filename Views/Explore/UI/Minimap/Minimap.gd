extends Control

onready var minimapBody = get_node("Body")
onready var minimapActual = get_node("Body/VBox/Map")

var eventBus = null

func _ready():
	pass

func setEvents( eBus : EventBus ):
	eventBus = eBus

	minimapActual.setEvents( eventBus )

# Responses to events
func _toggleShowHideMinimap():
	if( minimapBody.is_visible() ):
		minimapBody.set_visible( false )
	else:
		minimapBody.set_visible( true )