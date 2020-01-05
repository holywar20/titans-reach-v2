extends TextureRect

const STATE = { "TARGETING" : "TARGETING" , "TARGETED" : "TARGETED" , "HIGHLIGHT" : "HIGHLIGHT" , "CLEAR" : "CLEAR" , "LOCK" : "LOCK" }
const STATE_DATA = {
	"TARGETING" : { "Color" : Color( .6, .6, .3, .4 ) , "IsInteractable" : true  },
	"TARGETED"  : { "Color" : Color( .6, .3, .3, .4 ) , "IsInteractable" : true  },
	"HIGHLIGHT" : { "Color" : Color( .3, .6, .3,	.7 ) , "IsInteractable" : true  },
	"LOCK"		: { "Color" : Color( 1 , 1 ,	1, 0 ) , "IsInteractable" : false },
	"CLEAR" 		: { "Color" : Color( 1 , 1 ,	1, 0 ) , "IsInteractable" : true  }
}
var myState = STATE.CLEAR
var prevState = null

var eventBus
var occupant

export(bool) var isPlayer = false
export(int) var myX = 0
export(int) var myY = 0

func setupScene( eBus : EventBus ):
	eventBus = eBus
	setState( STATE.CLEAR )
	loadEvents()

func updateOccupant( crewman ):
	occupant = crewman

func loadEvents():
	# Targeting events
	eventBus.register("TargetingTile" , self , "_onTargetingTile")
	eventBus.register("TargetingBattler" , self, "_onTargetingBattler")
	
	# Clean up events
	eventBus.register("GeneralCancel"	, self, "_onGeneralCancel" )
	eventBus.register("TurnEnd" , self , "_onTurnEnd" )

func setState( stateName : String ):
	myState = STATE[stateName]
	set_self_modulate( STATE_DATA[myState].Color )

	if( STATE_DATA[myState].IsInteractable ):
		set_mouse_filter( MOUSE_FILTER_PASS )
	else:
		set_mouse_filter( MOUSE_FILTER_IGNORE )

func _onTargetingTile( validTargetMatrix , targetsPlayer ):
	if( isPlayer == targetsPlayer && validTargetMatrix[myX][myY] ):
		setState( STATE.TARGETING )
	else:
		setState( STATE.LOCK )

func _onGeneralCancel():
	if( myState != STATE.CLEAR ):
		setState( STATE.CLEAR )

func _onTargetingBattler( validTargetMatrix , targetsPlayer ):
	setState( STATE.LOCK )

func _onTurnEnd( crewman : Crew ):
	# TODO - maybe do a match so it knows to roll some kind of targeting animation?
	setState( STATE.CLEAR )

func _onMouseEntered():
	if( myState == STATE.TARGETING ):
		prevState = myState
		setState( STATE.HIGHLIGHT )

func _onMouseExited():
	if( prevState ):
		setState( prevState )
		prevState = null

func _gui_input( input ):
	if( myState == STATE.HIGHLIGHT && input.is_action_pressed( "GUI_SELECT" ) ):
		eventBus.emit("TargetingSelected" , [ myX , myY , occupant ] )

func _ready():
	pass # Replace with function body.