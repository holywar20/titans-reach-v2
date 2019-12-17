extends Sprite

var eventBus = null
var payloadObject = null
var sourceLock = null

var defaultTexture = "res://icon.png"

func setScene( eventBus : EventBus , payloadObject , sourceLock = null ):
	self.payloadObject = payloadObject
	self.eventBus = eventBus
	self.sourceLock = sourceLock

	var objClass = payloadObject.get_class()
	if( objClass == "Crew" ):
		self.set_texture( load( payloadObject.smallTexturePath ) )

	if( objClass == "Weapon" || objClass == "Frame" || objClass == "Equipment" ):
		self.set_texture( load( payloadObject.itemTexturePath ) )

func _ready():
	self.hide() # To prevent the draggable from being seen until some event with mouse position is fired.

func _input( ev : InputEvent ):
	self.set_global_position( ev.get_global_position() )
	self.show()

	if( ev.is_action_released( "GUI_SELECT" ) ):
		self.eventBus.emit( "DraggableReleased" , [ self.payloadObject , self.sourceLock, ev.position ] )
		self.queue_free()

