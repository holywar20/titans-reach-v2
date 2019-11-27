extends Control

onready var minimapBody = get_node("Body")
onready var minimapActual = get_node("Body/VBox/Map")

var eventBus = null

func _ready():
	pass

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

	self.minimapActual.setEvents( eventBus )

# Responses to events
func _toggleShowHideMinimap():
	if( self.minimapBody.is_visible() ):
		self.minimapBody.set_visible( false )
	else:
		self.minimapBody.set_visible( true )