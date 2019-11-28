extends PanelContainer

var eventBus = null
var playerCrew = null 

var crewCardScene = load("res://ReusableUI/CrewCard/CrewCard.tscn")
var crewCardNodeGroup = "CrewCard"

var consoleCardScene = load("res://Views/Explore/UI/SubUI/AssignmentsSubUI/Command.tscn")
var consoleCardNodeGroup = "ConsoleCard"

onready var bases = {
	"Unassigned" : get_node("Main/Left/Unassigned")
}

func setupScene( eventBus : EventBus , playerCrew ):
	self.eventBus = eventBus
	self.playerCrew = playerCrew

func _ready():
	self.eventBus.emit("SubUIAnyOpenBegin")

	self._layoutConsoles()
	self._layoutCrew()

	self.eventBus.emit("SubUIAnyOpenEnd")

func _exit_tree():
	self.eventBus.emit("SubUIAnyCloseBegin")
	self.eventBus.emit("SubUIAnyCloseEnd")

func _layoutCrew():

	for crew in playerCrew:
		# TODO figure out where crewman 'is'
		var crewCardInstance = self.crewCardScene.instance()
		crewCardInstance.setupScene( self.eventBus, crew )
		self.bases.Unassigned.add_child( crewCardInstance )

func _layoutConsoles():
	pass
