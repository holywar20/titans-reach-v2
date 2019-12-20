extends VBoxContainer

var crewman = null
var eventBus = null 

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")
onready var resistBase = get_node("Panel/Resists")

const HEADERS = [ "" , "Trait", "Base" , "Equip" , "Talent" , "Total"]

func setupScene( eventBus: EventBus, crewman: Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

	if( self.crewman ):
		self.show()
	else:
		self.hide()

func _ready():
	if( self.crewman ):
		self.loadData( crewman )
	if( self.eventBus ):
		self.setEvents

# Clears all Data Rows
func _clear():
	for row in self.resistBase.get_children():
		row.queue_free()

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func loadData( crewman = null ):
	self._clear()
	self.crewman = crewman
	
	if ( crewman ):
		self.show()
	else:
		self.hide()
		return null
	
	var headerRow = self.dataRowScene.instance()
	headerRow.setupScene( self.HEADERS )
	var allRows = [ headerRow ]

	# Resists are indexed by Trait
	var resistStatBlocks = self.crewman.getAllResistStatBlocks()
	for traitKey in resistStatBlocks:

		var traitStatBlocks = resistStatBlocks[traitKey]
		for innerKey in traitStatBlocks:
			var statBlock = traitStatBlocks[innerKey]
			var statBlockArray = [
				statBlock.name ,
				traitKey,
				statBlock.value , 
				statBlock.equip, 
				statBlock.talent, 
				statBlock.total
			]

			var statRow = self.dataRowScene.instance()
			statRow.setupScene( statBlockArray )
			allRows.append( statRow )

	for row in allRows:
		self.resistBase.add_child( row )



