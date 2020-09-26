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
	# TODO - add a stance card
	# TODO - add an instant card
	"LeftHover"		: get_node("BottomControls/Selection/LeftHover"),
	"LeftDetail" 	: get_node("BottomControls/Selection/LeftDetail"),

	"AllActionCard"	: get_node("BottomControls/TurnData/AllActionCard"),
	"EnemyActionCard"	: get_node("BottomControls/TurnData/EnemyActionCard"),
	"ActionCard"		: get_node("BottomControls/TurnData/ActionCard"),

	"RightDetail" 	: get_node("BottomControls/TargetData/RightDetail"),
	"RightHover"	: get_node("BottomControls/TargetData/RightHover")
}

onready var nodes = {
	"TurnLabel" 		: null,
	"ActionStatus"		: get_node("Header/UncontainedUI/CanvasLayer/ActionStatus")
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

	cards.LeftHover.setupScene( eventBus, null )
	cards.LeftDetail.setupScene( eventBus , null )

	cards.RightHover.setupScene( eventBus , null )
	cards.RightDetail.setupScene( eventBus , null )

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
	
	for trackerIcon in bases.PostTurnTrackerBase.get_children():
		trackerIcon.queue_free()

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

	cards.AllActionCard.loadData( currentTurnActor )
	cards.LeftDetail.loadData( currentTurnActor )

# Action resolution & Targeting
func _startAbility( ability : Ability ):
	eventBus.emit( "ActionStarted" , [ ability ])
	selectedAbility = ability
	nodes.ActionStatus.setStatus( ability.getFullName() )

	print("_startAbility : ")
	print( ability.targetType )

	# TODO - currently only permits 1 selection, should allow for multiple selections
	var validTargets = ability.getValidTargets()
	print(validTargets)
	if( ability.targetType == "ALLY_UNIT" or ability.targetType == "SELF" ):
		eventBus.emit("TargetingBattler" , [ validTargets , currentTurnActor.isPlayer ] )
	elif( ability.targetType == "ALLY_FLOOR" ):
		eventBus.emit("TargetingTile" , [ validTargets, currentTurnActor.isPlayer ] )
	elif( ability.targetType == "ENEMY_FLOOR" ): # Here we send the opposite of player. So true if it's NOT a player, and false if it is.
		eventBus.emit("TargetingTile" , [ validTargets , !currentTurnActor.isPlayer ] )
	elif( ability.targetType == "ENEMY_UNIT" ):
		print("I'm emmitting stuff")
		eventBus.emit("TargetingBattler" , [ validTargets , !currentTurnActor.isPlayer ] )

	eventBus.emit( "TargetingBegin" , [ ability ] )


func _onTargetingSelected( myX , myY , targetIsPlayer ):
	if( bases.BattleMap.isUnitOnTile( myX, myY ) ):
		cards.RightDetail.loadData( bases.BattleMap.getUnitFromTile( myX , myY ) )
	else:
		cards.RightDetail.loadData()
	
	_resolveAbility( myX , myY , targetIsPlayer )

# All targeting is done, now we resolve the ability in question
func _resolveAbility( myX , myY , targetIsPlayer ):
	# eventBus.emit( "ActionEnd" , [ action ] )
	var battlerMatrix = bases.BattleMap.getTargetsFromLocation( myX , myY , selectedAbility , targetIsPlayer)
	var arrayOfEffects = selectedAbility.rollEffectRolls()

	print("_resolveAbility : ")
	print(arrayOfEffects)

	for x in range(0 , battlerMatrix.size() ):
		for y in range(0, battlerMatrix[x].size() ):
			
			if( !battlerMatrix[x][y] ):
				continue

			for effect in arrayOfEffects:
				print( effect.displayEffect() )
				var hitRoll = effect.toHitRolls.pop_front()
				var effectRoll = effect.resultRolls.pop_front()
			
				if( effect.effectType == effect.EFFECT_TYPES.DAMAGE ):
					_resolveDamageEffect( battlerMatrix[x][y] , hitRoll , effectRoll )
				elif( effect.effectType == effect.EFFECT_TYPES.HEALING  ):
					_resolveHealingEffect( battlerMatrix[x][y] , hitRoll, effectRoll )

	yield( get_tree().create_timer( 2.5 ), "timeout" ) # Just waiting for animation to finish. TODO - do this better.
	nodes.ActionStatus.setStatus()

	_crewmanTurnEnd()

func _resolveDamageEffect( battler , hitRoll, dmgRoll ):
	if( hitRoll >= 100 ):
		battler.setState( Battler.STATE.DAMAGE , [ dmgRoll ] )
	else:
		battler.setState( Battler.STATE.MISS , [ hitRoll ] )

func _resolveHealingEffect( battler, hitRoll, healRoll ):
	print( battler, hitRoll , healRoll )
	if( hitRoll >= 100 ):
		battler.setState( Battler.STATE.HEALING , [ healRoll ] )
	else:
		battler.setState( Battler.STATE.MISS , [ hitRoll ] )

func _crewmanTurnEnd():
	cards.LeftDetail.loadData()
	cards.RightDetail.loadData()
	cards.ActionCard.loadData()
	cards.AllActionCard.loadData()

	eventBus.emit( "CrewmanTurnEnd" , [ currentTurnActor ] )
	eventBus.emit( "TurnEnd" , [ currentTurnActor ] )

func _enemyStartTurn ( crewman : Crew ):
	eventBus.emit("EnemyTurnStart" , [ crewman ] )
	
	cards.AllActionCard.loadData()
	cards.RightDetail.loadData( crewman )

	nodes.ActionStatus.setStatus( "Enemy: " + crewman.getFullName() )
	# TODO - Write some AI!
	# Enemy selects an Action
	# Enemy picks a target
	# _resolveAbility
	yield( get_tree().create_timer( 3.0 ), "timeout" ) # Do animation for the thing
	nodes.ActionStatus.setStatus()

	_enemyTurnEnd( crewman )

func _enemyTurnEnd( crewman ):
	cards.RightDetail.loadData()
	cards.ActionCard.loadData()

	eventBus.emit( "EnemyTurnEnd" , [crewman] )
	eventBus.emit( "TurnEnd" , [ crewman ] )

func _onTurnEnd( crewman : Crew ):
	_nextTurn()

func _onGeneralCancel():
	if( selectedAbility ):
		selectedAbility = null
		nodes.ActionStatus.setStatus()

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
		cards.ActionCard.loadData()
		eventBus.emit("GeneralCancel") 

func _onActionButtonClicked( action : Ability ):
	cards.ActionCard.loadData( action )

	_startAbility( action )

func _onStanceButtonClicked( stance : Ability ):
	print( stance.shortName )

# Helper methods
func _validateAlive( someCrew ):
	var deadCount = 0
	for crewman in someCrew:
		if( crewman.isDead() == true ):
			deadCount = deadCount + 1
	
	return deadCount >= someCrew.size()
