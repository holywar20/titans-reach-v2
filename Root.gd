extends Node

onready var UILayer 		= get_node( "UILayer" )
onready var pauseLayer	= get_node( "PauseLayer" )
onready var popupLayer	= get_node( "PopupLayer" )
onready var gameLayer	= get_node( "GameLayer" )
onready var debugLayer	= get_node( "DebugLayer" )

const VIEWS = {
	"EXPLORE" : {
		"UI" : "res://Views/Explore/UI/Explore.tscn" ,
		"GAME" : "res://Views/Explore/Game/Explore.tscn",
	} , 
	"BATTLE" : {
		"UI" : "res://Views/Battle/UI/Battle.tscn" ,
		"GAME" : "res://Views/Battle/Game/Battle.tscn",
	} ,
	"TITLE" : {
		"UI" : "res://Views/Title/UI/Title.tscn" ,
		"GAME" : "",
	} , 
}

const POP_UPS = {
	"BattlePosition" : ""
	}

var globalBus = null

onready var playerGear = null
onready var playerShip = Starship.new()
onready var playerCrew = CrewFactory.generateManyCrew( 30 , 5 )

func _ready():
	globalBus = EventBusStore.getGlobalEventBus()
	loadScreen( "TITLE" )

	_generateDebugGear()

	globalBus.register( "NewGame_Start_Begin" , self, 'startNewGame' )

func _generateDebugGear():

	playerGear = FrameFactory.generateDebugFrames()

	var weapons = WeaponFactory.generateDebugWeapons()
	for key in weapons:
		playerGear[key] = weapons[key]

	var equipment = EquipmentFactory.generateDebugEquipment()
	for key in equipment:
		playerGear[key] = equipment[key]

func _clearSelf():
	for child in gameLayer.get_children():
		child.queue_free()

	for child in UILayer.get_children():
		child.queue_free()
	
	for child in popupLayer.get_children():
		child.queue_free()

func _loadBattlePositionPopup( myCrew, battleType , myBattleOrder , inBattle = true):

	var myPopupScene = load( POP_UPS["BattlePosition"] )
	var myPopup = myPopupScene.instance()
	myPopup.initScene( myCrew, battleType , myBattleOrder , inBattle )

	popupLayer.add_child( myPopup )

func getPlayerCrew():
	return playerCrew

func getPlayerShip():
	return playerShip

func startNewGame():
	loadScreen( "EXPLORE" )

func loadSavedGame():
	pass

func loadPopup():
	pass

func loadScreen( screenName ):
	
	if( !VIEWS.has( screenName ) ):
		# fire an error
		print("Loading Error , VIEW doesn't exist in root: ", screenName )
		return null
	else:
		match screenName:
			"EXPLORE" :
				_loadExploreScreen()
			"TITLE":
				_loadTitleScreen()
			"BATTLE":
				_loadBattleScreen()

func _loadTitleScreen():
	_clearSelf()

	var ui 	= load( VIEWS.TITLE.UI )
	var uiInstance = ui.instance()
	UILayer.add_child( uiInstance )

func _loadBattleScreen():
	_clearSelf()
	var eventBus = EventBus.new()

	var ui = load( VIEWS.BATTLE.UI )
	var uiInstance = ui.instance()
	# Scene set up
	uiInstance.setupScene( eventBus )
	UILayer.add_child( uiInstance )
	

	var battleMap = load( VIEWS.BATTLE.GAME )
	var battleMapInstance = battleMap.instance()
	# TODO - add a hook to some kind of 'battle factory' to make the dictionary
	battleMapInstance.setupScene( eventBus , playerCrew , {} )
	gameLayer.add_child( battleMapInstance )

func _loadExploreScreen():
	_clearSelf()

	var ui = load( VIEWS.EXPLORE.UI )
	var uiInstance = ui.instance()
	
	var eventBus = EventBus.new()
	uiInstance.setupScene( eventBus , playerShip, playerCrew , playerGear )

	UILayer.add_child( uiInstance )

	var exploreMap = load( VIEWS.EXPLORE.GAME )
	var exploreMapInstance = exploreMap.instance()
	exploreMapInstance.setEvents( eventBus )

	gameLayer.add_child( exploreMapInstance )

	# Generate the previous system, by using the random seed, which was saved in StarSystemGenerator
	# var systemDict = StarSystemGenerator.generateRandomSystem( 100 ) # TODO - Starsystem shouldn't depend on a scene.
	# travelMapInstance.populateStarSystem(systemDict.star, systemDict.planets, systemDict.connections, systemDict.decorators )