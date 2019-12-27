extends Control

onready var trackerScene = load("res://Views/Battle/UI/TrackerIcon.tscn")

var events = [
	"NextPass" , "NextTurn", "InitiativeRolled", "ThisTurnEnded" ,
	
	"CrewmanTurnStart" , "CrewmanTurnEnd" , 
	"EnemyTurnStart", "EnemyTurnEnd",

	# Events dealing with action processing
	"ActionStarted" , 
	"TargetingBegin", 
	"TargetingTile" , "TargetingBattler" ,
	"TargetingEnd" , 
	"ActionEnded" ,

	# UI events
	"ActionButtonClicked" , "StanceButtonClicked", "GeneralCancel",
	
	# Triggered events
	"NoMoreBattlers", "EndOfGame" , "EndOfBattle" , "CrewmanDeath" , "EnemyDeath"
]

onready var bases = {
	"PreTurnTrackerBase" : get_node("TrackerContainer/BeforeTurn") ,
	"PostTurnTrackerBase" : get_node("TrackerContainer/AfterTurn") ,
	"InstantBase"		: get_node("Middle/VBox/InstantsContainer/VBox/BattleInstants")
}

onready var cards = {
	"AllActionCard"			: get_node("BottomControls/TurnData/VBox/HBox/AllActionCard"),
	"StanceCard"				: get_node("BottomControls/TurnData/VBox/HBox/StanceCard"),
	"LeftCrewDetailCard" 	: get_node("BottomControls/Selection/LeftCrewDetail"),
	"RightCrewDetailCard" 	: get_node("BottomControls/TargetData/RightCrewDetail"),
	"ActionCard"				: get_node("BottomControls/TargetData/ActionCard")
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
var initiativeArray = []
var currentTurnActor = null
var currentTurnCrewman = null
var selectedAbility = null

# Potential config options should be declared here.=

func setupScene( eBus : EventBus , crew , enemy , config ):
	eventBus = eBus
	playerCrew = crew
	enemyCrew = enemy
	
	# TODO : handling for config options

	loadEvents()

func _ready():
	cards.StanceCard.setupScene( eventBus , null )
	cards.AllActionCard.setupScene( eventBus , null )
	cards.LeftCrewDetailCard.setupScene( eventBus , null )
	cards.RightCrewDetailCard.setupScene( eventBus , null )

	_nextPass()

func loadEvents():
	eventBus.addEvents( events )

	eventBus.register("NextPass" , self ,  "_nextPass")
	
	# Events we would receive from UI elements that are not buttons.
	eventBus.register( "TargetingEnd"	, self , "_onTargetingEnd" )

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
	
	initiativeArray = Common.bubbleSortArrayByDictKey( packedArray , "Init" )
	for tuple in initiativeArray:
		var newTrackerIcon = trackerScene.instance()
		newTrackerIcon.setupScene( eventBus, tuple.Actor, tuple.Init )
		bases.PreTurnTrackerBase.add_child( newTrackerIcon )
	
	_nextTurn()

func _nextTurn():
	if( _validateAlive( playerCrew ) ):
		_loadEndGame()
		#return null

	if( _validateAlive( enemyCrew ) ):
		_loadEndBattle()
		#return null
	
	if( initiativeArray.size() == 0 ):
		eventBus.emit( "NextPass" , [] )

	var tuple = initiativeArray.pop_back()
	currentTurnActor = tuple.Actor

	if( currentTurnActor.isPlayer ):
		crewmanStartTurn( currentTurnActor )
	else:
		enemyStartTurn( currentTurnActor )

func crewmanStartTurn( crewman : Crew ):
	eventBus.emit("CrewmanStartTurn" , [ crewman ] )
	loadData( crewman )

func crewmanTurnEnd( crewman : Crew ):
	eventBus.emit("CrewmanTurnEnd" , [crewman] )
	eventBus.emit( "ThisTurnEnded" )

func enemyStartTurn ( crewman : Crew ):
	eventBus.emit("EnemyStartTurn" , [ crewman ])
	loadData( crewman )
	
	nodes.ActionLabel.set_text( "Enemy" )
	nodes.ActionStatus.show()

	yield(get_tree().create_timer(3.0), "timeout")
	
	nodes.ActionStatus.hide()
	nodes.ActionLabel.set_text("")

	enemyTurnEnded( crewman )

func enemyTurnEnded( crewman ):
	eventBus.emit( "EnemyTurnEnded" , [crewman] )
	eventBus.emit( "ThisTurnEnded" )

# Action resolution & Targeting
func _resolveAction( action : Ability ):
	eventBus.emit( "ActionStarted" , [ action ])
	selectedAbility = action
	nodes.ActionLabel.set_text( action.fullName )
	nodes.ActionStatus.show()

	targetingBegin( selectedAbility , currentTurnCrewman )

func targetingBegin( ability : Ability , crewman : Crew ):
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

func _targetEnd( myX , myY ):
	print("Targeting something!")

func _actionEnded( action : Ability ):
	eventBus.emit( "ActionEnd" , [ action ] )

	_resolvePassiveEffects()
	_resolveDamageEffects()
	_resolveMovement()
	_resolveStatusEffects()
	
	# TODO : Validate if anyone is alive or not 

	crewmanTurnEnd( currentTurnCrewman )

func _resolveMovement():
	# Fire an event to inform battleOrder to update
	pass

func _resolveStatusEffects():
	pass 

func _resolvePassiveEffects():
	pass

func _resolveDamageEffects():
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
		currentTurnCrewman = crewman
		nodes.TurnLabel.set_text( "Turn : " + crewman.getFullName() )

		

		cards.StanceCard.loadData( currentTurnCrewman )
		cards.AllActionCard.loadData( currentTurnCrewman )

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
		eventBus.emit("GeneralCancel") 

func _onActionButtonClicked( action : Ability ):
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