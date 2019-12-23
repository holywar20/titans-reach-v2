extends PanelContainer

var eventBus = null
var playerCrew = null 
var playerShip : Starship = null

var crewCardScene = load("res://ReusableUI/CrewCard/CrewCard.tscn")
var crewCardNodeGroup = "CrewCard"

var consoleCardScene = load("res://Views/Explore/UI/SubUI/AssignmentsSubUI/ConsoleCard.tscn")
var consoleCardNodeGroup = "ConsoleCard"

var CONSOLE_DRAG_LOCKS = "ConsoleDragLock"

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

func setupScene( eBus : EventBus , pCrew , pShip : Starship ):
	eventBus = eBus
	playerShip = pShip
	playerCrew = pCrew

func _ready():
	eventBus.emit("SubUIAnyOpenBegin")
	
	_resetConsoles()

	_layoutConsoles()
	_layoutCrew()

	nodes.CrewDetailNode.setupScene( eventBus )

	eventBus.register( "DraggableReleased" , self, "_onDraggableReleased")
	eventBus.register( "CrewmanAssigned", self, "_onConsoleChange" )
	eventBus.emit("SubUIAnyOpenEnd")

func _exit_tree():
	eventBus.emit( "SubUIAnyCloseBegin" )
	eventBus.emit( "SubUIAnyCloseEnd" )

func _onConsoleChange( crewObject ):
	_layoutCrew()

# Creates the consoles and assigns them to console.xxxx, so that consoles match the category and can be found easily.
func _resetConsoles():
	for key in Console.CATEGORY:
		var group = Console.CATEGORY[key]
		consoles[group] = consoleCardScene.instance()
		consoles[group].setupScene( eventBus , group )

		bases.ConsoleGroups.add_child( consoles[group] )

func _layoutCrew():
	var children = bases.Unassigned.get_children()
	for child in children:
		child.queue_free()

	for crew in playerCrew:
		if( crew.isAssigned() ): # Crewman already has a job, don't display them in list.
			continue

		var crewCardInstance = crewCardScene.instance()
		crewCardInstance.setupScene( eventBus, crew )
		bases.Unassigned.add_child( crewCardInstance )
		crewCardInstance.loadData()
	
func _layoutConsoles():
	var consoleObjects = playerShip.getConsoles()

	for console in consoleObjects:
		var card = consoles[console.consoleCategory]
		card.addConsole( console )

func _onDraggableReleased( crewman  , sourceLock, droppedLoc : Vector2 ):

	var targetLock = null
	for lock in get_tree().get_nodes_in_group( CONSOLE_DRAG_LOCKS ):
		if( lock.isInArea( droppedLoc ) ):
			targetLock = lock
			break

	var success = false
	if( targetLock && sourceLock ):
		var oldCrewman = targetLock.lockHolds
		success = targetLock.lockIs.crewTransaction( crewman , sourceLock.lockIs )
		if( success ):
			targetLock.updateLock( crewman )
			sourceLock.updateLock( oldCrewman )

	elif( targetLock ):
		success = targetLock.lockIs.crewTransaction( crewman , null )
		if( success ):
			targetLock.updateLock( crewman )
			
	elif( sourceLock ):
		success = sourceLock.lockIs.crewTransaction( null , null )
		if( success ):
			sourceLock.updateLock()
	
	_layoutCrew()