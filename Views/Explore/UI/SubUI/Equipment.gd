extends PanelContainer

var eventBus = null 
var playerCrew = null

func setupScene( eventBus : EventBus , playerCrew ):
	self.eventBus = eventBus
	self.playerCrew = playerCrew

func _ready():
	pass