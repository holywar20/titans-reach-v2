extends Control

onready var trackerScene = load("res://Views/Battle/UI/TrackerIcon.tscn")

var events = [
	"NextTurn",
	"InitiativeRolled",
	# 
	"CrewmanTurnStart" , "EnemyTurnStart",

	"CrewmanDeath",

	"ActionButtonClicked" , "StanceButtonClicked",
	# Events dealing with action processing
	"ActionStarted" ,  "TargetingBegin", "TargetingEnd" , "ActionEnded" ,

	"GeneralCancel",

	"NoMoreBattlers",

	"EndOfGame" , "EndOfBattle"
]

onready var bases = {
	"PreTurnTrackerBase" : get_node("TrackerContainer/BeforeTurn") ,
	"PostTurnTrackerBase" : get_node("TrackerContainer/AfterTurn") ,
	"InstantBase"		: get_node("Middle/VBox/InstantsContainer/VBox/BattleInstants")
}

onready var cards = {
	"AllActionCard"	: get_node("BottomControls/TurnData/VBox/HBox/AllActionCard"),
	"StanceCard"		: get_node("BottomControls/TurnData/VBox/HBox/StanceCard"),
	"CrewCard"			: get_node("BottomControls/Selection/HBox/VBox/Crew"),
	"TraitCard"			: get_node("BottomControls/Selection/HBox/VBox/TraitCard"),
	"ResistCard"		: get_node("BottomControls/Selection/HBox/ResistanceCard"),
}

onready var nodes = {
	"TurnLabel" 		: get_node("BottomControls/TurnData/VBox/Label"),
	"ActionStatus"		: get_node("Header/UncontainedUI/ActionStatus"),
	"ActionLabel"		: get_node("Header/UncontainedUI/ActionStatus/Label")
}

var eventBus = null
var currentTurnCrewman = null
var selectedAbility = null

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
	self.eventBus.register("CrewmanTurnStart" , self, "_onCrewmanTurnStart" )

	# Action Resolution
	self.eventBus.register( "ActionButtonClicked", self , '_onActionButtonClicked' )
	self.eventBus.register( "TargetingBegin" 		, self , "_onTargetingBegin" )
	self.eventBus.register( "TargetingEnd"			, self , "_onTargetingEnd" )
	self.eventBus.register( "ActionEnded"			, self , "_onActionEnded" )

	self.eventBus.register( "GeneralCancel" , self, "_onGeneralCancel" )

	self.eventBus.register( "StanceButtonClicked" , self , '_onStanceButtonClicked' )

	self.eventBus.register( "CrewmanDeath" , self, "_onCrewmanDeath" )

func _resolveAction( action : Ability ):
	self.eventBus.emit( "ActionStarted" )
	self.selectedAbility = action
	self.nodes.ActionLabel.set_text( action.fullName )
	self.nodes.ActionStatus.show()

	self.eventBus.emit( "TargetingBegin" , [ self.selectedAbility , self.currentTurnCrewman ] )

# This is generic and should apply to stances as well.
func _onTargetingBegin( ability : Ability , crewman : Crew ):
	pass

func _onTargetingEnd():
	pass

func _onActionEnd():
	pass

func _onGeneralCancel():
	if( self.selectedAbility ):
		self.selectedAbility = null
		self.nodes.ActionStatus.hide()

func loadData( crewman = null ):
	if( crewman ):
		self.currentTurnCrewman = crewman
		self.nodes.TurnLabel.set_text( "Turn : " + crewman.getFullName() )

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

func _onActionButtonClicked( action : Ability ):
	self._resolveAction( action )

func _onStanceButtonClicked( stance : Ability ):
	print( stance.shortName )

func _onCrewmanTurnStart( crewman : Crew ):
	# Find creman in tracker and highlight
	self.loadData( crewman )

func _input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		self.eventBus.emit("GeneralCancel") 