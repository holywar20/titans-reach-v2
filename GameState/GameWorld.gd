extends Node

# Quick ref for regenerating the seed. 
var systemSeed = 10000


# TODO Hiost this into an EventBus factory class, but leave the global one in GameWorld.
var globalEventBus = null
var _eventBuses = {
	"title" 		: null,
	"explore" 	: null,
	"battle" 	: null
}

const EVENT_BUS = {
	"BATTLE" : "battle",
	"EXPLORE": "explore",
	"TITLE"	: "title" 
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

func _ready():
	self.globalEventBus = EventBus.new();
	self.globalEventBus.addEvents( GLOBAL_LIFECYCLE_EVENTS )

func getSystemSeed():
	return self.systemSeed

func getGlobalBusRef():
	return self.globalEventBus

# This code deals with eventBus's. A bus must exist in _eventBuses or it's not valid.
func getEventBus( busName : String):
	if( !self._eventBuses.has( busName ) ):
		return null
		# TODO show an error about invalid bus name

	if( self._eventBuses[busName] ):
		return self._eventBuses[busName]
	else:
		self._eventBuses[busName] = EventBus.new()

func startupEventBus( busName : String ):
	pass

func clearEventBus( busName : String ):
	if( self._eventBuses.has( busName ) ):
		self._eventBuses[busName] = null
	else:
		# TODO - shoot an error
		pass 

func clearNonGlobalEvents():
	for bus in self._eventBuses:
		self._eventBuses[bus] = null

# var targetKey = self.globalEventBus.register( event , ref, func )
#	return targetKey