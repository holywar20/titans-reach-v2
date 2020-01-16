extends VBoxContainer

onready var anomButtonScene = load("res://Views/Explore/UI/AnomolyButton/AnomolyButton.tscn")

onready var tabBase		= get_node("Dynamic/Tab-Bind")
onready var anomButtonBase = get_node("Footer/Near/Buttons")

onready var nodes = {
	"AnomButtons"			: get_node("Footer/Near"),
	"Context"				: get_node("Dynamic/Right/Context"),
	"Minimap"				: get_node("Dynamic/Right/Minimap")
}

# Passed in by the parent
var eventBus = null
var playerCrew = []
var playerShip = []
var playerGear = {}

var GlobalEventBus = null

# Utilized by elements that list all crew sequentially
var currentCrewmanIdx = null
var subUIOpen = "None"

const MENU = { 
	'ASSIGNMENTS'	: "res://Views/Explore/UI/SubUI/Assignments.tscn",
	'CREW' 			: "res://Views/Explore/UI/SubUI/Crew.tscn",
	'EQUIPMENT'		: "res://Views/Explore/UI/SubUI/Equipment.tscn",
	'SHIP'			: "res://Views/Explore/UI/SubUI/Ship.tscn",
	'CARGO'			: "res://Views/Explore/UI/SubUI/Cargo.tscn",
	'STARMAP'		: "res://Views/Explore/UI/SubUI/Starmap.tscn" ,
	"MARKETS" 		: "res://Views/Explore/UI/SubUI/Markets.tscn" ,
	"SYSTEM"			: "res://Views/Explore/UI/SubUI/System.tscn"
}

const EXPLORE_EVENTS = [
	# Fired when a planet or star has been clicked
	"StarClickedStart" 			,"StarClickedEnd",
	"PlanetClickedStart"			,"PlanetClickedEnd",
	"AnomolyClicked"				,

	# Called on the _ready function of the Explore Page
	"CelestialsLoadingOnMap" 	, "CelestialsLoadedOnMap",

	# Draggable events, fired by a draggable object or Draglock
	"DraggableCreated", "DraggableReleased", "DraggableMatched",
	
	# Events fired by UI elements that indicate succesful data changes, that other UI elements might care about.
	"CrewmanAssigned", "WeaponAssigned" , "EquipmentAssigned",

	# Anomolies ( AnomolyEntered & AnomolyExited are emmited by the player ship )
	"AnomolyEntered"		, "AnomolyExited",  "AnomButtonPressed",

	# Dealing with Narratives 
	"NarrativeOptionSelected",
	"NarrativeBattleStart" , "NarrativeLootStart" , "NarrativeOver" , 

	# Events fired by Card Nodes
	"CrewmanSelected", "ItemSelected",

	# Issued by player ship whenever it notices a change in the Areas it's interacting with.
	"PlayerContactingAreasUpdated",

	"SubUIAnyOpenBegin"	, "SubUIAnyOpenEnd",
	"SubUIAnyCloseBegin"	, "SubUIAnyCloseEnd",

	# Cancel current action that is only partially complete, or exit a context menu
	"GeneralCancel"
]

func setupScene( eBus : EventBus, pShip : Starship , pCrew , pGear ):
	eventBus = eBus
	eventBus.addEvents( EXPLORE_EVENTS )

	eventBus.register( "AnomButtonPressed" , self , "_onAnomButtonPressed")
	eventBus.register( "PlayerContactingAreasUpdated" , self , "_onPlayerContactingAreasUpdated" )

	eventBus.register("NarrativeBattleStart" , self , "_onNarrativeBattleStart" )
	eventBus.register("NarrativeLootStart" , self , "_onNarrativeLootStart")
	eventBus.register("NarrativeOver" , self , "_onNarrativeOver")

	playerShip = pShip
	playerCrew = pCrew
	playerGear = pGear

	currentCrewmanIdx = 0

func _ready():
	# Nodes need to exist before we can set the eventBus on them.
	nodes.Context.setEvents( eventBus )
	nodes.Minimap.setEvents( eventBus )

	GlobalEventBus = EventBusStore.getGlobalEventBus()

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
		"MARKETS" :
			subUI.setupScene( eventBus )
		"SYSTEM" :
			subUI.setupScene( eventBus )

func getEquipableGear():
	return playerGear

func getCurrentCrewman():
	return playerCrew[currentCrewmanIdx]

func getNextCrewman():
	currentCrewmanIdx = currentCrewmanIdx + 1
	if( currentCrewmanIdx > playerCrew.size() - 1 ):
		currentCrewmanIdx = 0

	return playerCrew[currentCrewmanIdx]

func getPrevCrewman():
	currentCrewmanIdx = currentCrewmanIdx - 1
	if( currentCrewmanIdx < 0 ):
		currentCrewmanIdx = playerCrew.size() - 1
	
	return playerCrew[currentCrewmanIdx]


func _onPlayerContactingAreasUpdated( anoms ):
	if( anoms.size() == 0 ):
		nodes.AnomButtons.hide()
	else:
		for child in anomButtonBase.get_children():
			child.queue_free()

		for anom in anoms:
			var button = anomButtonScene.instance()
			button.set_text( anom.getShowText() )
			button.setupScene( anom , eventBus )
			anomButtonBase.add_child( button )

		nodes.AnomButtons.show()

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

func _onAnomButtonPressed( anom ):
	GlobalEventBus.emit( "LaunchAnomolyPopup" , [ anom , eventBus ] )

func _onNarrativeBattleStart( narrative : Narrative ):
	var params = narrative.eventParams

func _onNarrativeLootStart( narrative : Narrative ):
	var params = narrative.eventParams

func _onNarrativeOver( narrative : Narrative ):
	var params = narrative.eventParams
