extends Sprite

var eventBus = null
var payloadObject = null
var sourceLock = null

var defaultTexture = "res://icon.png"

func setScene( eBus : EventBus , pObject , sLock = null ):
	payloadObject = pObject
	eventBus = eBus
	sourceLock = sLock

	var objClass = payloadObject.get_class()
	if( objClass == "Crew" ):
		set_texture( load( payloadObject.smallTexturePath ) )

	if( objClass == "Weapon" || objClass == "Frame" || objClass == "Equipment" ):
		set_texture( load( payloadObject.itemTexturePath ) )

func _ready():
	hide() # To prevent the draggable from being seen until some event with mouse position is fired.

func _input( ev : InputEvent ):
	set_global_position( ev.get_global_position() )
	show()

	if( ev.is_action_released( "GUI_SELECT" ) ):
		eventBus.emit( "DraggableReleased" , [ payloadObject , sourceLock, ev.position ] )
		queue_free()

