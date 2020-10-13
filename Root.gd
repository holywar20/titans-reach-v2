extends Node

onready var UILayer 		= get_node( "UILayer" )
onready var pauseLayer	= get_node( "PauseLayer/TextureRect" )
onready var popupLayer	= get_node( "PopupLayer/PopupContainer" )
onready var gameLayer	= get_node( "GameLayer" )
onready var debugLayer	= get_node( "DebugLayer" )

onready var popupPoint  = get_node( "PopupLayer/Position2D")

const VIEWS = {
	"EXPLORE" : {
		"UI" : "res://Views/Explore/UI/Explore.tscn" ,
		"GAME" : "res://Views/Explore/Game/Explore.tscn",
	} , 
	"BATTLE" : {
		"UI" : "res://Views/Battle/UI/Battle.tscn" ,
		"GAME" : "",
	} ,
	"TITLE" : {
		"UI" : "res://Views/Title/UI/Title.tscn" ,
		"GAME" : "",
	} , 
}

const POP_UPS = {
	"NarrativeResolution" : "res://ReusableUI/NarrativeCard/NarrativeCard.tscn",
	"LootResolution" : "res://ReusableUI/LootCard/LootCard.tscn"
}

var GlobalEventBus = null

const DEBUG_MODE = true
const DEBUG_OPTIONS = {
	"GENERATE_CREW_WITH_WOUNDS" : true
}

# TODO : Put this into a save game system of some kind, instead of loading from scratch
onready var playerGear = {}
onready var playerItems = null
onready var playerShip = Starship.new()
onready var playerCrew = CrewFactory.generateManyCrew( 30 , 5 )

func _ready():
	GlobalEventBus = EventBusStore.getGlobalEventBus()
	loadScreen( "TITLE" )

	if( DEBUG_MODE ):
		_generateDebugGear()

	if( DEBUG_OPTIONS.GENERATE_CREW_WITH_WOUNDS ):
		for crew in playerCrew:
			crew.applyDamage( 10 , "KINETIC")
	
	GlobalEventBus.register( "NewGame_Start_Begin" , self, 'startNewGame' )

	GlobalEventBus.register( "LaunchAnomolyPopup" , self, "_onLaunchAnomolyPopup" )
	GlobalEventBus.register( "ResolveAnomolyPopup" , self , "_onResolveAnomolyPopup" )

	GlobalEventBus.register( "LaunchBattleStart" , self , "_loadBattleScreen" )

func _generateDebugGear():
	var testFrameList = ["TerranLightFrame", "TerranHeavyFrame" , "TerranAssaultFrame" , "TerranMediumFrame"]
	for key in testFrameList:
		playerGear[key] = ItemDB.getCoreItem( key );

	var testWeaponList = ["TerranSword" , "TerranPistol" , "TerranHammer" , "TerranMinigun" , "TerranShotgun" , "TerranAssaultRifle" ]
	for key in testWeaponList:
		playerGear[key] = ItemDB.getCoreItem( key )

	var testEquipmentList = ["TerranShieldGenerator" , "TerranMedkit" , "TerranFragGrenade" , "TerranEMPGrenade"]
	for key in testEquipmentList:
		playerGear[key] = ItemDB.getCoreItem( key )

func _clearPopupLayer():
	for child in popupLayer.get_children():
		child.queue_free()

func _clearSelf():
	for child in gameLayer.get_children():
		child.queue_free()

	for child in UILayer.get_children():
		child.queue_free()
	
	_clearPopupLayer()

func getPlayerCrew():
	return playerCrew

func getPlayerShip():
	return playerShip

func startNewGame():
	loadScreen( "EXPLORE" )

func loadSavedGame():
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

func _loadBattleScreen( factionKey = "THE_ACCORD" , numOfEnemy = 5 , cp = 30 ):
	_clearSelf()
	var eventBus = EventBus.new()
	var enemyCrew = []

	for x in range( 0 , numOfEnemy ):
		enemyCrew.append( CrewFactory.generateNewCrewWithEquipment( cp , cp , CrewFactory.MAKE_ENEMY ) )

	# TODO - hook for a battleConfig object of some kind
	var ui = load( VIEWS.BATTLE.UI )
	var uiInstance = ui.instance()
	uiInstance.setupScene( eventBus , playerCrew , enemyCrew, {} )
	UILayer.add_child( uiInstance )

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

func pause( shouldPause ):
	if( shouldPause ):
		pauseLayer.show()
		get_tree().paused = true
	else:
		pauseLayer.hide()
		get_tree().paused = false

# Methods that respond directly to global events. Generally loading popups
func _onLaunchAnomolyPopup( anom : Anomoly , ebus : EventBus ):
	pause( true )
	
	var narrativeCardScene = load( POP_UPS.NarrativeResolution )
	var narrativeCard = narrativeCardScene.instance()
	narrativeCard.setupScene( ebus )

	popupLayer.add_child( narrativeCard )
	narrativeCard.loadData( anom.getNarrative() )

func _onResolveAnomolyPopup( anom : Anomoly ):
	pause( false )

	_clearPopupLayer()
