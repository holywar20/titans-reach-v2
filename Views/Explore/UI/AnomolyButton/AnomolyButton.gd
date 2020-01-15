extends Button

var parentAnom = null
var eventBus = null

func setupScene( anom , eBus ):
	parentAnom = anom
	eventBus = eBus

func _ready():
	pass # Replace with function body.

func _onButtonPressed():
	eventBus.emit( "AnomButtonPressed" , [ parentAnom ] )

