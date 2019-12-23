extends VBoxContainer

var crewman = null
var eventBus = null

onready var nodes = {
	"Height"		: get_node( "BioLine3/Height" ),
	"Age"			: get_node( "BioLine3/Age" ),

	"Sex"			: get_node( "BioLine2/Sex" ),
	"Mass"		: get_node( "BioLine2/Mass" ),

	"Homeworld" : get_node( "BioLine1/Homeworld" ),
	"Race"		: get_node( "BioLine1/Race" ),

	"Description" : get_node( "TextEdit")
}

func setupScene( eBus : EventBus , newCrewman : Crew ):
	eventBus = eBus
	crewman = newCrewman

func _ready():
	if( crewman ):
		loadData( crewman )
	if( eventBus ):
		loadEvents( eventBus )

func loadEvents( eBus : EventBus ):
	eventBus = eBus

func loadData( crewman : Crew ):
	crewman = crewman

	nodes.Height.set_text( ": " + crewman.getHeightString() )
	nodes.Mass.set_text( ": " + crewman.getMassString() )
	nodes.Sex.set_text( ": " + crewman.getSexString() )
	nodes.Age.set_text( ": " + crewman.getAgeString() )
	nodes.Homeworld.set_text( ": " + crewman.getWorldString() )
	nodes.Race.set_text( ": " + crewman.getRaceString() )

	nodes.Description.set_text( crewman.bio )






