extends PanelContainer

var eventBus : EventBus = null
var playerCrew = null 
var playerShip : Starship = null

var crewCardScene = load("res://ReusableUI/CrewCard/CrewCard.tscn")
var crewCardNodeGroup = "CrewCard"

var consoleCardScene = load("res://Views/Explore/UI/SubUI/AssignmentsSubUI/ConsoleCard.tscn")
var consoleCardNodeGroup = "ConsoleCard"

onready var bases = {
	"Unassigned" 		: get_node("Main/Left/Scroll/Unassigned"),
	"ConsoleGroups"	: get_node("Main/Right/ConsoleGroups")
}

onready var nodes = {
	"CrewDetailNode"	: get_node("Main/Left/CrewTraitDetail")
}

onready var consoles = {
	"Command" :  null ,
	"Security" : null ,
	"Engineering" : null,
	"Science" : null,
	"Medical" : null, 
	"Medbay"  : null
}

func setupScene( eventBus : EventBus , playerCrew , playerShip : Starship ):
	self.eventBus = eventBus
	self.playerShip = playerShip
	self.playerCrew = playerCrew

func _ready():
	self.eventBus.emit("SubUIAnyOpenBegin")
	
	self._resetConsoles()

	self._layoutConsoles()
	self._layoutCrew()

	self.nodes.CrewDetailNode.setupScene( self.eventBus )


	self.eventBus.register("CrewAssignmentChanged", self, "_onConsoleChange")
	self.eventBus.emit("SubUIAnyOpenEnd")

func _exit_tree():
	self.eventBus.emit("SubUIAnyCloseBegin")
	self.eventBus.emit("SubUIAnyCloseEnd")

func _onConsoleChange():
	self._layoutCrew()

# Creates the consoles and assigns them to console.xxxx, so that consoles match the category and can be found easily.
func _resetConsoles():
	for key in Console.CATEGORY:
		var group = Console.CATEGORY[key]
		self.consoles[group] = consoleCardScene.instance()
		self.consoles[group].setupScene( self.eventBus , group )

		self.bases.ConsoleGroups.add_child( self.consoles[group] )

func _layoutCrew():
	var children = self.bases.Unassigned.get_children()
	for child in children:
		child.queue_free()

	for crew in playerCrew:
		if( crew.isAssigned() ): # Crewman already has a job, don't display them in list.
			continue

		var crewCardInstance = self.crewCardScene.instance()
		crewCardInstance.setupScene( self.eventBus, crew )
		self.bases.Unassigned.add_child( crewCardInstance )
	
func _layoutConsoles():
	var consoles = self.playerShip.getConsoles()

	for console in consoles:
		var card = self.consoles[console.consoleCategory]
		card.addConsole( console )


