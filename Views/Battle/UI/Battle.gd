extends Control

onready var trackerScene = load("res://Views/Battle/UI/TrackerIcon.tscn")

var events = [
	"NextTurn",
	"InitiativeRolled",
	# 
	"CrewmanTurn" , "EnemyTurn",

	"CrewmanDeath",

	# Events dealing with action processing
	"ActionStarted" , 
	"SelectAlly" , "SelectEnemy" , "SelectAllyFloor" , "SelectEnemyFloor",
	"ActionEnded" ,

	"StanceChanged",

	"GeneralCancel",

	"NoMoreBattlers",

	"EndOfGame" , "EndOfBattle"
]

onready var bases = {
	"PreTurnTrackerBase" : get_node("TrackerContainer/BeforeTurn") ,
	"PostTurnTrackerBase" : get_node("TrackerContainer/AfterTurn") ,
	"InstantBase"	: get_node("Middle/VBox/InstantsContainer/VBox/InstantBase")
}

onready var cards = {
	"AllActionCard": get_node("BottomControls/TurnData/VBox/HBox/AllActionCard"),
	"StanceCard"	: get_node("BottomControls/TurnData/VBox/HBox/StanceCard"),
	"CrewCard"		: get_node("BottomControls/Selection/HBox/VBox/Crew"),
	"TraitCard"		: get_node("BottomControls/Selection/HBox/VBox/TraitCard"),
	"ResistCard"	: get_node("BottomControls/Selection/HBox/ResistanceCard"),
}

onready var nodes = {
	"TurnLabel" : get_node("BottomControls/TurnData/VBox/Label")
}

var eventBus = null
var currentTurnCrewman = null

func setupScene( eventBus : EventBus ):
	self.eventBus = eventBus

func _ready():
	self.loadEvents()

	self.cards.StanceCard.setupScene( self.eventBus , null )
	self.cards.CrewCard.setupScene( self.eventBus , null )
	self.cards.TraitCard.setupScene( self.eventBus , null )
	self.cards.ResistCard.setupScene( self.eventBus , null )
	self.cards.AllActionCard.setupScene( self.eventBus , null )

func loadEvents():
	self.eventBus.addEvents( self.events )
	
	self.eventBus.register("InitiativeRolled" , self, "_onInitiativeRolled")

	self.eventBus.register("CrewmanTurn" , self, "_onCrewmanTurn" )
	self.eventBus.register("CrewmanDeath" , self, "_onCrewmanDeath" )

func loadData( crewman = null ):
	if( crewman ):
		self.currentTurnCrewman = crewman
		self.cards.CrewCard.loadData( self.currentTurnCrewman )
		self.cards.TraitCard.loadData( self.currentTurnCrewman )
		self.cards.ResistCard.loadData( self.currentTurnCrewman )

		self.cards.StanceCard.loadData( self.currentTurnCrewman )
		self.cards.AllActionCard.loadData( self.currentTurnCrewman )
		

func _onBattleOrderChange( battleOrder ):
	pass

func _onInitiativeRolled( initiativeArray ):
	
	for tuple in initiativeArray:
		var actor = tuple.Actor
		var init = tuple.Init

		var newTrackerIcon = self.trackerScene.instance()
		newTrackerIcon.setupScene( self.eventBus, actor, init )

		self.bases.PreTurnTrackerBase.add_child( newTrackerIcon )

func _onCrewmanDeath( crewman : Crew ):
	self.loadData( crewman )

func _onCrewmanHover( crewman : Crew ):
	self.loadData( crewman )

func _onCrewmanTurn( crewman : Crew ):
	# Find creman in tracker and highlight
	self.loadData( crewman )