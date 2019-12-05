extends Sprite

var eventBus = null
var payloadObject = null

func setScene( eventBus : EventBus , payloadObject ):
	self.payloadObject = payloadObject
	self.eventBus = eventBus

	self.set_texture( load( payloadObject.smallTexturePath ) )
	# TODO add a switch for pulling in various textures based on type
	# TODO add a default texture for when dragging an item icon doesn't make sense.

func _ready():
	self.hide()

	self.eventBus.emit("DraggableClicked" , [ self.payloadObject ] )

func _input( ev : InputEvent ):
	self.set_global_position( ev.get_global_position() )

	self.show()

	if( ev.is_action_released( "GUI_SELECT" ) ):
		self.eventBus.emit( "DraggableReleased" , [ self.payloadObject , ev.position ] )
		self.queue_free()

