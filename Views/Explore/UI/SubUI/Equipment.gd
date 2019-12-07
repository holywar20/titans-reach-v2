extends PanelContainer

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
	"Wep1" :  get_node(""),
	"Wep2" :  get_node(""),

	"Frame" :  get_node(""),

	"Equip1" : get_node(""),
	"Equip2" : get_node(""),
	"Equip3" : get_node("") 
}

func setupScene( eventBus : EventBus , parentNode ):
	self.eventBus = eventBus
	self.parentNode = parentNode

	self.crewman = self.parentNode.getCurrentCrewman()
	self.allGear = self.parentNode.getEquipableGear()

func _layoutGear():
	var itemIdx = { # Need to track indexes manually so I can append meta-data to the item
		"Frame" : 0 , "Equipment" : 0 , "Weapons" : 0
	}

	for key in self.allGear:
		var item = self.allGear[key]
		var display = item.itemDisplayNameShort + " x" + str( item.getRemaining() )

		if( item.is_class("Frame") ):
			self.bases.FrameList.add_item( display, load( item.itemTexturePath ), true )
			self.bases.FrameList.set_item_metadata( itemIdx.Frame , item )
			itemIdx.Frame = itemIdx.Frame + 1

	self.bases.FrameList.select( 0 ) 

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")
	self.loadCrewmanData( self.crewman )

	self._layoutGear()

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

func _onFrameGridItemActivate( idx ):
	var item = self.bases.FrameList.get_item_metadata( idx )
	self.eventBus.emit( "ItemSelected" , [ item ] )

func _onItemSelected( item ):

	self.nodes.ActionCard.hide()
	self.nodes.ItemCard.loadItemData( item )
	self.nodes.ItemCard.show()

func _onGeneralCancel():
	self.nodes.ActionCard.hide()
	self.nodes.ItemCard.hide()