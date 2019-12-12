extends Panel

class_name DragLock

enum RELATIONSHIPS { CREW_CONSOLE , EQUIPMENT_CREW , WEAPON_CREW , FRAME_CREW , MOD_STARSHIP , CONSOLE_STARSHIP , SHIPWEAPON_STARSHIP , CREW_BATTLEORDER }
const RELATIONSHIP_DATA = [
	{	"holdsClass" : "Crew"	,
		"isClass" : "Console",
		"firesEvent" : "CrewAssigned",
		"lockSize" : Vector2( 100 , 100 ),
		"textureSize" : Vector2( 64, 64),
		"validationFunc" : "",
		"executionFunc" : ""
	} , {
		"holdsClass" : "Equipment"	, 
		"isClass" : "Crew" 	, 
		"firesEvent" : "EquipmentAssigned", 
		"lockSize" : Vector2( 100 , 100 ),
		"textureSize" : Vector2( 64, 64),
		"validationFunc" : "" , 
		"executionFunc" : "" 
	} , {
		"holdsClass" : "Weapon", 
		"isClass" : "Crew" 	, 
		"firesEvent" : "WeaponAssigned"	,
		"lockSize" : Vector2( 200 , 100 ) ,
		"textureSize" : Vector2( 128, 64),
		"validationFunc" : "" , 
		"executionFunc" : "" 
	} , {
		"holdsClass" : "Frame" , 
		"isClass" : "Crew" 	, 
		"firesEvent" : "FrameAssigned" ,
		"lockSize" : Vector2( 100 , 200 ),
		"textureSize" : Vector2( 64, 128 ),
		"validationFunc" : "" , 
		"executionFunc" : "" 
	}
]

var holdsClass
var isClass
var firesEvent
var validationFunc
var executionFunc
var lockSize
var textureSize

var defaultTexture = "res://icon.png"

onready var nodes = {
	"Name" 	: get_node("VBox/Name"),
	"Image"	: get_node("VBox/Image")
}

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"

var eventBus : EventBus
var displayName = ""

var lockHolds = null 
var lockIs = null

var myDraggableBeingDragged = false

func setupScene( eventBus : EventBus ,  lockIs , relationship : int , displayName ):
	self.eventBus = eventBus
	self.lockIs = lockIs
	self.displayName = displayName

	var myRelationship = self.RELATIONSHIP_DATA[relationship]

	for key in myRelationship:
		self.set( key , myRelationship[key] )

	if( self.is_inside_tree() ):
		self._loadData()

func _ready():
	if( self.lockIs ):
		self._loadData()

func _loadData():
	self.nodes.Image.set_size( self.textureSize )
	self.nodes.Name.set_text( self.displayName )

	self.set_size( self.lockSize )

func _onDraggableReleased( payload , draggableDroppedLocation : Vector2 ):
	var inArea = false
	if( self._isInArea( draggableDroppedLocation ) ):
		inArea = true
		
	# Verify the type of the payload matches
	var isRightType = false 
	if( inArea ):
		if( payload.is_class( self.holdsClass ) ):
			isRightType = true
		else:
			isRightType = false
	
	var isValid = false 
	if( isRightType ):
		isValid = self.callv( self.validationFunc , [ self.lockIs , self.lockHolds ] )
	
	var isExecuted
	if( isValid ):
		isExecuted = self.callv( self.executionFunc , [ self.lockIs , self.lockHolds ] )

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) && self.lockHolds ):
		self._createDraggable( guiEvent , self.lockHolds )
		self.eventBus.emit( self.firesEvent , [ self.lockHolds ] )

func updateScene():
	if( self.lockIs ):
		pass
	else:
		self.nodes.Image.set_texture( self.defaultTexture )

func _isInArea( pos: Vector2 ):
	var rect = self.get_global_rect()
	
	if rect.has_point(pos):
		return true
	
	return false

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( self.DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( self.eventBus , payloadObject )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )

	self.myDraggableBeingDragged = true
