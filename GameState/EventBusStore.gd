extends Node

var _globalEventBus = EventBus.new()

const GLOBAL_LIFECYCLE_EVENTS = [
	# Events linked to specific buttons
	"NewGame_Start_Begin"		, "NewGame_Start_End" ,

	# Triggered events, fired by Root.gd, that handles the scene tree.
	"TitleScreen_Open_Begin"	, "TitleScreen_Open_End",
	"TitleScreen_Close_Begin"	, "TitleScreen_Close_End",
	"BattleScreen_Open_Begin"	, "BattleScreen_Open_End",
	"BattleScreen_Close_Begin"	, "BattleScreen_Close_End",
	"ExploreScreen_Open_Begin"	, "ExploreScreen_Open_End",
	"ExploreScreen_Close_Begin"	, "ExploreScreen_Close_End"
]

func _ready():
	_globalEventBus.addEvents( GLOBAL_LIFECYCLE_EVENTS )

func getGlobalEventBus():
	return _globalEventBus