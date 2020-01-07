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
	"NOT_ACTIVE":{ },
	"HOVER"		:{ },
	"ACTIVE"		:{ }
}
var myTurnState = TURN.NOT_ACTIVE
var prevState = null

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
	# Figure out a way to show the current turn in a nice way. May need to move turns over to sprite, so I can tweak with scale

func set_unit_state( stateName : String ):
	myUnitState = UNIT[stateName]
	set_self_modulate( UNIT_STATE[myUnitState].Color )

func _ready():
	if( eventBus ):
		loadEvents()

	if( crewman ):
		loadData()

func getActor():
	return self.crewman

func loadEvents():
	if( crewman.isPlayer ): 
		eventBus.register( "CrewmanDeath" , self , "_onDeath" )
	else:
		eventBus.register( "EnemyDeath" , self, "_onDeath" )

func _onDeath( deadCrewman : Crew ):
	if( crewman.getId() == deadCrewman.getId() ):
		queue_free()

func loadData():
	nodes.Crewman.set_texture( load(crewman.smallTexturePath) )
	nodes.Init.set_text( str(init) )

func _onMouseEnter():
	pass

func _onMouseExit():
	pass