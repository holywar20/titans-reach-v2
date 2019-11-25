extends Node

var _globalEventBus = EventBus.new()
var _eventBuses = {
	"title" 		: EventBus.new(),
	"explore" 	: EventBus.new(),
	"battle" 	: EventBus.new()
}

const BUS = {
	'EXPLORE' : 'explore' ,
	'TITLE'	: 'title',
	'BATTLE'	: 'battle'
}

const GLOBAL_LIFECYCLE_EVENTS = [
	# Events linked to specific buttons
	"NewGame_Start_Begin"		, "NewGame_Start_End" ,

	# Triggered events, fired by Root.gd, that handles the scene tree.
	"TitleScreen_Open_Begin"	, "TitleScreen_Open_End",
	"TitleScreen_Close_Begin"	, "TitleScreen_Close_End",
	"BattleScreen_Open_Begin"	, "BattleScreen_Open_End",
	"BattleScreen_Close_Begin"	, "BattleScreen_Close_End",
	"ExploreScreen_Open_Begin"	, "ExploreScreen_Open_End",
	"ExploreScreen_CloseBegin"	, "ExploreScreen_Close_End"
]

const EXPLORE_EVENTS = [
	# Fired when a planet or star has been clicked
	"StarClickedStart" , "StarClickedEnd",
	"PlanetClickedStart" , "PlanetClickedEnd",

	# Cancel current action that is only partially complete, or exit a context menu
	"GeneralCancel"
]

func _ready():
	self._globalEventBus.addEvents( self.GLOBAL_LIFECYCLE_EVENTS )

	self._eventBuses.explore.addEvents( self.EXPLORE_EVENTS )

func getGlobalEventBus():
	return self._globalEventBus

func getEventBus( busName : String ):
	return self._eventBuses[busName]