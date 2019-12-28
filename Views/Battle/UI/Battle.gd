extends Control

onready var trackerScene = load("res://Views/Battle/UI/TrackerIcon.tscn")

var events = [
	# Events with turn order
	"NextPass" , "NextTurn", "InitiativeRolled", "TurnEnd" ,

	# Events
	"CrewmanTurnStart" , "CrewmanTurnEnd" , "EnemyTurnStart", "EnemyTurnEnd",

	# Events dealing with action processing
	"ActionStarted" , 
	"TargetingBegin", 
	"TargetingTile" , "TargetingBattler" ,
	"TargetingSelected" , 
	"ActionEnded" ,

	# UI events
	"ActionButtonClicked" , "StanceButtonClicked", "GeneralCancel",
	"HoverCrewman" , "UnhoverCrewman",
	
	# Triggered events
	"NoMoreBattlers", "EndOfGame" , "EndOfBattle" , "CrewmanDeath" , "EnemyDeath"
]

onready var bases = {
	"PreTurnTrackerBase" : get_node("TrackerContainer/BeforeTurn") ,
	"PostTurnTrackerBase" : get_node("TrackerContainer/AfterTurn") ,
	"BattleMap"				: get_node("Middle/SpacerControl/Battle")
}

onready var cards = {
	"LeftCrewDetailCard" 	: get_node("BottomControls/Selection/LeftCrewDetail"),

	"AllActionCard"			: get_node("BottomControls/TurnData/HBox/AllActionCard"),
	# TODO - add a stance card
	# TODO - add an instant card
	"ActionsContainer"		: get_node("BottomControls/TurnData/HBox"),
	"ActionCard"				: get_node("BottomControls/TurnData/ActionCard"),

	"RightCrewDetailCard" 	: get_node("BottomControls/TargetData/RightCrewDetail"),
}

onready var nodes = {
	"TurnLabel" 		: get_node("BottomControls/TurnData/VBox/Label"),
	"ActionStatus"		: get_node("Header/UncontainedUI/ActionStatus"),
	"ActionLabel"		: get_node("Header/UncontainedUI/ActionStatus/Label")
}

var eventBus = null

# Battle state
var playerCrew = []
var enemyCrew = []
var currentTurnActor = null
var selectedAbility = null

# Potential config options should be declared here.=

func setupScene( eBus : EventBus , crew , enemy , config ):
	eventBus = eBus
	playerCrew = crew
	enemyCrew = enemy

	loadEvents()

func _ready():
	cards.ActionCard.setupScene( eventBus , null )
	cards.AllActionCard.setupScene( eventBus , null )

	cards.LeftCrewDetailCard.setupScene( eventBus , null )
	cards.RightCrewDetailCard.setupScene( eventBus , null )

	bases.BattleMap.setupScene( eventBus, playerCrew, enemyCrew )

	_nextPass()

func loadEvents():
	eventBus.addEvents( events )

	eventBus.register("NextPass" , self ,  "_nextPass")
	eventBus.register( "TurnEnd" , self , "_onTurnEnd")
	
	# Events we would receive from UI elements that are not buttons.
	eventBus.register( "TargetingSelected"	, self , "_onTargetingSelected" )

	# Button events
	eventBus.register( "StanceButtonClicked" , self , '_onStanceButtonClicked' )
	eventBus.register( "ActionButtonClicked", self , '_onActionButtonClicked' )
	
	eventBus.register( "GeneralCancel" , self, "_onGeneralCancel" )

func _nextPass():
	var allActors = []
	
	for crew in enemyCrew:
		if( crew.getFightableStatus() ):
			allActors.append( crew )
	
	for crew in playerCrew:
		if( crew.getFightableStatus() ):
			allActors.append( crew )
	
	var packedArray = []
	for actor in allActors:
		packedArray.append({ 
				"Init": actor.rollInit() , 
				"Actor" : actor
			})
	
	packedArray = Common.bubbleSortArrayByDictKey( packedArray , "Init" , "Invert" )
	for tuple in packedArray:
		var newTrackerIcon = trackerScene.instance()
		newTrackerIcon.setupScene( eventBus, tuple.Actor, tuple.Init )
		bases.PreTurnTrackerBase.add_child( newTrackerIcon )
	
	_nextTurn()

func _nextTurn():
	# Do all checks that could invalidate the next turn
	if( _validateAlive( playerCrew ) ):
		_loadEndGame()

	if( _validateAlive( enemyCrew ) ):
		_loadEndBattle()

	var trackerIcons = bases.PreTurnTrackerBase.get_children()
	if( trackerIcons.size() == 0 ):
		eventBus.emit( "NextPass" , [] )
		return null

	# Default the entire tracker
	for tracker in trackerIcons:
		tracker.set_turn_state( tracker.TURN.NOT_ACTIVE )

	var nextTracker = trackerIcons.pop_front()

	bases.PreTurnTrackerBase.remove_child( nextTracker )
	bases.PostTurnTrackerBase.add_child( nextTracker )
	nextTracker.set_owner( bases.PostTurnTrackerBase )

	currentTurnActor = nextTracker.getActor()
	nextTracker.set_turn_state( nextTracker.TURN.ACTIVE )

	if( currentTurnActor.isPlayer ):
		_crewmanStartTurn( currentTurnActor )
	else:
		_enemyStartTurn( currentTurnActor )

func _crewmanStartTurn( crewman : Crew ):
	eventBus.emit("CrewmanTurnStart" , [ crewman ] )
	loadData( crewman )

	cards.LeftCrewDetailCard.loadData( crewman )

func _crewmanTurnEnd( crewman : Crew ):
	cards.LeftCrewDetailCard.loadData()

	eventBus.emit( "CrewmanTurnEnd" , [ crewman ] )
	eventBus.emit( "TurnEnd" , [ crewman ] )

func _enemyStartTurn ( crewman : Crew ):
	eventBus.emit("EnemyTurnStart" , [ crewman ] )
	
	loadData( crewman )
	
	cards.RightCrewDetailCard.loadData( crewman )
	nodes.ActionLabel.set_text( "Enemy" )
	nodes.ActionStatus.show()

	yield( get_tree().create_timer(3.0), "timeout" )
	
	nodes.ActionStatus.hide()
	nodes.ActionLabel.set_text("")

	_enemyTurnEnd( crewman )

func _enemyTurnEnd( crewman ):
	cards.RightCrewDetailCard.loadData()

	eventBus.emit( "EnemyTurnEnd" , [crewman] )
	eventBus.emit( "TurnEnd" , [ crewman ] )

func _onTurnEnd( crewman : Crew ):
	_nextTurn()

# Action resolution & Targeting
func _resolveAction( action : Ability ):
	eventBus.emit( "ActionStarted" , [ action ])
	selectedAbility = action
	nodes.ActionLabel.set_text( action.fullName )
	nodes.ActionStatus.show()

	# TODO - currently only permits 1 selection, should allow for multiple selections
	_targetingBegin( selectedAbility , currentTurnActor )

func _targetingBegin( ability : Ability , crewman : Crew ):
	eventBus.emit( "TargetingBegin" , [ ability , crewman ] )

	var validTargets = ability.getValidTargets()
	if( ability.targetType == "ALLY_UNIT" || ability.targetType == "SELF" ):
		eventBus.emit("TargetingBattler" , [ validTargets , crewman.isPlayer ] )
	elif( ability.targetType == "ALLY_FLOOR" ):
		eventBus.emit("TargetingTile" , [ validTargets, crewman.isPlayer ] )
	elif( ability.targetType == "ENEMY_FLOOR" ): # Here we send the opposite of player. So true if it's NOT a player, and false if it is.
		eventBus.emit("TargetingTile" , [ validTargets , !crewman.isPlayer ])
	elif( ability.targetType == "ENEMY_UNIT" ):
		eventBus.emit("TargetingBattler" , [ validTargets , !crewman.isPlayer ])

func _onTargetingSelected( myX , myY ):
	_completeAction( myX , myY )

func _completeAction(  targetX , targetY ):
	#eventBus.emit( "ActionEnd" , [ action ] )
	print("action Completion Reached!")

	_resolvePassiveEffects()
	_resolveDamageEffects()
	_resolveMovement()
	_resolveStatusEffects()
	
	# TODO : Validate if anyone is alive or not 

	_crewmanTurnEnd( currentTurnActor )

func _resolveMovement():
	# Fire an event to inform battleOrder to update
	pass

func _resolveStatusEffects():
	pass 

func _resolvePassiveEffects():
	pass

func _resolveDamageEffects():
	# TODO - figure out target map for area effects
	pass

func _onGeneralCancel():
	if( selectedAbility ):
		selectedAbility = null
		nodes.ActionStatus.hide()

# Other UI Events
func _onCrewmanDeath( crewman : Crew ):
	loadData( crewman )

func _onCrewmanHover( crewman : Crew ):
	loadData( crewman )

func loadData( crewman = null ):
	if( crewman ):
		currentTurnActor = crewman
		
		cards.AllActionCard.loadData( currentTurnActor )

func _loadEndGame():
	# Fire local event
	pass

func _loadEndBattle():
	# Fire local event
	# fire global event
	pass

# UI Events controlled by this script
func _input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		cards.ActionCard.hide()
		cards.ActionsContainer.show()

		eventBus.emit("GeneralCancel") 

func _onActionButtonClicked( action : Ability ):
	cards.ActionsContainer.hide()
	cards.ActionCard.loadData( action )
	cards.ActionCard.show()

	_resolveAction( action )

func _onStanceButtonClicked( stance : Ability ):
	print( stance.shortName )

# Helper methods
func _validateAlive( someCrew ):
	var deadCount = 0
	for crewman in someCrew:
		if( crewman.isDead() == true ):
			deadCount = deadCount + 1
	
	return deadCount >= someCrew.size()