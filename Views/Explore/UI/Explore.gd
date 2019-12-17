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

func setupScene( eventBus: EventBus, playerShip : Starship , playerCrew , playerGear ):
	self.eventBus = eventBus
	self.eventBus.addEvents( self.EXPLORE_EVENTS )

	self.eventBus.register( "PlayerContactingAreasUpdated" , self , "_onPlayerContactingAreasUpdated" )

	self.playerShip = playerShip
	self.playerCrew = playerCrew
	self.playerGear = playerGear

	self.currentCrewmanIdx = 0

func _ready():
	# Nodes need to exist before we can set the eventBus on them.
	self.nodes.Context.setEvents( self.eventBus )
	self.nodes.Minimap.setEvents( self.eventBus )

func _setupSubUI( menuTarget : String , subUI ):
	match menuTarget:
		"ASSIGNMENTS":
			subUI.setupScene( self.eventBus , self.playerCrew , self.playerShip )
		"CREW":
			subUI.setupScene( self.eventBus , self )
		"EQUIPMENT":
			subUI.setupScene( self.eventBus , self )
		"SHIP":
			subUI.setupScene( self.eventBus )
		"CARGO":
			subUI.setupScene( self.eventBus )
		"STARMAP":
			subUI.setupScene( self.eventBus )

func getEquipableGear():
	return self.playerGear

func getCurrentCrewman():
	return self.playerCrew[self.currentCrewmanIdx]

func getNextCrewman():
	self.currentCrewmanIdx = self.currentCrewmanIdx + 1
	if( self.currentCrewmanIdx >= self.playerCrew.size() - 1 ):
		self.currentCrewmanIdx = 0

	return self.playerCrew[self.currentCrewmanIdx]

func getPrevCrewman():
	self.currentCrewmanIdx = self.currentCrewmanIdx - 1
	if( self.currentCrewmanIdx < 0 ):
		self.currentCrewmanIdx = playerCrew.size() - 1
	
	return self.playerCrew[self.currentCrewmanIdx]

func _onPlayerContactingAreasUpdated( bodies ):
	if( bodies.size() == 0 ):
		self.nodes.NearObjectModal.hide()
	elif( bodies.size() == 1 ):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( bodies[0].showText )
	elif( bodies.size() >= 2):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( "Investigate Anomoly" )

# TODO - Add an underscore here.
func menuButtonPressed( menuTarget : String ):
	for tab in self.tabBase.get_children():
		tab.queue_free()

	if( self.subUIOpen == menuTarget ):
		self.subUIOpen = "None"
	else:
		self.subUIOpen = menuTarget
		var subUIScene = load( self.MENU[menuTarget] )
		var subUI = subUIScene.instance()

		self._setupSubUI( menuTarget , subUI )

		self.tabBase.add_child( subUI )