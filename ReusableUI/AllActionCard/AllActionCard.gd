extends VBoxContainer


onready var actionButtonScene = load("res://ReusableUI/AllActionCard/ActionButton.tscn")
onready var grid = get_node("Panel/Center/HBox/Grid")

var eventBus = null
var crewman = null

func setupScene( eventBus : EventBus, crewman ):
	self.eventBus = eventBus
	self.crewman = crewman

	if( self.crewman ):
		self.show()
	else:
		self.hide()

func _ready():
	if( self.crewman ):
		self.loadData( self.crewman )

func _clear():
	for child in self.grid.get_children():
		child.queue_free()

func loadData( crewman = null ):
	self._clear()
	self.crewman = crewman
	
	if ( crewman ):
		self.show()
	else:
		self.hide()

	var allActions = self.crewman.getAllActions()
