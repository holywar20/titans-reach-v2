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

const POPUPS = {
	"BattlePosition" : ""
	}

var globalBus = null

onready var playerGear = null
onready var playerShip = Starship.new()
onready var playerCrew = CrewFactory.generateManyCrew( 30 , 5 )

func _ready():
	self.globalBus = EventBusStore.getGlobalEventBus()
	self.loadScreen( "TITLE" )

	self._generateDebugGear()

	self.globalBus.register( "NewGame_Start_Begin" , self, 'startNewGame' )

func _generateDebugGear():

	self.playerGear = FrameFactory.generateDebugFrames()

	var weapons = WeaponFactory.generateDebugWeapons()
	for key in weapons:
		self.playerGear[key] = weapons[key]

	var equipment = EquipmentFactory.generateDebugEquipment()
	for key in equipment:
		self.playerGear[key] = equipment[key]

func _clearSelf():
	for child in self.gameLayer.get_children():
		child.queue_free()

	for child in self.UILayer.get_children():
		child.queue_free()
	
	for child in self.popupLayer.get_children():
		child.queue_free()

func _loadBattlePositionPopup( myCrew, battleType , myBattleOrder , inBattle = true):

	var myPopupScene = load( self.POP_UPS["BattlePosition"] )
	var myPopup = myPopupScene.instance()
	myPopup.initScene( myCrew, battleType , myBattleOrder , inBattle )

	self.popupLayer.add_child( myPopup )

func getPlayerCrew():
	return self.playerCrew

func getPlayerShip():
	return self.playerShip

func startNewGame():
	self.loadScreen( "EXPLORE" )

func loadSavedGame():
	pass

func loadPopup():
	pass

func loadScreen( screenName ):
	
	if( !self.VIEWS.has( screenName ) ):
		# fire an error
		print("Loading Error , VIEW doesn't exist in root: ", screenName )
		return null
	else:
		match screenName:
			"EXPLORE" :
				self._loadExploreScreen()
			"TITLE":
				self._loadTitleScreen()
			"BATTLE":
				self._loadBattleScreen()

func _loadTitleScreen():
	self._clearSelf()

	var ui 	= load( self.VIEWS.TITLE.UI )
	var uiInstance = ui.instance()
	self.UILayer.add_child( uiInstance )

func _loadBattleScreen():
	self._clearSelf()
	var eventBus = EventBus.new()

	var ui = load( self.VIEWS.BATTLE.UI )
	var uiInstance = ui.instance()
	# Scene set up
	uiInstance.setupScene( eventBus )
	self.UILayer.add_child( uiInstance )
	

	var battleMap = load( self.VIEWS.BATTLE.GAME )
	var battleMapInstance = battleMap.instance()
	# TODO - add a hook to some kind of 'battle factory' to make the dictionary
	battleMapInstance.setupScene( eventBus , playerCrew , {} )
	self.gameLayer.add_child( battleMapInstance )
	

	

func _loadExploreScreen():
	self._clearSelf()

	var ui = load( self.VIEWS.EXPLORE.UI )
	var uiInstance = ui.instance()
	
	var eventBus = EventBus.new()
	uiInstance.setupScene( eventBus , self.playerShip, self.playerCrew , self.playerGear )

	self.UILayer.add_child( uiInstance )

	var exploreMap = load( self.VIEWS.EXPLORE.GAME )
	var exploreMapInstance = exploreMap.instance()
	exploreMapInstance.setEvents( eventBus )

	self.gameLayer.add_child( exploreMapInstance )

	# Generate the previous system, by using the random seed, which was saved in StarSystemGenerator
	# var systemDict = StarSystemGenerator.generateRandomSystem( 100 ) # TODO - Starsystem shouldn't depend on a scene.
	# travelMapInstance.populateStarSystem(systemDict.star, systemDict.planets, systemDict.connections, systemDict.decorators )