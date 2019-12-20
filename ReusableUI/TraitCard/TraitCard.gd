extends VBoxContainer

var crewman = null
var eventBus = null

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")
onready var traitBase = get_node("Panel/VBox")

const HEADERS = [ "" , "Base" , "Equip" , "Talent" , "Total"]

func setupScene( eventBus : EventBus , crewman : Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

	if( self.crewman ):
		self.show()
	else:
		self.hide()

func _ready():
	if( self.crewman ):
		self.loadData( self.crewman )
	if( self.eventBus ):
		self.setEventBus( self.eventBus )
	
func setEventBus( eventBus : EventBus ):
	self.eventBus = eventBus

func _clear():
	for child in self.traitBase.get_children():
		child.queue_free()

func loadData( crewman = null ):
	self._clear()
	self.crewman = crewman
	
	if ( crewman ):
		self.show()
	else:
		self.hide()
	
	self._clear()
	self.crewman = crewman

	var headerRow = self.dataRowScene.instance()
	headerRow.setupScene( self.HEADERS )
	var allRows = [ headerRow ]

	var traitStatBlocks = self.crewman.getAllTraitStatBlocks()
	for key in traitStatBlocks:
		var statBlock = traitStatBlocks[key]
		var statBlockArray = [
			statBlock.fullName , 
			statBlock.value , 
			statBlock.equip, 
			statBlock.talent, 
			statBlock.total
		]
		var statRow = self.dataRowScene.instance()
		statRow.setupScene( statBlockArray )
		allRows.append( statRow )
	
	for row in allRows:
		self.traitBase.add_child( row )
