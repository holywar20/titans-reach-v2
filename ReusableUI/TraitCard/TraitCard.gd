extends VBoxContainer

var crewman = null
var eventBus = null

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")
onready var traitBase = get_node("Panel/VBox")

const HEADERS = [ "" , "Base" , "Equip" , "Talent" , "Total"]

func setupScene( eBus : EventBus , newCrewman : Crew ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		show()
	else:
		hide()

func _ready():
	if( crewman ):
		loadData( crewman )
	
func setEventBus( eBus : EventBus ):
	eventBus = eBus

func _clear():
	for child in traitBase.get_children():
		child.queue_free()

func loadData( crewman = null ):
	_clear()
	crewman = crewman
	
	if ( crewman ):
		show()
	else:
		hide()

	var headerRow = dataRowScene.instance()
	headerRow.setupScene( HEADERS )
	var allRows = [ headerRow ]

	var traitStatBlocks = crewman.getAllTraitStatBlocks()
	for key in traitStatBlocks:
		var statBlock = traitStatBlocks[key]
		var statBlockArray = [
			statBlock.fullName , 
			statBlock.value , 
			statBlock.equip, 
			statBlock.talent, 
			statBlock.total
		]
		var statRow = dataRowScene.instance()
		statRow.setupScene( statBlockArray )
		allRows.append( statRow )
	
	for row in allRows:
		traitBase.add_child( row )
