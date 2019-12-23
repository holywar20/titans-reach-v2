extends VBoxContainer

onready var abilityButtonScene = load("res://ReusableUI/AbilityButton/AbilityButton.tscn")
onready var grid = get_node("Grid")

var eventBus = null
var crewman = null

func setupScene( eBus : EventBus , newCrewman ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		show()
	else:
		hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	if( crewman ):
		loadData( crewman )

func _clear():
	for child in grid.get_children():
		child.queue_free()
	
func toggleAllButtons( status ):
	for actionButton in grid.get_children():
		actionButton.toggleDisabled( status )

func loadData( newCrewman = null ):
	_clear()
	crewman = newCrewman
	
	if ( crewman ):
		show()
	else:
		hide()

	if( crewman ):
		var stances = crewman.getAllStances()
		
		for stance in stances:
			var stanceInstance = abilityButtonScene.instance()
			# TODO - add tests for clickability potentially
			stanceInstance.setupScene( eventBus , stance , false )
			grid.add_child( stanceInstance )