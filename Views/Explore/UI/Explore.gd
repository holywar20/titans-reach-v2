extends VBoxContainer

onready var tabBase		= get_node("Dynamic/Tab-Bind")

# Passed in by the parent
var eventBus = null
var playerCrew = []
var playerShip = []

var playerGear = {}

# Utilized by elements that list all crew sequentially
var currentCrewmanIdx = null

var subUIOpen = "None"

const MENU = { 
	'ASSIGNMENTS'	: "res://Views/Explore/UI/SubUI/Assignments.tscn",
	'CREW' 			: "res://Views/Explore/UI/SubUI/Crew.tscn",
	'EQUIPMENT'		: "res://Views/Explore/UI/SubUI/Equipment.tscn",
	'SHIP'			: "res://Views/Explore/UI/SubUI/Ship.tscn",
	'CARGO'			: "res://Views/Explore/UI/SubUI/Cargo.tscn",
	'STARMAP'		: "res://Views/Explore/UI/SubUI/Starmap.tscn",
}

const EXPLORE_EVENTS = [
	# Fired when a planet or star has been clicked
	"StarClickedStart" 			,"StarClickedEnd",
	"PlanetClickedStart"			,"PlanetClickedEnd",
	"AnomolyClicked",

	# Called on the _ready function of the Explore Page
	"CelestialsLoadingOnMap" 	, "CelestialsLoadedOnMap",

	# Draggable events, fired by a draggable object or Draglock
	"DraggableCreated", "DraggableReleased", "DraggableMatched",
	
	# Events fired by UI elements that indicate succesful data changes, that other UI elements might care about.
	"CrewmanAssigned",

	# Interactable Collision Events , emitted by the players ship
	"AnomolyEntered"		, "AnomolyExited",
	"PlanetEntered" 		, "PlanetExited" ,
	"ConnectionEntered"	, "ConnectionExited",
	"StarEntered"			, "StarExited",

	# Events fired by Card Nodes
	"CrewmanSelected", "ItemSelected",

	# Issued by player ship whenever it notices a change in the Areas it's interacting with.
	"PlayerContactingAreasUpdated",

	"SubUIAnyOpenBegin"	, "SubUIAnyOpenEnd",
	"SubUIAnyCloseBegin"	, "SubUIAnyCloseEnd",

	# Cancel current action that is only partially complete, or exit a context menu
	"GeneralCancel"
]

onready var nodes = {
	"NearObjectModal"		: get_node("Footer/Near"),
	"NearObjectButton"	: get_node("Footer/Near/Button"),
	"Context"				: get_node("Dynamic/Right/Context"),
	"Minimap"				: get_node("Dynamic/Right/Minimap")
}

func setupScene( eBus : EventBus, pShip : Starship , pCrew , pGear ):
	eventBus = eBus
	eventBus.addEvents( EXPLORE_EVENTS )

	eventBus.register( "PlayerContactingAreasUpdated" , self , "_onPlayerContactingAreasUpdated" )

	playerShip = pShip
	playerCrew = pCrew
	playerGear = pGear

	currentCrewmanIdx = 0

func _ready():
	# Nodes need to exist before we can set the eventBus on them.
	nodes.Context.setEvents( eventBus )
	nodes.Minimap.setEvents( eventBus )

func _setupSubUI( menuTarget : String , subUI ):
	match menuTarget:
		"ASSIGNMENTS":
			subUI.setupScene( eventBus , playerCrew , playerShip )
		"CREW":
			subUI.setupScene( eventBus , self )
		"EQUIPMENT":
			subUI.setupScene( eventBus , self )
		"SHIP":
			subUI.setupScene( eventBus )
		"CARGO":
			subUI.setupScene( eventBus )
		"STARMAP":
			subUI.setupScene( eventBus )

func getEquipableGear():
	return playerGear

func getCurrentCrewman():
	return playerCrew[currentCrewmanIdx]

func getNextCrewman():
	currentCrewmanIdx = currentCrewmanIdx + 1
	if( currentCrewmanIdx >= playerCrew.size() - 1 ):
		currentCrewmanIdx = 0

	return playerCrew[currentCrewmanIdx]

func getPrevCrewman():
	currentCrewmanIdx = currentCrewmanIdx - 1
	if( currentCrewmanIdx < 0 ):
		currentCrewmanIdx = playerCrew.size() - 1
	
	return playerCrew[currentCrewmanIdx]

func _onPlayerContactingAreasUpdated( bodies ):
	if( bodies.size() == 0 ):
		nodes.NearObjectModal.hide()
	elif( bodies.size() == 1 ):
		nodes.NearObjectModal.show()
		nodes.NearObjectButton.set_text( bodies[0].showText )
	elif( bodies.size() >= 2):
		nodes.NearObjectModal.show()
		nodes.NearObjectButton.set_text( "Investigate Anomoly" )

# TODO - Add an underscore here.
func menuButtonPressed( menuTarget : String ):
	for tab in tabBase.get_children():
		tab.queue_free()

	if( subUIOpen == menuTarget ):
		subUIOpen = "None"
	else:
		subUIOpen = menuTarget
		var subUIScene = load( MENU[menuTarget] )
		var subUI = subUIScene.instance()

		_setupSubUI( menuTarget , subUI )

		tabBase.add_child( subUI )