extends PanelContainer

const DRAGGABLE_SCENE_PATH = "res://ReusableUI/Draggable/Draggable.tscn"

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
	"LWeapon" :  get_node("HBox/Center/Panel/TextureRect/LWeapon"),
	"RWeapon" :  get_node("HBox/Center/Panel/TextureRect/RWeapon"),

	"Frame" :  get_node("HBox/Center/Panel/TextureRect/Frame"),

	"LEquip" : get_node("HBox/Center/Panel/TextureRect/LEquip"),
	"CEquip" : get_node("HBox/Center/Panel/TextureRect/CEquip"),
	"REquip" : get_node("HBox/Center/Panel/TextureRect/REquip") 
}

func setupScene( eventBus : EventBus , parentNode ):
	self.eventBus = eventBus
	self.parentNode = parentNode

	self.crewman = self.parentNode.getCurrentCrewman()
	self.allGear = self.parentNode.getEquipableGear()

func _layoutGear():
	var itemIdx = { # Need to track indexes manually so I can append meta-data to the proper item index
		"Frames" : 0 , "Equipment" : 0 , "Weapons" : 0
	}

	for key in self.allGear:
		var item = self.allGear[key]
		var display = item.itemDisplayNameShort + " x" + str( item.getRemaining() )

		if( item.is_class("Frame") ):
			self.bases.FrameList.add_item( display, load( item.itemTexturePath ), true )
			self.bases.FrameList.set_item_metadata( itemIdx.Frames , item )
			itemIdx.Frames = itemIdx.Frames + 1

		if( item.is_class("Weapon") ):
			self.bases.WeaponList.add_item( display , load( item.itemTexturePath) , true )
			self.bases.WeaponList.set_item_metadata( itemIdx.Weapons , item )
			itemIdx.Weapons = itemIdx.Weapons + 1

		if( item.is_class("Equipment") ):
			self.bases.EquipmentList.add_item( display , load( item.itemTexturePath) , true )
			self.bases.EquipmentList.set_item_metadata( itemIdx.Equipment , item )
			itemIdx.Equipment = itemIdx.Equipment + 1

	self.bases.FrameList.select( 0 ) 

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")
	self.loadCrewmanData( self.crewman )

	self._layoutGear()

	self.locks.Frame.setupScene( self.eventBus , self.crewman , DragLock.RELATIONSHIPS.FRAME_CREW , "Frame" )
	self.locks.LWeapon.setupScene( self.eventBus , self.crewman, DragLock.RELATIONSHIPS.WEAPON_CREW , "Weapon" )
	self.locks.RWeapon.setupScene( self.eventBus ,self.crewman, DragLock.RELATIONSHIPS.WEAPON_CREW , "Weapon" )
	self.locks.LEquip.setupScene( self.eventBus ,self.crewman, DragLock.RELATIONSHIPS.EQUIPMENT_CREW , "Equip." )
	self.locks.CEquip.setupScene( self.eventBus ,self.crewman, DragLock.RELATIONSHIPS.EQUIPMENT_CREW , "Equip." )
	self.locks.REquip.setupScene( self.eventBus ,self.crewman, DragLock.RELATIONSHIPS.EQUIPMENT_CREW , "Equip.")

	self.eventBus.register( "ItemSelected" , self, "_onItemSelected" )
	self.eventBus.register( "GeneralCancel", self, "_onGeneralCancel" )

func loadCrewmanData( crewman : Crew ):
	self.nodes.CrewmanName.set_text( crewman.getFullName() )

	self.nodes.TraitsCard.loadData( crewman )
	self.nodes.ResistanceCard.loadData( crewman )
	self.nodes.VitalsCard.loadData( crewman )

# Buttons
func _onNextPressed():
	self.crewman = self.parentNode.getNextCrewman()
	self.loadCrewmanData( self.crewman )

func _onPrevPressed():
	self.crewman = self.parentNode.getPrevCrewman()
	self.loadCrewmanData( self.crewman )

func _onWeaponGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.WeaponList.get_item_at_position( guiEvent.get_global_position() )
		var item = self.bases.WeaponList.get_item_metadata( itemIdx )

		if( item ):
			self._createDraggable( guiEvent , item )
			self.eventBus.emit("ItemSelected" , [ item ] )

func _onFrameGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.FrameList.get_item_at_position( guiEvent.get_global_position() )
		var item = self.bases.FrameList.get_item_metadata( itemIdx )

		if( item ):
			self._createDraggable( guiEvent , item )
			self.eventBus.emit("ItemSelected" , [ item ] )

func _onEquipmentGridGuiInput( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) ):
		var itemIdx = self.bases.EquipmentList.get_item_at_position( guiEvent.get_global_position() )
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
	
func _onGeneralCancel():
	self.nodes.ActionCard.hide()
	self.nodes.ItemCard.hide()





