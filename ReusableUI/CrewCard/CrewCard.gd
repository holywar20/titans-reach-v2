extends HBoxContainer

onready var nodes = {
	"Name" 		: get_node("Data/CrewmanName"),
	"HpBar"		: get_node("Data/HP/Bar"),
	"HpVal"		: get_node("Data/HP/Bar/Val"),
	"MoBar"		: get_node("Data/Morale/Bar"),
	"MoVal"		: get_node("Data/Morale/Bar/Val"),
	"Character" : get_node("Avatar/Center/Face")
}

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"

var eventBus = null
var crewman = null 

func setupScene( eBus : EventBus, newCrewman = null ):
	eventBus = eBus
	crewman = newCrewman

	if( crewman ):
		show()
	else:
		hide()

func _ready():
	if( crewman ):
		loadData()

func loadData( newCrewman = null ):
	if( newCrewman ):
		crewman = newCrewman
	
	if ( crewman ):
		show()
	else:
		hide()
		return null
	
	nodes.Name.set_text( crewman.getFullName() )
	
	var texture = load( crewman.smallTexturePath )
	if( texture ):
		nodes.Character.set_texture( texture )
	
	var hp = crewman.getHPStatBlock()

	nodes.HpBar.set_max( hp.total )
	nodes.HpBar.set_value( hp.current )
	nodes.HpVal.set_text( crewman.getHitPointString() )

	var morale = crewman.getMoraleStatBlock()

	nodes.MoBar.set_max( morale.total )
	nodes.MoBar.set_value( morale.current )
	nodes.MoVal.set_text( crewman.getMoraleString() )

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		_createDraggable( guiEvent )
		eventBus.emit( "CrewmanSelected" , [ crewman ] )

func _createDraggable( guiEvent : InputEvent ):
	var draggableScene = load( DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( eventBus , crewman )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )
	eventBus.emit( "DraggableCreated" , [ crewman , null ] )

