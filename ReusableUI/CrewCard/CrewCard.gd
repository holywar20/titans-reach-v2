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

func setupScene( eventBus : EventBus, crewman : Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

func _ready():
	if( self.crewman ):
		self.loadData()

func loadData():
	self.nodes.Name.set_text( self.crewman.getFullName() )
	
	var texture = load( self.crewman.smallTexturePath )
	if( texture ):
		self.nodes.Character.set_texture( texture )
	
	var hp = crewman.getHPStatBlock()

	self.nodes.HpBar.set_max( hp.total )
	self.nodes.HpBar.set_value( hp.current )
	self.nodes.HpVal.set_text( self.crewman.getHitPointString() )

	var morale = crewman.getMoraleStatBlock()

	self.nodes.MoBar.set_max( morale.total )
	self.nodes.MoBar.set_value( morale.current )
	self.nodes.MoVal.set_text( self.crewman.getMoraleString() )

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		self._createDraggable( guiEvent )
		self.eventBus.emit( "CrewmanSelected" , [ self.crewman ] )

func _createDraggable( guiEvent : InputEvent ):
	var draggableScene = load( self.DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( self.eventBus , self.crewman )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )
	self.eventBus.emit( "DraggableCreated" , [ self.crewman , null ] )

