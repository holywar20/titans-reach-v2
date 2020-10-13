extends PanelContainer

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"

const FRAME_DRAG_LOCK = "FrameDragLock"
const EQUIP_DRAG_LOCK = "EquipDragLock"
const WEAPON_DRAG_LOCK = "WeaponDragLock"

var eventBus = null
var parentNode = null
var crewman = null
var allGear = null

onready var nodes = {
	"VitalsCard"		: get_node("HBox/Left/VitalsCard"),
	"TraitsCard"		: get_node("HBox/Left/TraitCard") ,
	"ResistanceCard" 	: get_node("HBox/Left/ResistanceCard") ,
	
	"ActionCard"		:  get_node("HBox/Center/ActionCard") ,
	"ItemCard" 			: get_node("HBox/Center/ItemCard") , 

	"CrewmanName"		: get_node("HBox/Center/Crewman/Name"),
	"PaperDoll"			: get_node("")
}

onready var bases = {
	"WeaponList"		: get_node("HBox/Right/WeaponGrid"), 
	"FrameList"			: get_node("HBox/Right/FrameGrid"),
	"EquipmentList"	: get_node("HBox/Right/EquipmentGrid")
}

onready var locks = {
	"LWeapon" :  get_node("HBox/Center/Panel/LWeapon"),
	"RWeapon" :  get_node("HBox/Center/Panel/RWeapon"),

	"Frame" :  get_node("HBox/Center/Panel/Frame"),

	"LEquip" : get_node("HBox/Center/Panel/LEquip"),
	"CEquip" : get_node("HBox/Center/Panel/CEquip"),
	"REquip" : get_node("HBox/Center/Panel/REquip") 
}

func setupScene( eBus : EventBus , pNode ):
	eventBus = eBus
	parentNode = pNode

	crewman = parentNode.getCurrentCrewman()
	allGear = parentNode.getEquipableGear()

func _clearGear():
	bases.WeaponList.clear()
	bases.FrameList.clear()
	bases.EquipmentList.clear()

func _layoutGear():
	_clearGear()
	
	var itemIdx = { # Need to track indexes manually so I can append meta-data to the proper item index
		"Frames" : 0 , "Equipment" : 0 , "Weapons" : 0
	}

	for key in allGear:
		var item = allGear[key]
		if( item ):
			var display = item.itemDisplayNameShort + " x" + str( item.getRemaining() )
			
			if( item.is_class("Frame") && item.getRemaining() > 0 ):
				bases.FrameList.add_item( display, load( item.itemTexturePath ), true )
				bases.FrameList.set_item_metadata( itemIdx.Frames , item )
				itemIdx.Frames = itemIdx.Frames + 1

			if( item.is_class("Weapon") && item.getRemaining() > 0 ):
				bases.WeaponList.add_item( display , load( item.itemTexturePath) , true )
				bases.WeaponList.set_item_metadata( itemIdx.Weapons , item )
				itemIdx.Weapons = itemIdx.Weapons + 1

			if( item.is_class("Equipment") && item.getRemaining() > 0  ):
				bases.EquipmentList.add_item( display , load( item.itemTexturePath) , true )
				bases.EquipmentList.set_item_metadata( itemIdx.Equipment , item )
				itemIdx.Equipment = itemIdx.Equipment + 1
		else:
			print("Dev Error: Equipment Page: item is null for key" , item )

func _ready():
	eventBus.emit("SubUIAnyOpenEnd")
	loadCrewmanData( crewman )

	_layoutGear()

	for key in locks:
		locks[key].setEvents( eventBus )

	eventBus.register( "DraggableReleased" , self , "_onDraggableReleased" )
	eventBus.register( "ItemSelected" , self, "_onItemSelected" )
	eventBus.register( "GeneralCancel", self, "_onGeneralCancel" )

func loadCrewmanData( newCrewman = null ):
	# ON a null, assume this variable already exists. We want a fatal error if it's missing anyways
	if( newCrewman ):
		crewman = newCrewman
	
	nodes.CrewmanName.set_text( crewman.getFullName() )

	nodes.TraitsCard.loadData( crewman )
	nodes.ResistanceCard.loadData( crewman )
	nodes.VitalsCard.loadData( crewman )

	for key in locks:
		locks[key].updateLockIs( crewman )

func _onDraggableReleased( item, sourceLock : DragLock , droppedLoc : Vector2 ):
	var nodeGroup = null
	if item is Frame:
		nodeGroup = FRAME_DRAG_LOCK
	elif item is Weapon:
		nodeGroup = WEAPON_DRAG_LOCK
	elif item is Equipment:
		nodeGroup = EQUIP_DRAG_LOCK
	
	var targetLock = null
	for lock in get_tree().get_nodes_in_group( nodeGroup ):
		if( lock.isInArea( droppedLoc ) ):
			targetLock = lock
			break

	var success = false
	if( targetLock && sourceLock ):
		var oldItem = targetLock.lockHolds
		success = targetLock.lockIs.itemTransaction( item , targetLock.lockName, sourceLock.lockName )
		if( success ):
			targetLock.updateLock( item )
			sourceLock.updateLock( oldItem )

	elif( targetLock ):
		success = targetLock.lockIs.itemTransaction( item , targetLock.lockName, null )
		if( success ):
			targetLock.updateLock( item )
			
	elif( sourceLock ):
		success = sourceLock.lockIs.itemTransaction( null , sourceLock.lockName, null )
		if( success ):
			sourceLock.updateLock()

	if( success ):
		_layoutGear()
		loadCrewmanData()

# Buttons
func _onNextPressed():
	crewman = parentNode.getNextCrewman()
	loadCrewmanData( crewman )

func _onPrevPressed():
	crewman = parentNode.getPrevCrewman()
	loadCrewmanData( crewman )

func _onWeaponGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = bases.WeaponList.get_item_at_position( guiEvent.position )
		var item = bases.WeaponList.get_item_metadata( itemIdx )

		if( item ):
			_createDraggable( guiEvent , item )
			eventBus.emit("ItemSelected" , [ item ] )

func _onFrameGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = bases.FrameList.get_item_at_position( guiEvent.position )
		var item = bases.FrameList.get_item_metadata( itemIdx )

		if( item ):
			_createDraggable( guiEvent , item )
			eventBus.emit("ItemSelected" , [ item ] )

func _onEquipmentGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = bases.EquipmentList.get_item_at_position( guiEvent.position )
		var item = bases.EquipmentList.get_item_metadata( itemIdx )

		if( item ):
			_createDraggable( guiEvent , item )
			eventBus.emit("ItemSelected" , [ item ] )

func _onItemSelected( item ):
	nodes.ActionCard.hide()
	nodes.ItemCard.loadItemData( item )
	nodes.ItemCard.show()

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( eventBus , payloadObject )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )

	eventBus.emit( "DraggableCreated" , [ payloadObject , null ] )
	
func _onGeneralCancel():
	nodes.ActionCard.hide()
	nodes.ItemCard.hide()





