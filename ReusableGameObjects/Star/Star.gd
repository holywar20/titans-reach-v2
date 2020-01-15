extends Node2D

class_name Star

onready var nodes = {
	'sprite'		: get_node("Area2D/Sprite"),
	'nameLabel'	: get_node("Label")
}

const ORBIT_COUNT = 8 # should result in 9 orbits, due to index of zero being first planet.
const ORBIT_SIZE_FACTOR = 1000
const ORBIT_LINE_WIDTH = 5
const ORBIT_LINE_SEGMENTS = 128
const CONNECTION_COLOR = Color( .2, .6 , .2, .5)

var firstName = "X"
var lastName = "X"

# Class data
var starSeed = 0
var classification = "M"
var className = "Red Dwarf"
var boilLine = 0
var freezeLine = 0
var radius = 0
var temp = 0
var mass = 0
var orbitSize = 0
var color = Color( 0 , 0 ,0 , 0 )
var description = ""
var hoverText = "Star"

# IMG Data
var smallTexturePath = "" 
var iconTexturePath = ""
var fullTexturePath = ""

# Star Metadata
var orbitArray = [ false , false , false, false, false, false, false, false, false, false ] # NOTE 9 valid orbits.
var connectionArray = []
var chanceOfPlanetPerOrbit = 100

var eventBus = null

enum TEXTURE{ FULL, SMALL , ICON }

func _ready():
	nodes.nameLabel.set_text( getName() )
	nodes.sprite.set_texture( load( fullTexturePath ) ) # DO we need an override for this?
	nodes.sprite.set_self_modulate( color )

func setEvents( eBus : EventBus ):
	eventBus = eBus

func setName( fName : String , lName: String ):
	firstName = fName
	lastName = lName

func getName():
	return firstName + " " + lastName

func getColor():
	return color

func getSeed():
	return starSeed

func setOrbitState( orbit : int , state : bool ):
	orbitArray[orbit] = state 

func getOrbitalDistance( orbit: int ):
	return ORBIT_SIZE_FACTOR + ( orbitSize * orbit * ORBIT_SIZE_FACTOR )

func _draw():
	for orbit in range( 0, orbitArray.size() ):
		var orbitColor = Color( .2, .4, .2 , float(orbit) / 20 + .5  )
		
		if( orbitArray[orbit] ):
			var position = get_position()
			var orbitDistance = getOrbitalDistance( orbit )
			Common.drawCircle( position, orbitDistance , orbitColor , self , ORBIT_LINE_WIDTH , ORBIT_LINE_SEGMENTS )
	
	for connection in range( 0 , connectionArray.size() ):
		var radians = deg2rad( connectionArray[connection].degrees )
		var targetVector = Vector2( cos(radians) * 100000 , sin(radians) * 100000 ) 
		draw_line( Vector2(0, 0) , targetVector, CONNECTION_COLOR , ORBIT_LINE_WIDTH )

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( event.is_action_pressed( "GUI_SELECT" ) ):
		eventBus.emit( "StarClickedStart" , [self] )