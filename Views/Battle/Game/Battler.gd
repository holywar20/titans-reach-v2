extends Sprite

onready var barNodes = {
	"HealthBar" : get_node("Health/Bar"),
	"MoraleBar" : get_node("Morale/Bar"),
	"HealthValue" : get_node( "Health/Bar/Value"),
	"MoraleValue" : get_node( "Morale/Bar/Value")
}

const STATE = { "TARGETING" : "TARGETING" , "TARGETED" : "TARGETED" , "CLEAR" : "CLEAR" }
const STATE_DATA = {
	"TARGETING" : { "Color" : Color( .6 , .6  , .3 , 1 ) },
	"TARGETED"  : { "Color" : Color( .6 , .3 , .3 , 1 ) },
	"CLEAR" 		: { "Color" : Color( 1 , 1  ,  1 , 1 ) }
}
var myState = STATE.CLEAR

var eventBus = null
var crewman = null
export(int) var myX = 0
export(int) var myY = 0

func setupScene( eBus : EventBus , battler : Crew ):
	eventBus = eBus
	crewman = battler

	loadEvents()

	if( is_inside_tree() ):
		loadData()

func _ready():
	pass

func loadEvents():
	pass

func setState( stateName : String ):
	# print("setting state for battler , " , myX , " ",  myY , " " , stateName)
	myState = STATE_DATA[stateName]
	set_self_modulate( myState.Color )

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