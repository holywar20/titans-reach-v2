extends Area2D

class_name Anomoly

var showText = "This is an anomoly"
var hoverText = null
var eventBus = null

func _ready():
	hoverText = "Anomoly Detected!"
	# set_texture( load("res://icon.png") )

func setEvents( eBus : EventBus ):
	eventBus = eBus

func initAnomoly( location : Vector2 , visible : bool ):
	pass

func _onAreaClicked():
	if( eventBus ):
		eventBus.emit( "AnomolyClicked" , [ self ])

func _startAnomoly():
	pass

func _startBattle():
	pass

func _modifyItems():
	pass

func _modifyTime():
	pass

func _effectCrew():
	pass