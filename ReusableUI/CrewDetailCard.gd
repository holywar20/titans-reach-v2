extends PanelContainer

var eventBus
var crewman 

onready var dataRowScene = load("res://ReusableUI/DataRow/DataRow.tscn")

var labels = {
	"Armor" : get_node("VBox/Vitals/Right/Armor/ArmorName"),
	"Weapons" : get_node("VBox/Vitals/Right/Weapons/WeaponNames"),
	"Equipment" : get_node("VBox/Vitals/Right/Equipment/EquipmentNames")
}

var bars = {
	"HealthBar" : get_node("VBox/Vitals/Left/Health/Bar"),
	"HealthValue" : get_node("VBox/Vitals/Left/Health/Bar/Label"),
	"MoraleBar" : get_node("VBox/Vitals/Left/Morale/Bar"),
	"MoraleValue" : get_node("VBox/Vitals/Left/Morale/Value")
}

var bases = {
	"Buffs" : get_node("VBox/Bottom/Right/Buffs"),
	"Traits" : get_node("VBox/Bottom/Traits/Panel/Traits"),
	"StatusEffects" : get_node("VBox/Bottom/Right/StatusEffectPanel/StatusEffects")
}

func setupScene( ebus : EventBus , newCrewman : Crew ):
	eventBus = ebus
	crewman = newCrewman

func _ready():
	if( crewman ):
		loadData( crewman )

func loadData( crewman ):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
