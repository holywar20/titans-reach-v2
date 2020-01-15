extends PanelContainer

var eventBus = null
var parentNode = null
var crewman = null

onready var nodes = {
	# Cards
	"TraitsCard" : get_node("HBox/Left/TraitCard"),
	"VitalsCard" : get_node("HBox/Right/VitalsCard"),
	"BioCard" : get_node("HBox/Right/BioCard"),
	"ResistanceCard" : get_node("HBox/Right/ResistanceCard"),
	"ActionCard" : get_node("HBox/Center/ActionCard"),

	# Text nodes
	"CharacterPoints" : get_node("HBox/Left/CharacterPoints/Amount"),
	"CrewmanName"		: get_node("HBox/Center/Crewman/Name")
}

func setupScene( eBus : EventBus , parentNode ):
	eventBus = eBus
	parentNode = parentNode
	crewman = parentNode.getCurrentCrewman()

func _ready():
	eventBus.emit("SubUIAnyOpenEnd")
	loadCrewmanData( crewman )

func loadCrewmanData( crewman : Crew ):
	nodes.CharacterPoints.set_text( crewman.getCPointString() )
	nodes.CrewmanName.set_text( crewman.getFullName() )

	nodes.TraitsCard.loadData( crewman )
	nodes.ResistanceCard.loadData( crewman )

	nodes.VitalsCard.loadData( crewman )
	nodes.BioCard.loadData( crewman )

# Buttons
func _onNextPressed():
	crewman = parentNode.getNextCrewman()
	loadCrewmanData( crewman )

func _onPrevPressed():
	crewman = parentNode.getPrevCrewman()
	loadCrewmanData( crewman )