extends Control

onready var minimapBody = get_node("Body")
onready var minimapActual = get_node("Body/VBox/Map")

func _ready():
	pass

# Responses to events
func _toggleShowHideMinimap():
	if( self.minimapBody.is_visible() ):
		self.minimapBody.set_visible( false )
	else:
		self.minimapBody.set_visible( true )