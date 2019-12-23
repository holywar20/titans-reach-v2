extends Sprite

onready var barNodes = {
	"HealthBar" : get_node("Health/Bar"),
	"MoraleBar" : get_node("Morale/Bar"),
	"HealthValue" : get_node( "Health/Bar/Value"),
	"MoraleValue" : get_node( "Morale/Bar/Value")
}

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

func highlight():
	print( "Highlighting!")

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