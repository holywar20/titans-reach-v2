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

func setupScene( eventBus : EventBus , parentNode ):
	self.eventBus = eventBus
	self.parentNode = parentNode

	self.crewman = self.parentNode.getCurrentCrewman()
	self.allGear = self.parentNode.getEquipableGear()

func _clearGear():
	self.bases.WeaponList.clear()
	self.bases.FrameList.clear()
	self.bases.EquipmentList.clear()

func _layoutGear():
	self._clearGear()
	
	var itemIdx = { # Need to track indexes manually so I can append meta-data to the proper item index
		"Frames" : 0 , "Equipment" : 0 , "Weapons" : 0
	}

	for key in self.allGear:
		var item = self.allGear[key]
		var display = item.itemDisplayNameShort + " x" + str( item.getRemaining() )

		if( item.is_class("Frame") && item.getRemaining() > 0 ):
			self.bases.FrameList.add_item( display, load( item.itemTexturePath ), true )
			self.bases.FrameList.set_item_metadata( itemIdx.Frames , item )
			itemIdx.Frames = itemIdx.Frames + 1

		if( item.is_class("Weapon") && item.getRemaining() > 0 ):
			self.bases.WeaponList.add_item( display , load( item.itemTexturePath) , true )
			self.bases.WeaponList.set_item_metadata( itemIdx.Weapons , item )
			itemIdx.Weapons = itemIdx.Weapons + 1

		if( item.is_class("Equipment") && item.getRemaining() > 0  ):
			self.bases.EquipmentList.add_item( display , load( item.itemTexturePath) , true )
			self.bases.EquipmentList.set_item_metadata( itemIdx.Equipment , item )
			itemIdx.Equipment = itemIdx.Equipment + 1

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")
	self.loadCrewmanData( self.crewman )

	self._layoutGear()

	for key in self.locks:
		self.locks[key].setEvents( self.eventBus )

	self.eventBus.register( "DraggableReleased" , self , "_onDraggableReleased" )
	self.eventBus.register( "ItemSelected" , self, "_onItemSelected" )
	self.eventBus.register( "GeneralCancel", self, "_onGeneralCancel" )

func loadCrewmanData( crewman = null ):
	# ON a null, assume this variable already exists. We want a fatal error if it's missing anyways
	if( crewman ):
		self.crewman = crewman
	
	self.nodes.CrewmanName.set_text( self.crewman.getFullName() )

	self.nodes.TraitsCard.loadData( self.crewman )
	self.nodes.ResistanceCard.loadData( self.crewman )
	self.nodes.VitalsCard.loadData( self.crewman )

	for key in self.locks:
		self.locks[key].updateLockIs( self.crewman )

func _onDraggableReleased( item, sourceLock : DragLock , droppedLoc : Vector2 ):
	print( "Firing!" )
	
	var nodeGroup = null
	if( item.is_class("Frame") ):
		nodeGroup = self.FRAME_DRAG_LOCK
	elif( item.is_class("Weapon") ):
		nodeGroup = self.WEAPON_DRAG_LOCK
	elif( item.is_class("Equipment") ):
		nodeGroup = self.EQUIP_DRAG_LOCK
	
	var targetLock = null
	for lock in get_tree().get_nodes_in_group( nodeGroup ):
		if( lock.isInArea( droppedLoc ) ):
			targetLock = lock
			break

	var success = false
	if( targetLock && sourceLock ):
		print( targetLock , sourceLock )
		var oldItem = targetLock.lockHolds
		success = targetLock.lockIs.itemTransaction( item , targetLock.lockName, sourceLock.lockName )
		if( success ):
			targetLock.updateLock( item )
			sourceLock.updateLock( oldItem )

	elif( targetLock ):
		print( targetLock , sourceLock )
		success = targetLock.lockIs.itemTransaction( item , targetLock.lockName, null )
		if( success ):
			targetLock.updateLock( item )
			
	elif( sourceLock ):
		print( targetLock , sourceLock )
		success = sourceLock.lockIs.itemTransaction( null , sourceLock.lockName, null )
		if( success ):
			sourceLock.updateLock()

	if( success ):
		self._layoutGear()
		self.loadCrewmanData()

# Buttons
func _onNextPressed():
	self.crewman = self.parentNode.getNextCrewman()
	self.loadCrewmanData( self.crewman )

func _onPrevPressed():
	self.crewman = self.parentNode.getPrevCrewman()
	self.loadCrewmanData( self.crewman )

func _onWeaponGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.WeaponList.get_item_at_position( guiEvent.position )
		var item = self.bases.WeaponList.get_item_metadata( itemIdx )

		if( item ):
			self._createDraggable( guiEvent , item )
			self.eventBus.emit("ItemSelected" , [ item ] )

func _onFrameGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.FrameList.get_item_at_position( guiEvent.position )
		var item = self.bases.FrameList.get_item_metadata( itemIdx )

		if( item ):
			self._createDraggable( guiEvent , item )
			self.eventBus.emit("ItemSelected" , [ item ] )

func _onEquipmentGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.EquipmentList.get_item_at_position( guiEvent.position )
		var item = self.bases.EquipmentList.get_item_metadata( itemIdx )

		if( item ):
			self._createDraggable( guiEvent , item )
			self.eventBus.emit("ItemSelected" , [ item ] )

func _onItemSelected( item ):
	self.nodes.ActionCard.hide()
	self.nodes.ItemCard.loadItemData( item )
	self.nodes.ItemCard.show()

func _createDraggable( guiEvent : InputEvent , payloadObject ):
	var draggableScene = load( self.DRAGGABLE_SCENE_PATH )
	var draggable = draggableScene.instance()
	draggable.setScene( self.eventBus , payloadObject )
	draggable.set_global_position( guiEvent.position )

	var draggableLayer = get_node( Common.DRAGGABLE_LAYER )
	draggableLayer.add_child( draggable )

	self.eventBus.emit( "DraggableCreated" , [ payloadObject , null ] )
	
func _onGeneralCancel():
	self.nodes.ActionCard.hide()
	self.nodes.ItemCard.hide()





