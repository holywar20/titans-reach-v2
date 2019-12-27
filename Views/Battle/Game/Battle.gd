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
var playerCrew
var enemyCrew

func setupScene( eBus : EventBus , playerUnits , enemyUnits  ):
	eventBus = eBus
	playerCrew = playerUnits
	enemyCrew = enemyUnits

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

	_setupBattleOrder( playerCrew , enemyCrew )

func _onGeneralCancel():
	pass

func _setupBattleOrder( playerCrew , enemyCrew = null ):
	# TODO - Create a pop up to allow this to be changed and saved before battle. For now , hardcode!
	playerUnits[1][0].loadData( playerCrew[0] )
	playerUnits[1][1].loadData( playerCrew[1] )
	playerUnits[1][2].loadData( playerCrew[2] )
	playerUnits[2][1].loadData( playerCrew[3] )
	playerUnits[0][1].loadData( playerCrew[4] )

	# Randomly generate enemy Unit battle order
	enemyUnits[1][0].loadData( enemyCrew[0] )
	enemyUnits[1][1].loadData( enemyCrew[1] )
	enemyUnits[1][2].loadData( enemyCrew[2] )
	enemyUnits[2][1].loadData( enemyCrew[3] )
	enemyUnits[0][1].loadData( enemyCrew[4] )