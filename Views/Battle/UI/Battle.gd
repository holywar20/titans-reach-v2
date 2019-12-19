extends Control

onready var trackerScene = load("res://Views/Battle/UI/TrackerIcon.tscn")

var events = [
	"NextTurn",
	"InitiativeRolled",
	# 
	"CrewmanTurn" , "EnemyTurn",

	"CrewmanDeath",

	"EndOfGame" , "EndOfBattle"
]

onready var bases = {
	"PreTurnTrackerBase" : get_node("TrackerContainer/BeforeTurn") ,
	"PostTurnTrackerBase" : get_node("TrackerContainer/AfterTurn") ,
	"InstantBase"	: get_node("Middle/VBox/InstantsContainer/VBox/InstantBase")
}

var eventBus = null

func setupScene( eventBus : EventBus ):
	self.eventBus = eventBus

func loadCrewman( crewman : Crew ):
	pass 

func _ready():
	if( self.eventBus ):
		self.loadEvents()

func loadEvents():
	print( "loading events ")
	self.eventBus.addEvents( self.events )
	
	self.eventBus.register("CrewmanTurn" , self, "_onCrewmanTurn" )
	self.eventBus.register("InitiativeRolled" , self, "_onInitiativeRolled")
	self.eventBus.register("CrewmanDeath" , self, "_onCrewmanDeath" )

func _onBattleOrderChange( battleOrder ):
	pass

func _onInitiativeRolled( initiativeArray ):
	
	for tuple in initiativeArray:
		var actor = tuple.Actor
		var init = tuple.Init

		var newTrackerIcon = self.trackerScene.instance()
		newTrackerIcon.setupScene( self.eventBus, actor, init )

		self.bases.PreTurnTrackerBase.add_child( newTrackerIcon )

func _onCrewmanDeath( crewman ):
	pass

func _onCrewmanTurn( crewman : Crew ):
	
	# var action = self._pickAction()

	pass