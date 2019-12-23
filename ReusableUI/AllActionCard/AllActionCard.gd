extends VBoxContainer


onready var abilityButtonScene = load("res://ReusableUI/AbilityButton/AbilityButton.tscn")
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

func toggleAllButtons( status ):
	for abilityButton in self.grid.get_children():
		abilityButton.toggleDisabled( status )

func loadData( crewman = null ):
	self._clear()
	self.crewman = crewman
	
	if ( crewman ):
		self.show()
	else:
		self.hide()

	if( crewman ):
		var actions = self.crewman.getAllActions()
		
		for action in actions:
			var actionInstance = self.abilityButtonScene.instance()
			actionInstance.setupScene( self.eventBus , action , false )
			self.grid.add_child( actionInstance )
