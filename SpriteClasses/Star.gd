extends Sprite

class_name Star

const ORBIT_LINE_WIDTH = 5
const ORBIT_LINE_SEGMENTS = 128
const CONNECTION_COLOR = Color( .2, .4 , .2, .5)

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

# IMG Data
var smallTexturePath = "" 
var iconTexturePath = ""
var fullTexturePath = ""

# Star Metadata
var orbitArray = []
var connectionArray = []

func _ready():
	pass

func _draw():
	for orbit in range( 1, self.orbitArray.size() ):
		var orbitColor = Color( .2, .4, .2 , float(orbit) / 20 + .5  )
		
		if( orbitArray[orbit] ):
			var position = self.get_position()
			Common.drawCircle( position, orbitArray[orbit], orbitColor , self , self.ORBIT_LINE_WIDTH , self.ORBIT_LINE_SEGMENTS )
	
	for connection in range( 0 , self.connectionArray.size() ):
		var radians = deg2rad( self.connectionArray[connection].degrees )
		var targetVector = Vector2( cos(radians) * 100000 , sin(radians) * 100000 ) 
		draw_line( Vector2(0, 0) , targetVector, self.CONNECTION_COLOR , self.ORBIT_LINE_WIDTH )

func init( inputStarData, connections, decorators ):
	var starData = inputStarData
	
	#self.connectionArray = connections
	#self.decorators = decorators
	#self.get_node( self.NAME_LABEL ).set_text( decorators.fname + " " + decorators.lname + "( class " + starData['Class'] + " )")
	
	#$Sprite.set_scale( Vector2( starData['Radius'], starData['Radius']) )
	#$Sprite.set_texture( load(starData['TexturePath']) )
	#self.set_name( starData['Class'] )

func getOrbitalDistance():
	pass

func _onAreaInputEvent( viewport, event, shape_idx ):
	if( Input.is_mouse_button_pressed( BUTTON_LEFT ) ):
		pass # TODO - link to event bus.
	