extends Control

onready var playerUnits = [
	[get_node("Player/Unit_0_0") , get_node("Player/Unit_0_1") , get_node("Player/Unit_0_2") ],
	[get_node("Player/Unit_1_0") , get_node("Player/Unit_1_1") , get_node("Player/Unit_1_2") ],
	[get_node("Player/Unit_2_0") , get_node("Player/Unit_2_1") , get_node("Player/Unit_2_2") ]
]

onready var playerField = [
	[ get_node("Player/Floor_0_0"), get_node("Player/Floor_0_1"), get_node("Player/Floor_0_2") ],
	[ get_node("Player/Floor_1_0"), get_node("Player/Floor_1_1"), get_node("Player/Floor_1_2") ],
	[ get_node("Player/Floor_2_0"), get_node("Player/Floor_2_1"), get_node("Player/Floor_2_2") ]
]

onready var enemyUnits = [
	[get_node("Enemy/Unit_0_0") , get_node("Enemy/Unit_0_1") , get_node("Enemy/Unit_0_2") ],
	[get_node("Enemy/Unit_1_0") , get_node("Enemy/Unit_1_1") , get_node("Enemy/Unit_1_2") ],
	[get_node("Enemy/Unit_2_0") , get_node("Enemy/Unit_2_1") , get_node("Enemy/Unit_2_2") ]
]

onready var enemyField = [
	[ get_node("Enemy/Floor_0_0"), get_node("Enemy/Floor_0_1"), get_node("Enemy/Floor_0_2") ],
	[ get_node("Enemy/Floor_1_0"), get_node("Enemy/Floor_1_1"), get_node("Enemy/Floor_1_2") ],
	[ get_node("Enemy/Floor_2_0"), get_node("Enemy/Floor_2_1"), get_node("Enemy/Floor_2_2") ]
]

var eventBus
var playerCrew
var enemyCrew

const EMPTY_MATRIX = [ [ 0, 0, 0] , [ 0, 0, 0] , [ 0, 0, 0] ]
const TARGET_AREAS = {
	"SINGLE" 	: [ [ 0 , 0 , 0 ] , [ 0 , 1 , 0 ] , [ 0 , 0 , 0 ] ],
	"ROW" 		: [ [ 0 , 0 , 0 ] , [ 1 , 1 , 1 ] , [ 0 , 0 , 0 ] ],
	"ROW_DECAY"	: [ [ 0 , 0 , 0 ] , [ 0 , 1 , 1 ] , [ 0 , 0 , 0 ] ],
	"COLUMN" 	: [ [ 0 , 1 , 0 ] , [ 0 , 1 , 0 ] , [ 0 , 1 , 0 ] ],
	"CROSS" 		: [ [ 0 , 1 , 0 ] , [ 1 , 1 , 1 ] , [ 0 , 1 , 0 ] ],
	"ALL" 		: [ [ 1 , 1 , 1 ] , [ 1 , 1 , 1 ] , [ 1 , 1 , 1 ] ]
}

func setupScene( eBus : EventBus , player , enemy ):
	eventBus = eBus
	playerCrew = player
	enemyCrew = enemy

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
	eventBus.register( "GeneralCancel"  , self , "_onGeneralCancel")

func _ready():
	pass

func _onGeneralCancel():
	pass

# Finds a specific crewman. If not found, return null
func getBattlerCrewPosition( crewman : Crew ):
	var myUnits = null
	if( crewman.isPlayer ):
		myUnits = playerUnits
	else:
		myUnits = enemyUnits

	var crewmanVector = null
	for x in range( 0 , myUnits.size() ):
		for y in range ( 0 , myUnits[x].size() ):
			if( !playerUnits[x][y] ):
				continue
			
			if( playerUnits[x][y].crewman == crewman ):
				crewmanVector = Vector2( x , y )
	
	return crewmanVector

func isUnitOnTile( myX, myY , isPlayer = false ):
	var targetField = null
	if( isPlayer ):
		targetField = playerUnits
	else:
		targetField = enemyUnits

	if( targetField[myX][myY].hasCrewman() ):
		return true
	else:
		return false

func getUnitFromTile( myX , myY , isPlayer = false ):
	var targetField = null
	if( isPlayer ):
		targetField = playerUnits
	else:
		targetField = enemyUnits

	if( targetField[myX][myY].hasCrewman() ):
		return targetField[myX][myY].getCrewman()
	else:
		return false

# figures out which things an ability will hit. Normally returns battlers from the map, but can get the crewman as an optional flag.
func getTargetsFromLocation( myX , myY , effect : Effect , isPlayer : bool , getCrewman = false ):
	
	var targetField = null
	if( isPlayer ):
		targetField = playerUnits
	else:
		targetField = enemyUnits

	var potentialValidTargets = effect.getOffsetMatrix( myX, myY )

	for x in potentialValidTargets.size():
		for y in potentialValidTargets[x].size():
			
			if( targetField[x][y].hasCrewman() && potentialValidTargets[x][y] ):
				if( getCrewman ):
					potentialValidTargets[x][y] = targetField[x][y].getCrewman()
				else:
					potentialValidTargets[x][y] = targetField[x][y]
			
			else:
				potentialValidTargets[x][y] = 0

	return potentialValidTargets

func resolveMoveSwap( pos : Vector2, pos2 : Vector2 , effect : Effect , isPlayer : bool ):
	# WORK
	# TODO - Allow a hook for animation

func resolveMovePush( pos : Vector2, pos2 : Vector2 , isPlayer: bool ):
	pass
	# TODO - Allow a hook for animiations

func resolveMovePull( pos: Vector2, pos2 : Vector2 , isPlayer : bool ):
	pass

func resolveMoveSetAny():
	pass

func resolveMoveScramble():
	pass

func _setupBattleOrder( pCrew , eCrew = null ):
	# TODO - Create a pop up to allow this to be changed and saved before battle. For now , hardcode!
	playerUnits[1][0].loadData( pCrew[0] )
	playerUnits[1][1].loadData( pCrew[1] )
	playerUnits[1][2].loadData( pCrew[2] )
	playerUnits[2][1].loadData( pCrew[3] )
	playerUnits[0][1].loadData( pCrew[4] )

	# TODO - Randomly generate enemy Unit battle order
	enemyUnits[0][1].loadData( eCrew[0] )
	enemyUnits[1][2].loadData( eCrew[1] )
	enemyUnits[2][2].loadData( eCrew[2] )
	enemyUnits[1][1].loadData( eCrew[3] )
	enemyUnits[0][2].loadData( eCrew[4] )
