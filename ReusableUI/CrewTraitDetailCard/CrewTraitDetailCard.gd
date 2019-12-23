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

func setupScene( eBus : EventBus ):
	eventBus = eBus

	eventBus.register("CrewmanSelected" , self, "_onCrewmanSelected")
	eventBus.register("GeneralCancel" , self , "_onGeneralCancel")

func _ready():
	hide()

func _clearSelf():
	for child in traitBase.get_children():
		child.queue_free()

func _onCrewmanSelected( newCrewman : Crew ):
	_clearSelf()
	crewman = newCrewman

	nodes.Name.set_text( crewman.getFullName() )
	nodes.Image.set_texture( load( crewman.smallTexturePath ) )
	
	var station = crewman.getStation()
	if( station ):
		nodes.Station.set_text( station.consoleName )
	else:
		nodes.Station.set_text( UNASSIGNED_DISPLAY_TEXT )

	_buildTraitsTable()
	show()

func _onGeneralCancel():
	hide()

func _buildTraitsTable():
	var headerRow = dataRowScene.instance()
	headerRow.setupScene( HEADERS )

	var allRows = [ headerRow ]

	var traitStatBlocks = crewman.getAllTraitStatBlocks()
	for key in traitStatBlocks:
		var statBlock = traitStatBlocks[key]
		var statBlockArray = [
			statBlock.fullName, statBlock.total
		]
		var statRow = dataRowScene.instance()
		statRow.setupScene( statBlockArray )
		allRows.append( statRow )

	for row in allRows:
		traitBase.add_child( row )


