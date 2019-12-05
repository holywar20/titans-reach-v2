extends VBoxContainer

var eventBus : EventBus
var crewman : Crew

onready var nodes = {
	"DetailText": get_node("DetailText"),
	"Name"		: get_node("Header/VBox/Name"),
	"Image"		: get_node("Header/Control/CrewmanFace"),
	"Station"	: get_node("Header/VBox/Station")
}

func setupScene( eventBus: EventBus ):
	self.eventBus = eventBus

	self.eventBus.register("CrewmanSelected" , self, "_onCrewmanSelected")
	self.eventBus.register("GeneralCancel" , self , "_onGeneralCancel")

func _ready():
	pass

func _onCrewmanSelected( crewman : Crew ):
	self.crewman = crewman

	self.nodes.Name.set_text( crewman.getFullName() )
	self.nodes.Image.set_texture( load( crewman.smallTexturePath ) )

	self._buildTraitsTable()

	self.show()

func _onGeneralCancel():
	self.hide()

	self.nodes.DetailText.set_text( "" )

func _buildTraitsTable():
	var table = "Table!"
	self.nodes.DetailText.set_text( table )


