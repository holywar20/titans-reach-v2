extends VBoxContainer

var character

onready var expandedHeader = get_node("Header")

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
		# Build up some data object & find and replace into a bbcode string
		pass 

func loadCharacterDataExpanded( character : Crew ):
	self.character = character
	self._clear()

	self.expandedHeader.set_visible( true )

	var resistStatBlocks = self.character.getAllResistStatBlocks()

	for key in resistStatBlocks:

		var traitStatBlocks = resistStatBlocks[key]

		for iKey in traitStatBlocks:
			var statBlock = traitStatBlocks[iKey]

			var statBlockArray = [
				statBlock.name , 
				statBlock.value , 
				statBlock.equip, 
				statBlock.talent, 
				statBlock.total
			]



