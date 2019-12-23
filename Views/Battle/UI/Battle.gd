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

func setupScene( eBus : EventBus ):
	eventBus = eBus

func _ready():
	loadEvents()

	cards.StanceCard.setupScene( eventBus , null )
	cards.CrewCard.setupScene( eventBus , null )
	cards.TraitCard.setupScene( eventBus , null )
	cards.ResistCard.setupScene( eventBus , null )
	cards.AllActionCard.setupScene( eventBus , null )

func loadEvents():
	eventBus.addEvents( events )
	
	eventBus.register("InitiativeRolled" , self, "_onInitiativeRolled")
	eventBus.register("CrewmanTurnStart" , self, "_onCrewmanTurnStart" )

	# Action Resolution
	eventBus.register( "ActionButtonClicked", self , '_onActionButtonClicked' )
	eventBus.register( "TargetingBegin" 		, self , "_onTargetingBegin" )
	eventBus.register( "TargetingEnd"			, self , "_onTargetingEnd" )
	eventBus.register( "ActionEnded"			, self , "_onActionEnded" )

	eventBus.register( "GeneralCancel" , self, "_onGeneralCancel" )

	eventBus.register( "StanceButtonClicked" , self , '_onStanceButtonClicked' )

	eventBus.register( "CrewmanDeath" , self, "_onCrewmanDeath" )

func _resolveAction( action : Ability ):
	eventBus.emit( "ActionStarted" )
	selectedAbility = action
	nodes.ActionLabel.set_text( action.fullName )
	nodes.ActionStatus.show()

	eventBus.emit( "TargetingBegin" , [ selectedAbility , currentTurnCrewman ] )

# This is generic and should apply to stances as well.
func _onTargetingBegin( ability : Ability , crewman : Crew ):
	pass

func _onTargetingEnd():
	pass

func _onActionEnd():
	pass

func _onGeneralCancel():
	if( selectedAbility ):
		selectedAbility = null
		nodes.ActionStatus.hide()

func loadData( crewman = null ):
	if( crewman ):
		currentTurnCrewman = crewman
		nodes.TurnLabel.set_text( "Turn : " + crewman.getFullName() )

		cards.CrewCard.loadData( currentTurnCrewman )
		cards.TraitCard.loadData( currentTurnCrewman )
		cards.ResistCard.loadData( currentTurnCrewman )

		cards.StanceCard.loadData( currentTurnCrewman )
		cards.AllActionCard.loadData( currentTurnCrewman )
		

func _onBattleOrderChange( battleOrder ):
	pass

func _onInitiativeRolled( initiativeArray ):
	
	for tuple in initiativeArray:
		var actor = tuple.Actor
		var init = tuple.Init

		var newTrackerIcon = trackerScene.instance()
		newTrackerIcon.setupScene( eventBus, actor, init )

		bases.PreTurnTrackerBase.add_child( newTrackerIcon )

func _onCrewmanDeath( crewman : Crew ):
	loadData( crewman )

func _onCrewmanHover( crewman : Crew ):
	loadData( crewman )

func _onActionButtonClicked( action : Ability ):
	_resolveAction( action )

func _onStanceButtonClicked( stance : Ability ):
	print( stance.shortName )

func _onCrewmanTurnStart( crewman : Crew ):
	# Find creman in tracker and highlight
	loadData( crewman )

func _input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		eventBus.emit("GeneralCancel") 