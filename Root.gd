extends Node

onready var UILayer = get_node( "UILayer" )
onready var pauseLayer = get_node( "PauseLayer" )
onready var popupLayer = get_node( "PopupLayer" )
onready var gameLayer = get_node( "GameLayer" )
onready var debugLayer = get_node( "DebugLayer" )

const VIEWS = {
	"EXPLORE" : {
		"UI" : "" ,
		"GAME" : "res://Views/Explore/Game/Explore.tscn",
		"EVENTBUS"	: GameWorld.EVENT_BUS.EXPLORE
	} , 
	"BATTLE" : {
		"UI" : "" ,
		"Game" : "",
		"EVENTBUS" : GameWorld.EVENT_BUS.BATTLE
	} ,
	"TITLE" : {
		"UI" : "res://Views/Title/UI/Title.tscn" ,
		"Game" : "",
		"EVENTBUS" : GameWorld.EVENT_BUS.TITLE
	}
}

const POPUPS = {
	"BattlePosition" : ""
	}


var globalBus = GameWorld.getEventBus("")

# Event Keys
var onStartNewGame = null

func _ready():
	self.loadScreen( "TITLE" )

	self.globalBus = GameWorld.getGlobalBusRef()
	self.onStartNewGame = self.globalBus.register( "NewGame_Start_Begin" , self, 'startNewGame' )

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

func startNewGame():
	print("Starting new Game")
	self.loadScreen( "EXPLORE" )

func loadSavedGame():
	pass

func loadPopup():
	pass

func loadScreen( screenName ):
	
	if( !self.VIEWS.has( screenName ) ):
		# fire an error
		print("error: ", screenName )
		return null
	else:
		match screenName:
			"EXPLORE" :
				self._loadExploreScreen()
				print("loading Explore")
			"BATTLE" :
				self._loadBattleScreen()
				print("loading Battle")
			"TITLE":
				self._loadTitleScreen()
				print("loading Title")

func _loadTitleScreen():
	self._clearSelf()

	var ui 	= load( self.VIEWS.TITLE.UI )
	print( self.VIEWS.TITLE.UI )
	var uiInstance = ui.instance()
	self.UILayer.add_child( uiInstance )

func _loadBattleScreen():
	self._clearSelf()

func _loadExploreScreen():
	self._clearSelf()
	
	#var ui = load( self.VIEWS.EXPLORE.UI )
	#var uiInstance = ui.instance()
	#self.UILayer.add_child(uiInstance);

	var exploreMap = load( self.VIEWS.EXPLORE.GAME )
	var exploreMapInstance = exploreMap.instance()
	self.gameLayer.add_child( exploreMapInstance )

	# Generate the previous system, by using the random seed, which was saved in StarSystemGenerator
	# var systemDict = StarSystemGenerator.generateRandomSystem( 100 ) # TODO - Starsystem shouldn't depend on a scene.
	# travelMapInstance.populateStarSystem(systemDict.star, systemDict.planets, systemDict.connections, systemDict.decorators )