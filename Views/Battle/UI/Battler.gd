extends Control

onready var barNodesStandard = {
	"Handle"		: get_node("Standard"),
	"HealthBar" : get_node("Standard/Health/Bar"),
	"MoraleBar" : get_node("Standard/Morale/Bar"),
	"HealthValue" : get_node( "Standard/Health/Bar/Value"),
	"MoraleValue" : get_node( "Standard/Morale/Bar/Value")
}

onready var barNodesReversed = {
	"Handle"		: get_node("Reversed"),
	"HealthBar" : get_node("Reversed/Health/Bar"),
	"MoraleBar" : get_node("Reversed/Morale/Bar"),
	"HealthValue" : get_node( "Reversed/Health/Bar/Value"),
	"MoraleValue" : get_node( "Reversed/Morale/Bar/Value")
}

var barNodes = null

const STATE = { "TARGETING" : "TARGETING" , "TARGETED" : "TARGETED" , "HIGHLIGHT" : "HIGHLIGHT" , "CLEAR" : "CLEAR" , "LOCK" : "LOCK" }
const STATE_DATA = {
	"TARGETING" : { "Color" : Color( .6 , .6  , .3 , 1 ) , "IsInteractable" : true },
	"TARGETED"  : { "Color" : Color( .6 , .3 , .3 , 1 ) , "IsInteractable" : false },
	"HIGHLIGHT" : { "Color" : Color( .3 , .6 , .3 , 1 ) , "IsInteractable" : true },
	"LOCK"		: { "Color" : Color( 1  , 1 , 1 ,  1 ) , "IsInteractable" : false },
	"CLEAR" 		: { "Color" : Color( 1 , 1  ,  1 , 1 )	, "IsInteractable" : true }
}
var myState = null
var prevState = null

var eventBus = null
var crewman = null

export(bool) var isPlayer = true
export(int) var myX = 0
export(int) var myY = 0

func setupScene( eBus : EventBus ):
	eventBus = eBus

	loadEvents()
	setState( STATE.CLEAR )

	if( is_inside_tree() ):
		loadData()
	
	if( isPlayer ):
		barNodesStandard.Handle.show()
		barNodes = barNodesStandard
	else:
		barNodesReversed.Handle.show()
		barNodes = barNodesReversed

func _ready():
	pass

func loadEvents():
	eventBus.register("TargetingTile" , self , "_onTargetingTile")
	eventBus.register("TargetingBattler" , self, "_onTargetingBattler")
	eventBus.register("GeneralCancel" , self, "_onGeneralCancel" )

func setState( stateName : String ):
	# print("setting state for battler , " , myX , " ",  myY , " " , stateName)
	myState = STATE[stateName]
	set_self_modulate( STATE_DATA[myState].Color )

	if( STATE_DATA[myState].IsInteractable ):
		set_mouse_filter( MOUSE_FILTER_PASS )
	else:
		set_mouse_filter( MOUSE_FILTER_IGNORE )

func loadData( newCrewman = null ):
	if( newCrewman ):
		crewman = newCrewman

	if( crewman ):
		var hp = crewman.getHPStatBlock()
		barNodes.HealthBar.set_max( hp.total )
		barNodes.HealthBar.set_value( hp.current )
		barNodes.HealthValue.set_text( crewman.getHitPointString() )
		
		var morale = crewman.getMoraleStatBlock()
		barNodes.MoraleBar.set_max( morale.total )
		barNodes.MoraleBar.set_value( morale.current )
		barNodes.MoraleValue.set_text( crewman.getMoraleString() )

		show()
	else:
		hide()

func _onTargetingTile( validTargetMatrix , targetsPlayer ):
	setState( STATE.LOCK )

func _onTargetingBattler( validTargetMatrix , targetsPlayer ):
	if( isPlayer == targetsPlayer && validTargetMatrix[myX][myY] ):
		setState( STATE.TARGETING )
	else:
		setState( STATE.LOCK )

func _onGeneralCancel():
	if( myState != STATE.CLEAR ):
		setState( STATE.CLEAR )

func _gui_input( input ):
	if( myState == STATE.HIGHLIGHT && input.is_action_pressed( "GUI_SELECT" ) ):
		print("Battler at " , myX , ":" , myY , " is a valid target and clicked")
		eventBus.emit( "TargetingSelected" , [ myX , myY ] )

func _onMouseEntered():
	if( myState == STATE.TARGETING ):
		prevState = myState
		setState( STATE.HIGHLIGHT )
	
	eventBus.emit("HoverCrewman" , [ crewman ] )

func _onMouseExited():
	if( prevState ):
		setState( prevState )
		prevState = null
	
	eventBus.emit("UnhoverCrewman" , [ crewman ])