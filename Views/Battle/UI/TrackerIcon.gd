extends Panel

onready var nodes = {
	"Crewman"	: get_node("CrewmanPicture"),
	"Init"		: get_node("InitValue")
}

var eventBus = null
var crewman = null
var init = 0

func setupScene( eventBus : EventBus , crewman : Crew  , init : int ):
	self.crewman = crewman
	self.eventBus = eventBus
	self.init = init

func _ready():
	if( self.eventBus ):
		self.loadEvents()

	if( self.crewman ):
		self.loadData()

func loadEvents():
	pass 

func loadData():
	self.nodes.Crewman.set_texture( load(self.crewman.smallTexturePath) )
	self.nodes.Init.set_text( str(self.init) )