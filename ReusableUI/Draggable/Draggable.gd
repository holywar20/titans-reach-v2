extends Sprite

var eventBus = null
var payloadObject = null

func setScene( eventBus : EventBus , payloadObject ):
	self.payloadObject = payloadObject
	self.eventBus = eventBus

	var objClass = payloadObject.get_class()
	if( objClass == "Console" ):
		self.set_texture( load( payloadObject.smallTexturePath ) )

	if( objClass == "Weapon" || objClass == "Frame" || objClass == "Equipment" ):
		self.set_texture( load( payloadObject.itemTexturePath ) )

	# TODO add a default texture for when dragging an item icon doesn't make sense.

func _ready():
	self.hide()

	self.eventBus.emit("DraggableClicked" , [ self.payloadObject ] )

func _input( ev : InputEvent ):
	self.set_global_position( ev.get_global_position() )

	self.show()

	if( ev.is_action_released( "GUI_SELECT" ) ):
		print( self.payloadObject.get_class() )
		self.eventBus.emit( "DraggableReleased" , [ self.payloadObject , ev.position ] )
		self.queue_free()

