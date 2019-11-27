extends VBoxContainer

onready var tabBase		= get_node("Dynamic/Tab-Bind")

var eventBus = null
var subUIOpen = "None"

var playerCrew = []
var playerShip = []

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

	# Interactable Collision Events , emitted by the players ship
	"AnomolyEntered"				,"AnomolyExited",
	"PlanetEntered" 				,"PlanetExited" ,
	"ConnectionEntered"			,"ConnectionExited",
	"StarEntered"					, "StarExited",

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

func _ready():
	# Nodes need to exist before we can set the eventBus on them.
	self.nodes.Context.setEvents( self.eventBus )
	self.nodes.Minimap.setEvents( self.eventBus )

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus
	self.eventBus.addEvents( self.EXPLORE_EVENTS )

	self.eventBus.register( "PlayerContactingAreasUpdated" , self , "_onPlayerContactingAreasUpdated" )

func setPlayerCrew( crew ):
	self.playerCrew = crew

func menuButtonPressed( menuTarget : String ):
	for tab in self.tabBase.get_children():
		tab.queue_free()

	if( self.subUIOpen == menuTarget ):
		self.eventBus.emit( "SubUICloseBegin" )
		self.subUIOpen = "None"
	else:
		self.eventBus.emit("SubUIOpenBegin")
		
		self.subUIOpen = menuTarget
		var subUIScene = load( self.MENU[menuTarget] )
		print( self.MENU[menuTarget] )
		var subUI = subUIScene.instance()
		
		if( subUI.has_method( "setEvents" ) ):
			subUI.setEvents( self.eventBus )

		self.tabBase.add_child( subUI )

func _onPlayerContactingAreasUpdated( bodies ):
	if( bodies.size() == 0 ):
		self.nodes.NearObjectModal.hide()
	elif( bodies.size() == 1 ):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( bodies[0].showText )
	elif( bodies.size() >= 2):
		self.nodes.NearObjectModal.show()
		self.nodes.NearObjectButton.set_text( "Investigate Anomoly" )