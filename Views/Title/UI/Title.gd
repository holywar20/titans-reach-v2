extends Control

var globalBus = EventBusStore.getGlobalEventBus()

func _ready():
	pass

func newGameButtonClick():
	globalBus.emit( "NewGame_Start_Begin" , [] )

func exit_tree():
	pass