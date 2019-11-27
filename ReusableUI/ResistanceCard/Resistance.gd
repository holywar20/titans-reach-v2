extends VBoxContainer

var character

onready var dataRowScene = load("res://ReusableUI/General/DoubleDataRow.tscn")
onready var expandedDataScene = load("res://ReusableUI/General/ExpandedDataRow.tscn")

onready var expandedHeader = get_node("Header")

const DATA_ROW_GROUP = "ResistanceDataRow"

func _ready():
	pass

# Clears all Data Rows
func _clear():
	var currentDataRows = get_tree().get_nodes_in_group( self.DATA_ROW_GROUP )
	for row in currentDataRows:
		row.queue_free()

func loadCharacterData( character : Crew ):
	self._clear()
	self.character = character

	self.expandedHeader.set_visible( false )

	#instance new datarows on the basis of character data
	var resistStatBlocks = self.character.getAllResistStatBlocks()

	for key in resistStatBlocks:
		var dataRow = dataRowScene.instance()
		dataRow.add_to_group( self.DATA_ROW_GROUP )

		var traitStatBlocks = resistStatBlocks[key]
		
		var data = []

		for iKey in traitStatBlocks:
			data.append(traitStatBlocks[iKey])
		
		dataRow.loadData( data[0].name , data[0].total , data[1].name, data[1].total )
		
		self.add_child(dataRow)

func loadCharacterDataExpanded( character : Crew ):
	self.character = character
	self._clear()

	self.expandedHeader.set_visible( true )

	var resistStatBlocks = self.character.getAllResistStatBlocks()

	for key in resistStatBlocks:

		var traitStatBlocks = resistStatBlocks[key]

		for iKey in traitStatBlocks:
			var dataRow = expandedDataScene.instance()
			dataRow.add_to_group( self.DATA_ROW_GROUP )

			var statBlock = traitStatBlocks[iKey]

			var statBlockArray = [
				statBlock.name , 
				statBlock.value , 
				statBlock.equip, 
				statBlock.talent, 
				statBlock.total
			]

			dataRow.loadData ( statBlockArray )
			self.add_child( dataRow )



