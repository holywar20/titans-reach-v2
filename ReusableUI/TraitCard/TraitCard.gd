extends VBoxContainer

var character

onready var expandedHeader = get_node("Header")

const DATA_ROW_GROUP = "TraitDataRow"

func _clear():
	var currentDataRows = get_tree().get_nodes_in_group( self.DATA_ROW_GROUP )
	for row in currentDataRows:
		row.queue_free()

func loadCharacterDataExpanded( character : Crew ):
	self._clear()
	self.character = character
	self.expandedHeader.set_visible( true )

	var traitStatBlocks = self.character.getAllTraitStatBlocks()

	for key in traitStatBlocks:

		var statBlock = traitStatBlocks[key]

		var statBlockArray = [
			statBlock.fullName , 
			statBlock.value , 
			statBlock.equip, 
			statBlock.talent, 
			statBlock.total
		]


func loadCharacterDataDense( character : Crew ):
	self._clear()
	self.character = character
	self.expandedHeader.set_visible( false )

	var traitStatBlocks = self.character.getAllTraitStatBlocks()

	for key in traitStatBlocks:
		var statBlock = traitStatBlocks[key]

		var statBlockArray = [
			statBlock.name , 
			statBlock.total
		]
