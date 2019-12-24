extends TextureRect

const STATE = { "TARGETING" : "TARGETING" , "TARGETED" : "TARGETED" , "HIGHLIGHT" : "HIGHLIGHT" , "CLEAR" : "CLEAR" }
const STATE_DATA = {
	"TARGETING" : { "Color" : Color( .6 , .6  , .3 , .4 ) },
	"TARGETED"  : { "Color" : Color( .6 , .3 , .3 , .4 ) },
	"HIGHLIGHT" : { "Color" : Color( .6 , .3 , .3 , .7 ) },
	"CLEAR" 		: { "Color" : Color( 1 , 1  ,  1 , 0 ) }
}
var myState = STATE.CLEAR
var prevState = null

var eventBus
var occupant
export(int) var myX = 0
export(int) var myY = 0

func setUpScene( eBus : EventBus ):
	eventBus = eBus 

func updateOccupant( crewman ):
	occupant = crewman

func setState( stateName : String ):
	myState = STATE[stateName]
	set_self_modulate( STATE_DATA[stateName].Color )

func _onMouseEntered():
	# print( "mouseEntered" , " " , myX , " ", myY)
	if( myState == STATE.TARGETING ):
		prevState = myState
		setState( STATE.HIGHLIGHT )

func _onMouseExited():
	# print( "mouse exited" , " " , myX , " ", myY)
	if( prevState ):
		setState( prevState )
		prevState = null

func _gui_input( input ):
	if( myState == STATE.HIGHLIGHT && input.is_action_pressed( "GUI_SELECT" ) ):
		print("something happened")

func _ready():
	pass # Replace with function body.