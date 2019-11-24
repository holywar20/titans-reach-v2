extends Control

var globalBus = null # A refrence to the global event bus, declared in GameWorld

func _ready():
	self.globalBus = GameWorld.getGlobalBusRef()

func newGameButtonClick():
	self.globalBus.emit( "NewGame_Start_Begin" , [] )

