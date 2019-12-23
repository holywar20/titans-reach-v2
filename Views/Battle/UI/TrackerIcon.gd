extends Panel

onready var nodes = {
	"Crewman"	: get_node("CrewmanPicture"),
	"Init"		: get_node("InitValue")
}

var eventBus = null
var crewman = null
var init = 0

func setupScene( eBus : EventBus , newCrewman : Crew  , newInit : int ):
	crewman = newCrewman
	eventBus = eBus
	init = newInit

func _ready():
	if( eventBus ):
		loadEvents()

	if( crewman ):
		loadData()

func loadEvents():
	pass 

func loadData():
	nodes.Crewman.set_texture( load(crewman.smallTexturePath) )
	nodes.Init.set_text( str(init) )