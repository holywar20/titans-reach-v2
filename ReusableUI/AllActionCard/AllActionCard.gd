extends VBoxContainer


onready var abilityButtonScene = load("res://ReusableUI/AbilityButton/AbilityButton.tscn")
onready var grid = get_node("Panel/Center/HBox/Grid")

var eventBus = null
var crewman = null

func setupScene( eBus : EventBus, newCrewman ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		show()
	else:
		hide()

func _ready():
	if( crewman ):
		loadData( crewman )

func _clear():
	for child in grid.get_children():
		child.queue_free()

func toggleAllButtons( status ):
	for abilityButton in grid.get_children():
		abilityButton.toggleDisabled( status )

func loadData( newCrewman = null ):
	_clear()
	crewman = newCrewman
	
	if ( crewman ):
		show()
	else:
		hide()

	if( crewman ):
		var actions = crewman.getAllActions()
		
		for action in actions:
			var actionInstance = abilityButtonScene.instance()
			actionInstance.setupScene( eventBus , action , false )
			grid.add_child( actionInstance )
