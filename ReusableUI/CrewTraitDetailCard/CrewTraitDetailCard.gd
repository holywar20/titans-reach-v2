extends VBoxContainer

const UNASSIGNED_DISPLAY_TEXT = "Unassigned"

var eventBus = null
var crewman = null

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")
onready var traitBase = get_node("Details/VBox")

const HEADERS = [ "" , "Total" ]


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
	self.hide()

func _clearSelf():
	for child in self.traitBase.get_children():
		child.queue_free()

func _onCrewmanSelected( crewman : Crew ):
	self._clearSelf()
	self.crewman = crewman

	self.nodes.Name.set_text( crewman.getFullName() )
	self.nodes.Image.set_texture( load( crewman.smallTexturePath ) )
	
	var station = self.crewman.getStation()
	if( station ):
		self.nodes.Station.set_text( station.consoleName )
	else:
		self.nodes.Station.set_text( self.UNASSIGNED_DISPLAY_TEXT )

	self._buildTraitsTable()
	self.show()

func _onGeneralCancel():
	self.hide()

func _buildTraitsTable():
	var headerRow = self.dataRowScene.instance()
	headerRow.setupScene( self.HEADERS )

	var allRows = [ headerRow ]

	var traitStatBlocks = self.crewman.getAllTraitStatBlocks()
	for key in traitStatBlocks:
		var statBlock = traitStatBlocks[key]
		var statBlockArray = [
			statBlock.fullName, statBlock.total
		]
		var statRow = self.dataRowScene.instance()
		statRow.setupScene( statBlockArray )
		allRows.append( statRow )

	for row in allRows:
		self.traitBase.add_child( row )


