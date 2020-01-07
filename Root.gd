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
		"GAME" : "",
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

const DEBUG_MODE = true
const DEBUG_OPTIONS = {
	"GENERATE_CREW_WITH_WOUNDS" : true
}

onready var playerGear = null
onready var playerShip = Starship.new()
onready var playerCrew = CrewFactory.generateManyCrew( 30 , 5 )

func _ready():
	globalBus = EventBusStore.getGlobalEventBus()
	loadScreen( "TITLE" )

	if( DEBUG_MODE ):
		_generateDebugGear()

	if( DEBUG_OPTIONS.GENERATE_CREW_WITH_WOUNDS ):
		for crew in playerCrew:
			crew.applyDamage( 10 , "KINETIC")
	
	globalBus.register( "NewGame_Start_Begin" , self, 'startNewGame' )

func _generateDebugGear():

	playerGear = FrameFactory.generateDebugFrames()

	var weapons = WeaponFactory.generateDebugWeapons()
	for key in weapons:
		playerGear[key] = weapons[key]

	var equipment = EquipmentFactory.generateDebugEquipment()
	for key in equipment:
		playerGear[key] = equipment[key]

	# Do some basic equiping so I can do fast testing
	playerCrew[0].itemTransaction( playerGear["TerranMinigun"] , "LWeapon" )
	playerCrew[1].itemTransaction( playerGear["TerranAssaultRifle"] , "LWeapon" )
	playerCrew[2].itemTransaction( playerGear["TerranShotGun"] , "LWeapon" )
	playerCrew[3].itemTransaction( playerGear["TerranHammer"] , "LWeapon" )
	playerCrew[4].itemTransaction( playerGear["TerranSword"] , "LWeapon" )

	for x in range( 0 , playerCrew.size() ):
		playerCrew[x].itemTransaction( playerGear["TerranPistol"] , "RWeapon" )
		playerCrew[x].itemTransaction( playerGear["TerranMedKit"] , "LEquip" )

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
	var enemyCrew = []

	# TODO this should be populated from some event
	for x in range( 0 , 5 ):
		enemyCrew.append( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )

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