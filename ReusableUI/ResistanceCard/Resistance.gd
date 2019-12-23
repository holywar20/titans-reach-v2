extends VBoxContainer

var crewman = null
var eventBus = null 

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")
onready var resistBase = get_node("Panel/Resists")

const HEADERS = [ "" , "Trait", "Base" , "Equip" , "Talent" , "Total"]

func setupScene( eBus : EventBus, newCrewman : Crew ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		show()
	else:
		hide()

func _ready():
	if( crewman ):
		loadData( crewman )
	if( eventBus ):
		setEvents( eventBus )

# Clears all Data Rows
func _clear():
	for row in resistBase.get_children():
		row.queue_free()

func setEvents( eBus : EventBus ):
	eventBus = eBus

func loadData( crewman = null ):
	_clear()
	crewman = crewman
	
	if ( crewman ):
		show()
	else:
		hide()
		return null
	
	var headerRow = dataRowScene.instance()
	headerRow.setupScene( HEADERS )
	var allRows = [ headerRow ]

	# Resists are indexed by Trait
	var resistStatBlocks = crewman.getAllResistStatBlocks()
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

			var statRow = dataRowScene.instance()
			statRow.setupScene( statBlockArray )
			allRows.append( statRow )

	for row in allRows:
		resistBase.add_child( row )



