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

func setupScene( eBus : EventBus , pNode ):
	eventBus = eBus
	parentNode = pNode
	crewman = parentNode.getCurrentCrewman()

func _ready():
	eventBus.emit("SubUIAnyOpenEnd")
	loadCrewmanData( crewman )

func loadCrewmanData( cMan : Crew ):
	nodes.CharacterPoints.set_text( cMan.getCPointString() )
	nodes.CrewmanName.set_text( cMan.getFullName() )

	nodes.TraitsCard.loadData( cMan )
	nodes.ResistanceCard.loadData( cMan )

	nodes.VitalsCard.loadData( cMan )
	nodes.BioCard.loadData( cMan )

# Buttons
func _onNextPressed():
	crewman = parentNode.getNextCrewman()
	loadCrewmanData( crewman )

func _onPrevPressed():
	crewman = parentNode.getPrevCrewman()
	loadCrewmanData( crewman )