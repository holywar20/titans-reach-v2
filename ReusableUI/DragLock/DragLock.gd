extends Panel

onready var nodes = {
	"Name" 	: get_node("Name"),
	"Image"	: get_node("Image")
}

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"
const DEFAULT_TEXTURE = "res://icon.png"

# TODO - impliment some kind of map
const TYPES = {
	"CREWMAN_TO_CONSOLE" : "crewmanToConsole"
}

var eventBus : EventBus
var displayName : String = "set name in setupScene!"

var myDraggableBeingDragged = false


func setupScene( eventBus : EventBus , displayName : String , lockIs ):
	# Override this method for initially building your lock, before it's _ready() is called
	pass

func _onDraggableReleased( payload , draggableDroppedLocation : Vector2 ):
	# Impliment this method
	pass

func _gui_input ( guiEvent : InputEvent ):
	# if this Draglock needs to create it's own draggables, impliment a method here
	pass

func _ready():
	self.nodes.Name.set_text( self.displayName )

func _isInArea( pos: Vector2 ):
	var rect = self.get_global_rect()
	
	if rect.has_point(pos):
		return true
	
	return false

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( self.DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( self.eventBus , payloadObject )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )

	self.myDraggableBeingDragged = true
