extends Panel

class_name DragLock

# TODO - probally don't need this bullshit. Just make a draglock method that configures it as a console.
enum RELATIONSHIPS { CREW_CONSOLE , EQUIPMENT_CREW , WEAPON_CREW , FRAME_CREW , MOD_STARSHIP , CONSOLE_STARSHIP , SHIPWEAPON_STARSHIP , CREW_BATTLEORDER }
const RELATIONSHIP_DATA = [
	{	"holdsClass" : "Crew"	,
		"isClass" : "Console",
		"lockSize" : Vector2( 100 , 100 ),
		"firesEvent" : "CrewmanAssigned",
		"textureSize" : Vector2( 64, 64),
		"nodeGroup" : "ConsoleDragLock",
		"defaultTexture" : "res://icon.png",
}]


var nodeGroup	= null
var showsDescription = true # TODO may add an override for this later if we want to customize that behavior

export(String) var holdsClass 		= null
export(String) var isClass				= null 
export(Vector2) var textureSize		= Vector2( 75 , 100 )
export(Vector2) var lockSize 			= Vector2( 64 , 64)

export(String) var displayName 		= "{UNSET!}"
export(String) var firesEvent			= ""
export(String) var lockName			= ""
export(Texture) var defaultTexture 	= load("res://icon.png")

var myDraggableBeingDragged = false

onready var nodes = {
	"Name" 	: get_node("VBox/Name"),
	"Image"	: get_node("VBox/Image")
}

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"

const EQUIPPED_COLOR = Color( 1, 1, 1, 1 )
const UNEQUIPPED_COLOR = Color( .5 , .5 , .5 , 1 )
const DROPPABLE_COLOR = Color( .6 , 1 , .6 , 1 )
const UNDROPPABLE_COLOR = Color( 1 , .6, .6 , 1)

var eventBus : EventBus

var lockHolds = null 
var lockIs = null

# should only need to call this method if dynamically creating the lock.
func setupScene( eventBus : EventBus , lockIs , relationship : int , lockName : String, displayName = "" ):
	self.eventBus = eventBus
	self.lockIs = lockIs
	self.displayName = displayName
	self.lockName = lockName

	var myRelationship = self.RELATIONSHIP_DATA[relationship]
	for key in myRelationship:
		self.set( key , myRelationship[key] )

	# Stupid I know, but I want to be able to preload textures inside the interface, but store them as strings in the list
	self.defaultTexture = load( self.defaultTexture )

	if( self.is_inside_tree() ):
		self.setEvents()

func _ready():
	if( self.isClass ):
		self._loadData()
		self.setEvents()

func setEvents( newEventBus = null ):
	if( newEventBus ):
		self.eventBus = newEventBus

	if( self.eventBus ):
		self.eventBus.register( "DraggableCreated" , self , "_onDraggableCreated" )
		self.eventBus.register( "DraggableReleased" , self , "_onDraggableReleased" )

# Loads data from setupScene OR the export view, and calculates it all.
func _loadData():
	self.set_size( self.lockSize )
	
	self.nodes.Image.set_size( self.textureSize )
	self.nodes.Image.set_texture( self.defaultTexture )
	self.nodes.Name.set_text( self.displayName )

	if( self.showsDescription ):
		self.nodes.Name.set_text( self.displayName )
	else:
		self.nodes.Name.hide()

	if( self.nodeGroup ):
		self.add_to_group( self.nodeGroup )

	self.set_size( self.lockSize )

	if( self.lockIs ):
		if( self.isClass == "Console" ):
			self.lockHolds = self.lockIs.getAssignedCrewman()
		if( self.isClass == "Crew" ):
			self.lockHolds = self.lockIs.getGearAt( self.lockName )
	
	self.updateDisplay()

func _onDraggableCreated( itemObject , sourceLock ):

	if( self.myDraggableBeingDragged ):
		self.myDraggableBeingDragged = false
		return null # We do not want dragLocks change if they are the source of a drag event

	if( itemObject.is_class( self.holdsClass ) ):
		self.nodes.Image.set_self_modulate( self.DROPPABLE_COLOR )
		self.set_self_modulate( self.DROPPABLE_COLOR )
	else:
		self.nodes.Image.set_self_modulate( self.UNDROPPABLE_COLOR )
		self.set_self_modulate( self.UNDROPPABLE_COLOR )

func _onDraggableReleased( payload , sourceLock , droppedLocation : Vector2 ):
	if( self.lockHolds ):
		self.nodes.Image.set_self_modulate( self.EQUIPPED_COLOR )
		self.set_self_modulate( self.EQUIPPED_COLOR )
	else:
		self.nodes.Image.set_self_modulate( self.UNEQUIPPED_COLOR )
		self.set_self_modulate( self.UNEQUIPPED_COLOR )

	if( self.isInArea( droppedLocation ) ):
		self.eventBus.emit( "DraggableMatched" , [ payload, self , sourceLock ] )

func updateLock( newLockHolds = null ):
	self.lockHolds = newLockHolds
	self.updateDisplay()

	self.eventBus.emit( self.firesEvent , [ newLockHolds ] )

func updateDisplay():
	if( self.lockHolds ):
		if( self.holdsClass == "Crew" ):
			self.nodes.Image.set_texture( load( self.lockHolds.smallTexturePath ) )
		
		if( self.holdsClass == "Weapon" || self.holdsClass == "Frame" || self.holdsClass == "Equipment" ):
			self.nodes.Image.set_texture( load( self.lockHolds.itemTexturePath ) )

		self.set_self_modulate( self.EQUIPPED_COLOR )
		self.nodes.Image.set_self_modulate( self.EQUIPPED_COLOR )
	else:
		self.nodes.Image.set_texture( self.defaultTexture )
		self.nodes.Image.set_self_modulate( self.UNEQUIPPED_COLOR )

func isInArea( pos: Vector2 ):
	var rect = self.get_global_rect()
	
	if rect.has_point(pos):
		return true
	
	return false

func updateLockIs( lockIs ):
	self.lockIs = lockIs
	
	if( self.lockIs.has_method("getGearAt") ):
		self.lockHolds = self.lockIs.getGearAt( self.lockName )

	self.updateDisplay()

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) && self.lockHolds ):
		self._createDraggable( guiEvent , self.lockHolds )

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( self.DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( self.eventBus , payloadObject , self )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )
	self.myDraggableBeingDragged = true

	self.eventBus.emit( "DraggableCreated" , [ self.lockHolds , self.lockIs ] )