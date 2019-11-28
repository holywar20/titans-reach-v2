extends VBoxContainer

onready var tabBase		= get_node("Dynamic/Tab-Bind")

var draggableScene = load("")

# Passed in by the parent
var eventBus = null
var playerCrew = []
var playerShip = []

var subUIOpen = "None"

const MENU = { 
	'ASSIGNMENTS'	: "res://Views/Explore/UI/SubUI/Assignments.tscn" , 
	'CREW' 			: "res://Views/Explore/UI/SubUI/Crew.tscn" , 
	'EQUIPMENT'		: "res://Views/Explore/UI/SubUI/Equipment.tscn" ,  
	'SHIP'			: "res://Views/Explore/UI/SubUI/Ship.tscn" , 
	'CARGO'			: "res://Views/Explore/UI/SubUI/Cargo.tscn" , 
	'STARMAP'		: "res://Views/Explore/UI/SubUI/Starmap.tscn" ,  
}

const EXPLORE_EVENTS = [
	# Fired when a planet or star has been clicked
	"StarClickedStart" 			,"StarClickedEnd",
	"PlanetClickedStart"			,"PlanetClickedEnd",
	"AnomolyClicked",

	# Called on the _ready function of the Explore Page
	"CelestialsLoadingOnMap" 	, "CelestialsLoadedOnMap",

	# Draggable events
	"DraggableClicked"			, "DraggableReleased",

	# Interactable Collision Events , emitted by the players ship
	"AnomolyEntered"				, "AnomolyExited",
	"PlanetEntered" 				, "PlanetExited" ,
	"ConnectionEntered"			, "ConnectionExited",
	"StarEntered"					, "StarExited",

	"SubUIOpenBegin"				, "SubUIOpenEnd",
	"SubUICloseBegin"				, "SubUIOCloseEnd",

	# Issued by player ship whenever it notices a change in the Areas it's interacting with.
	"PlayerContactingAreasUpdated",

	# Cancel current action that is only partially complete, or exit a context menu
	"GeneralCancel"
]

onready var nodes = {
	"NearObjectModal"		: get_node("Footer/Near"),
	"NearObjectButton"	: get_node("Footer/Near/Button"),
	"Context"				: get_node("Dynamic/Right/Context"),
	"Minimap"				: get_node("Dynamic/Right/Minimap")
}

func setupScene( eventBus: EventBus, playerShip : Starship , playerCrew ):
	self.eventBus = eventBus
	self.eventBus.addEvents( self.EXPLORE_EVENTS )

	self.eventBus.register( "PlayerContactingAreasUpdated" , self , "_onPlayerContactingAreasUpdated" )
	self.eventBus.register( "DraggableClicked" , self , "_onDraggableClicked" ) 

	self.playerShip = playerShip
	self.playerCrew = playerCrew

func _ready():
	# Nodes need to exist before we can set the eventBus on them.
	self.nodes.Context.setEvents( self.eventBus )
	self.nodes.Minimap.setEvents( self.eventBus )

func menuButtonPressed( menuTarget : String ):
	for tab in self.tabBase.get_children():
		tab.queue_free()

	if( self.subUIOpen == menuTarget ):
		self.subUIOpen = "None"
	else:
		self.subUIOpen = menuTarget
		var subUIScene = load( self.MENU[menuTarget] )
		var subUI = subUIScene.instance()

		self.setupSubUI( menuTarget , subUI )

		self.tabBase.add_child( subUI )

func setupSubUI( menuTarget : String , subUI ):
	match menuTarget:
		"ASSIGNMENTS":
			subUI.setupScene( eventBus , playerCrew )
		"CREW":
			subUI.setupScene( eventBus , playerCrew )
		"EQUIPMENT":
			subUI.setupScene( eventBus , playerCrew )
		"SHIP":
			subUI.setupScene( eventBus )
		"CARGO":
			subUI.setupScene( eventBus )
		"STARMAP":
			subUI.setupScene( eventBus )

func _onPlayerContactingAreasUpdated( bodies ):
	if( bodies.size() == 0 ):
		self.nodes.NearObjectModal.hide()
	elif( bodies.size() == 1 ):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( bodies[0].showText )
	elif( bodies.size() >= 2):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( "Investigate Anomoly" )