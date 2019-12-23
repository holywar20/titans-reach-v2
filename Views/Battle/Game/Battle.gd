extends Node2D

onready var playerField = [
	[ get_node("BG/0_0"), get_node("BG/0_1"), get_node("BG/0_2") ] ,
	[ get_node("BG/1_0"), get_node("BG/1_1"), get_node("BG/1_2") ], 
	[ get_node("BG/2_0"), get_node("BG/2_1"), get_node("BG/2_2") ], 
]

onready var enemyField = [
	[ get_node("EBG/0_0"), get_node("EBG/0_1"), get_node("EBG/0_2") ] ,
	[ get_node("EBG/1_0"), get_node("EBG/1_1"), get_node("EBG/1_2") ], 
	[ get_node("EBG/2_0"), get_node("EBG/2_1"), get_node("EBG/2_2") ], 
]

const ENEMYBATTLERS = "EnemyBattlers"
const PLAYERBATTLERS = "PlayerBattlers"

var eventBus
var playerCrew = []
var enemyCrew = []
var battleConfig # No need not to keep as a ref, though we should load config as other variables

# Battle configuration variables

# STATE
var initiativeArray = []
var currentTurnActor = null

func setupScene( eBus : EventBus , crew , battleConfigDictionary ):
	eventBus = eBus
	playerCrew = crew
	battleConfig = battleConfigDictionary 

	eventBus.register( "TargetingBegin" , self , "_onTargetingBegin" )

func loadData():
	for row in playerField:
		for player in row:
			playerField[row][player].setupScene( eventBus )

	for row in enemyField:
		for enemy in row:
			enemyField[row][enemy].setupScene( eventBus )

func _ready():
	_setupBattleOrder()
	_nextPass()

func _onTargetingBegin( ability : Ability , crewman : Crew):
	print( ability.fullName )
	print( crewman.getFullName() )
	# TODO find a way to do this for multiple effects that might require multiple targets

	var doesTargetEnemy = ability.doesTargetEnemyUnits()
	var validTargets = ability.getValidTargets()

	print( doesTargetEnemy )
	print( validTargets )
	# crew.isPlayer
	# ability.targetType

func _setupBattleOrder():
	# TODO - Create a pop up to allow this to be changed and saved before battle. For now , hardcode!
	playerField[1][0].loadData( playerCrew[0] )
	playerField[1][1].loadData( playerCrew[1] )
	playerField[1][2].loadData( playerCrew[2] )
	playerField[2][1].loadData( playerCrew[3] )
	playerField[0][1].loadData( playerCrew[4] )

	enemyField[1][0].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyField[1][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyField[1][2].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyField[2][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyField[0][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )

func _nextPass():
	# Do any special end of pass checks ( Special conditions, etc )
	_rollInitiative()
	_nextTurn()

func _rollInitiative():
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

	eventBus.emit("InitiativeRolled" , [ initiativeArray ] )

func _nextTurn():
	if( _validateAlive( playerCrew ) ):
		_loadEndGame()
		#return null

	if( _validateAlive( enemyCrew) ):
		_loadEndBattle()
		#return null
	
	if( initiativeArray.size() == 0 ):
		eventBus.emit( "NextPass" , [] )

	var tuple = initiativeArray.pop_back()
	currentTurnActor = tuple.Actor

	if( currentTurnActor.isPlayer ):
		eventBus.emit( "CrewmanTurnStart" , [ currentTurnActor ] )
	else:
		eventBus.emit( "EnemyTurnStart" , [ currentTurnActor ])

func _validateAlive( someCrew ):
	var deadCount = 0
	for crewman in someCrew:
		if( crewman.isDead() == true ):
			deadCount = deadCount + 1
	
	return deadCount >= someCrew.size()

func _loadEndGame():
	# Fire local event
	pass

func _loadEndBattle():
	# Fire local event
	# fire global event
	pass