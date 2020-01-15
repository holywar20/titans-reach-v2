extends PanelContainer

onready var grid = get_node("VBox/Panel/Center/HBox/Grid")
onready var buttons = [
	get_node("VBox/Panel/HBox/Grid/Row1/A1"),
	get_node("VBox/Panel/HBox/Grid/Row1/A2"),
	get_node("VBox/Panel/HBox/Grid/Row1/A3"),
	get_node("VBox/Panel/HBox/Grid/Row1/A4"),
	get_node("VBox/Panel/HBox/Grid/Row1/A5"),
	get_node("VBox/Panel/HBox/Grid/Row2/A6"),
	get_node("VBox/Panel/HBox/Grid/Row2/A7"),
	get_node("VBox/Panel/HBox/Grid/Row2/A8"),
	get_node("VBox/Panel/HBox/Grid/Row2/A9"),
	get_node("VBox/Panel/HBox/Grid/Row2/A10"),
	get_node("VBox/Panel/HBox/Grid/Row3/A11"),
	get_node("VBox/Panel/HBox/Grid/Row3/A12"),
	get_node("VBox/Panel/HBox/Grid/Row3/A13"),
	get_node("VBox/Panel/HBox/Grid/Row3/A14"),
	get_node("VBox/Panel/HBox/Grid/Row3/A15")
]

var eventBus = null
var crewman = null

func setupScene( eBus : EventBus, newCrewman ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		loadData( crewman )
	else:
		loadData()

func _ready():
	if( crewman ):
		loadData( crewman )

func toggleAllButtons( status ):
	pass

func loadData( newCrewman = null ):
	crewman = newCrewman
	
	if ( crewman ):
		show()

		var actions = crewman.getAllActions()
		
		for x in range( 0 , buttons.size() ):
			if( actions.size() > x ):
				buttons[x].setupScene( eventBus , actions[x] , false )
			else:
				buttons[x].hide()
	else:
		hide()

