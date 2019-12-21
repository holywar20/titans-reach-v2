extends VBoxContainer

onready var abilityButtonScene = load("res://ReusableUI/AbilityButton/AbilityButton.tscn")
onready var grid = get_node("Grid")

var eventBus = null
var crewman = null

func setupScene( eventBus : EventBus , crewman ):
	self.eventBus = eventBus
	self.crewman = crewman

	if( self.crewman ):
		self.show()
	else:
		self.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	if( self.crewman ):
		self.loadData( self.crewman )

func _clear():
	for child in self.grid.get_children():
		child.queue_free()
	
func toggleAllButtons( status ):
	for actionButton in self.grid.get_children():
		actionButton.toggleDisabled( status )

func loadData( crewman = null ):
	self._clear()
	self.crewman = crewman
	
	if ( crewman ):
		self.show()
	else:
		self.hide()

	if( crewman ):
		var stances = self.crewman.getAllStances()
		
		for stance in stances:
			var stanceInstance = abilityButtonScene.instance()
			# TODO - add tests for clickability potentially
			stanceInstance.setupScene( self.eventBus , stance , false )
			self.grid.add_child( stanceInstance )