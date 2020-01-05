extends PanelContainer

var eventBus
var crewman 
var prevCrewman

export(bool) var respondsToHoverEvents = false
export(bool) var isPlayer = false

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")

onready var nodes = {
	"Name" : get_node("VBox/Name"),
	"Icon" : get_node("VBox/Vitals/Icon"),
	"Armor" : get_node("VBox/Vitals/Right/Armor/ArmorName"),
	"Weapons" : get_node("VBox/Vitals/Right/Weapons/WeaponNames"),
	"Equipment" : get_node("VBox/Vitals/Right/Equipment/EquipmentNames")
}

onready var bars = {
	"HealthBar" : get_node("VBox/Vitals/Left/Health/Bar"),
	"HealthValue" : get_node("VBox/Vitals/Left/Health/Bar/Value"),
	"MoraleBar" : get_node("VBox/Vitals/Left/Morale/Bar"),
	"MoraleValue" : get_node("VBox/Vitals/Left/Morale/Bar/Value")
}

onready var bases = {
	"Buffs" : get_node("VBox/Bottom/Right/BuffPanel/Buffs"),
	"Traits" : get_node("VBox/Bottom/Traits/Panel/Traits"),
	"StatusEffects" : get_node("VBox/Bottom/Right/StatusEffectPanel/StatusEffects")
}

func setupScene( ebus : EventBus , newCrewman : Crew ):
	eventBus = ebus
	crewman = newCrewman

	if( is_inside_tree() && crewman ):
		loadData( crewman )

	if( respondsToHoverEvents ):
		eventBus.register( "HoverCrewman" , self , "_onHoverCrewman")
		eventBus.register( "UnhoverCrewman" , self, "_onUnhoverCrewman")

func _ready():
	hide()

	if( crewman ):
		loadData( crewman )

func loadData( newCrewman = null ):
	crewman = newCrewman

	if( newCrewman ):
		show()

		nodes.Name.set_text( crewman.getFullName() )
		nodes.Icon.set_texture( load( crewman.getTexturePath() ) )

		nodes.Armor.set_text( PoolStringArray( crewman.getAllFrameStrings() ).join(" , ") )
		nodes.Weapons.set_text( PoolStringArray( crewman.getAllWeaponStrings() ).join(" , ") )
		nodes.Equipment.set_text( PoolStringArray( crewman.getAllEquipmentStrings() ).join(" , ") )

		var hp = crewman.getHPStatBlock()
		bars.HealthBar.set_max( hp.total )
		bars.HealthBar.set_value( hp.current )
		bars.HealthValue.set_text( crewman.getHitPointString() )

		var morale = crewman.getMoraleStatBlock()
		bars.MoraleBar.set_max( morale.total )
		bars.MoraleBar.set_value( morale.current )
		bars.MoraleValue.set_text( crewman.getMoraleString() )
	else:
		hide()

func _onHoverCrewman( newCrewman : Crew ):
	if( isPlayer == newCrewman.isPlayer ):
		prevCrewman = crewman
		loadData( newCrewman )

func _onUnhoverCrewman( newCrewman : Crew ):
	if( isPlayer == newCrewman.isPlayer ):
		loadData( prevCrewman )