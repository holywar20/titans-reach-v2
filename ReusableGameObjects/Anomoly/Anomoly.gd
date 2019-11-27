extends Area2D

class_name Anomoly

var showText = "This is an anomoly"
var hoverText = null
var eventBus = null

func _ready():
	self.hoverText = "Anomoly Detected!"
	# self.set_texture( load("res://icon.png") )

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func initAnomoly( location : Vector2 , visible : bool ):
	pass

func _onAreaClicked():
	if( self.eventBus ):
		self.eventBus.emit( "AnomolyClicked" , [ self ])

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