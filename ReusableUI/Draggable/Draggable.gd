extends TextureRect

var eventBus = null
var payloadObject = null

func setScene( eventBus : EventBus , payloadObject ):
	self.payloadObject = payloadObject
	self.eventBus = eventBus

func _ready():
	self.eventBus.emit("DraggableClicked" , [ self.payloadObject ] )

func _input( ev ):
	self.set_global_position( ev.get_global_position() )

	if( ev.is_action_released( "GUI_SELECT" ) ):
		self.eventBus.emit( "DraggableReleased" , [ payloadObject ])
		self.queue_free()

