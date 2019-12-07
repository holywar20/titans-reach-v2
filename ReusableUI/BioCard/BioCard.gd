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

func setupScene( eventBus : EventBus , crewman : Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

func _ready():
	if( self.crewman ):
		self.loadData( self.crewman )
	if( self.eventBus ):
		self.loadEvents( self.eventBus )

func loadEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func loadData( crewman : Crew ):
	self.crewman = crewman

	self.nodes.Height.set_text( ": " + crewman.getHeightString() )
	self.nodes.Mass.set_text( ": " + crewman.getMassString() )
	self.nodes.Sex.set_text( ": " + crewman.getSexString() )
	self.nodes.Age.set_text( ": " + crewman.getAgeString() )
	self.nodes.Homeworld.set_text( ": " + crewman.getWorldString() )
	self.nodes.Race.set_text( ": " + crewman.getRaceString() )

	self.nodes.Description.set_text( crewman.bio )






