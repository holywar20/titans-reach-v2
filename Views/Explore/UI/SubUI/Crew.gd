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
	"AllActionCard" : get_node("HBox/Left/AllActionCard"),

	# Text nodes
	"CharacterPoints" : get_node("HBox/Left/CharacterPoints/Amount"),
	"CrewmanName"		: get_node("HBox/Center/Crewman/Name")
}

func setupScene( eventBus : EventBus , parentNode ):
	self.eventBus = eventBus
	self.parentNode = parentNode
	self.crewman = self.parentNode.getCurrentCrewman()

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")
	self.loadCrewmanData( self.crewman )

func loadCrewmanData( crewman : Crew ):
	self.nodes.CharacterPoints.set_text( crewman.getCPointString() )
	self.nodes.CrewmanName.set_text( crewman.getFullName() )

	self.nodes.TraitsCard.loadData( crewman )
	self.nodes.ResistanceCard.loadData( crewman )

	self.nodes.VitalsCard.loadData( crewman )
	self.nodes.BioCard.loadData( crewman )

# Buttons
func _onNextPressed():
	self.crewman = self.parentNode.getNextCrewman()
	self.loadCrewmanData( self.crewman )

func _onPrevPressed():
	self.crewman = self.parentNode.getPrevCrewman()
	self.loadCrewmanData( self.crewman )