extends Control

onready var playerUnits = [
	[get_node("Player/Unit_0_0") , get_node("Player/Unit_0_1") , get_node("Player/Unit_0_2") ] , 
	[get_node("Player/Unit_1_0") , get_node("Player/Unit_1_1") , get_node("Player/Unit_1_2") ] , 
	[get_node("Player/Unit_2_0") , get_node("Player/Unit_2_1") , get_node("Player/Unit_2_2") ]
]

onready var playerField = [
	[ get_node("Player/Floor_0_0"), get_node("Player/Floor_0_1"), get_node("Player/Floor_0_2") ] ,
	[ get_node("Player/Floor_1_0"), get_node("Player/Floor_1_1"), get_node("Player/Floor_1_2") ], 
	[ get_node("Player/Floor_2_0"), get_node("Player/Floor_2_1"), get_node("Player/Floor_2_2") ], 
]

onready var enemyUnits = [
	[get_node("Enemy/Unit_0_0") , get_node("Enemy/Unit_0_1") , get_node("Enemy/Unit_0_2") ] , 
	[get_node("Enemy/Unit_1_0") , get_node("Enemy/Unit_1_1") , get_node("Enemy/Unit_1_2") ] , 
	[get_node("Enemy/Unit_2_0") , get_node("Enemy/Unit_2_1") , get_node("Enemy/Unit_2_2") ]
]

onready var enemyField = [
	[ get_node("Enemy/Floor_0_0"), get_node("Enemy/Floor_0_1"), get_node("Enemy/Floor_0_2") ] ,
	[ get_node("Enemy/Floor_1_0"), get_node("Enemy/Floor_1_1"), get_node("Enemy/Floor_1_2") ], 
	[ get_node("Enemy/Floor_2_0"), get_node("Enemy/Floor_2_1"), get_node("Enemy/Floor_2_2") ], 
]

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
	eventBus.register( "GeneralCancel"  , self , "_onGeneralCancel")

func _ready():
	for x in range( 0 , playerField.size() ):
		for y in range( 0 , playerField[x].size() ):
			playerField[x][y].setupScene( eventBus )

	for x in range( 0 , enemyField.size() ):
		for y in range( 0 , enemyField[x].size() ):
			enemyField[x][y].setupScene( eventBus )

	for x in range( 0 , playerUnits.size() ):
		for y in range( 0 , playerUnits[x].size() ):
			playerUnits[x][y].setupScene( eventBus )

	for x in range( 0 , enemyUnits.size() ):
		for y in range( 0 , enemyUnits[x].size() ):
			enemyUnits[x][y].setupScene( eventBus )

	_setupBattleOrder()
	_nextPass()

func _onGeneralCancel():
	pass

func _onTargetingBegin( ability : Ability , crewman : Crew ):
	print( ability.fullName )
	print( crewman.getFullName() )
	
	var validTargets = ability.getValidTargets()
	if( ability.targetType == "ALLY_UNIT" || ability.targetType == "SELF" ):
		eventBus.emit("TargetingBattler" , [ validTargets , crewman.isPlayer ] )
	elif( ability.targetType == "ALLY_FLOOR" ):
		eventBus.emit("TargetingTile" , [ validTargets, crewman.isPlayer ] )
	elif( ability.targetType == "ENEMY_FLOOR" ): # Here we send the opposite of player. So true if it's NOT a player, and false if it is.
		eventBus.emit("TargetingTile" , [ validTargets , !crewman.isPlayer ])
	elif( ability.targetType == "ENEMY_UNIT" ):
		eventBus.emit("TargetingBattler" , [ validTargets , !crewman.isPlayer ])

func _setupBattleOrder():
	# TODO - Create a pop up to allow this to be changed and saved before battle. For now , hardcode!
	playerUnits[1][0].loadData( playerCrew[0] )
	playerUnits[1][1].loadData( playerCrew[1] )
	playerUnits[1][2].loadData( playerCrew[2] )
	playerUnits[2][1].loadData( playerCrew[3] )
	playerUnits[0][1].loadData( playerCrew[4] )

	enemyUnits[1][0].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyUnits[1][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyUnits[1][2].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyUnits[2][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )
	enemyUnits[0][1].loadData( CrewFactory.generateNewCrewWithEquipment( 30 , 30 , CrewFactory.MAKE_ENEMY ) )

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

	if( _validateAlive( enemyCrew ) ):
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