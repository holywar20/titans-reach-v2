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
const UNEQUIPPED_COLOR = Color( .2 , .2 , .2 , 1 )
const DROPPABLE_COLOR = Color( .6 , 1 , .6 , 1 )
const UNDROPPABLE_COLOR = Color( 1 , .6, .6 , 1)

var eventBus : EventBus

var lockHolds = null 
var lockIs = null

# should only need to call this method if dynamically creating the lock.
func setupScene( eBus : EventBus , lock , rel : int , lName : String, dName = "" ):
	eventBus = eBus
	lockIs = lock
	displayName = dName
	lockName = lName

	var myRelationship = RELATIONSHIP_DATA[rel]
	for key in myRelationship:
		set( key , myRelationship[key] )

	# Stupid I know, but I want to be able to preload textures inside the interface, but store them as strings in the list
	defaultTexture = load( defaultTexture )

	if( is_inside_tree() ):
		setEvents()

func _ready():
	if( isClass ):
		_loadData()
		setEvents()

func setEvents( newEventBus = null ):
	if( newEventBus ):
		eventBus = newEventBus

	if( eventBus ):
		eventBus.register( "DraggableCreated" , self , "_onDraggableCreated" )
		eventBus.register( "DraggableReleased" , self , "_onDraggableReleased" )

# Loads data from setupScene OR the export view, and calculates it all.
func _loadData():
	set_size( lockSize )
	
	nodes.Image.set_size( textureSize )
	nodes.Image.set_texture( defaultTexture )
	nodes.Name.set_text( displayName )

	if( showsDescription ):
		nodes.Name.set_text( displayName )
	else:
		nodes.Name.hide()

	if( nodeGroup ):
		add_to_group( nodeGroup )

	set_size( lockSize )

	if( lockIs ):
		if( isClass == "Console" ):
			lockHolds = lockIs.getAssignedCrewman()
		if( isClass == "Crew" ):
			lockHolds = lockIs.getGearAt( lockName )
	
	updateDisplay()

func _onDraggableCreated( itemObject , sourceLock ):

	if( myDraggableBeingDragged ):
		myDraggableBeingDragged = false
		return null # We do not want dragLocks change if they are the source of a drag event

	if( itemObject.is_class( holdsClass ) ):
		nodes.Image.set_self_modulate( DROPPABLE_COLOR )
		set_self_modulate( DROPPABLE_COLOR )
	else:
		nodes.Image.set_self_modulate( UNDROPPABLE_COLOR )
		set_self_modulate( UNDROPPABLE_COLOR )

func _onDraggableReleased( payload , sourceLock , droppedLocation : Vector2 ):
	if( lockHolds ):
		nodes.Image.set_self_modulate( EQUIPPED_COLOR )
		set_self_modulate( EQUIPPED_COLOR )
	else:
		nodes.Image.set_self_modulate( UNEQUIPPED_COLOR )
		set_self_modulate( UNEQUIPPED_COLOR )

	if( isInArea( droppedLocation ) ):
		eventBus.emit( "DraggableMatched" , [ payload, self , sourceLock ] )

func updateLock( newLockHolds = null ):
	lockHolds = newLockHolds
	updateDisplay()

	eventBus.emit( firesEvent , [ newLockHolds ] )

func updateDisplay():
	if( lockHolds ):
		if( holdsClass == "Crew" ):
			nodes.Image.set_texture( load( lockHolds.smallTexturePath ) )
		
		if( holdsClass == "Weapon" || holdsClass == "Frame" || holdsClass == "Equipment" ):
			nodes.Image.set_texture( load( lockHolds.itemTexturePath ) )

		set_self_modulate( EQUIPPED_COLOR )
		nodes.Image.set_self_modulate( EQUIPPED_COLOR )
	else:
		nodes.Image.set_texture( defaultTexture )
		nodes.Image.set_self_modulate( UNEQUIPPED_COLOR )

func isInArea( pos: Vector2 ):
	var rect = get_global_rect()
	
	if rect.has_point(pos):
		return true
	
	return false

func updateLockIs( newLockIs ):
	lockIs = newLockIs
	
	if( lockIs.has_method("getGearAt") ):
		lockHolds = lockIs.getGearAt( lockName )

	updateDisplay()

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) && lockHolds ):
		_createDraggable( guiEvent , lockHolds )

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( eventBus , payloadObject , self )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )
	myDraggableBeingDragged = true

	eventBus.emit( "DraggableCreated" , [ lockHolds , lockIs ] )