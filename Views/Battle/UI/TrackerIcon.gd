extends Panel

onready var nodes = {
	"Crewman"	: get_node("CrewmanPicture"),
	"Init"		: get_node("InitValue")
}

const UNIT = { "PLAYER" : "PLAYER" , "ENEMY" : "ENEMY" }
const UNIT_STATE = {
	"PLAYER"		: { "Color" : Color( 1 , 1 , 1 ,1  ) },
	"ENEMY"		: { "Color" : Color( .8 , .4 ,.4 , 1) }
}
var myUnitState = UNIT.PLAYER

const TURN = { "NOT_ACTIVE": "NOT_ACTIVE" , "HOVER" : "HOVER", "ACTIVE" : "ACTIVE" }
const TURN_STATE = {
	"NOT_ACTIVE"	: { "Scale" : 1 	, "HighlightColor" : null }, 
	"HOVER"			: { "Scale" : 1.2 , "HighlightColor" : null }, 
	"ACTIVE"			: { "Scale" : 1.4 , "HighlightColor" : Color( .4 , .4 , .8 , 1 ) }, 
}
var myTurnState = TURN.NOT_ACTIVE

var eventBus = null
var crewman = null
var init = 0

func setupScene( eBus : EventBus , newCrewman : Crew  , newInit : int ):
	crewman = newCrewman
	eventBus = eBus
	init = newInit

	if( crewman.isPlayer ):
		set_unit_state( UNIT.PLAYER )
	else:
		set_unit_state( UNIT.ENEMY )

func set_turn_state( stateName : String ):
	myTurnState = TURN[stateName]
	set_scale( TURN_STATE[myTurnState].Color )

func set_unit_state( stateName : String ):
	myUnitState = UNIT[stateName]
	set_self_modulate( UNIT_STATE[myUnitState].Color )

func _ready():
	if( eventBus ):
		loadEvents()

	if( crewman ):
		loadData()

func loadEvents():
	pass 

func loadData():
	nodes.Crewman.set_texture( load(crewman.smallTexturePath) )
	nodes.Init.set_text( str(init) )