extends VBoxContainer

var eventBus = null
var ability = null

const ICON_COLORS = {
	"INVALID" : Color(.8 ,.4 , .4, 1) , 
	"VALID"	 : Color(.4 , .8 , .4 ,1)
}

onready var nodes = {
	"ActionName" : get_node("TitleRow/ActionName"),
	"ActionIcon" : get_node("TitleRow/ActionIcon"),
	"TargetArea" : get_node("HitDisplay/Label"),
	"RichText" 	: get_node("Detail"),
}

onready var validFrom = {
	"0" : get_node("HitDisplay/ValidFrom_0"),
	"1" : get_node("HitDisplay/ValidFrom_1"), 
	"2" : get_node("HitDisplay/ValidFrom_2"),
}

onready var validTargets = {
	"2" : get_node("HitDisplay/ValidTarget_2"),
	"1" : get_node("HitDisplay/ValidTarget_1"),
	"0" : get_node("HitDisplay/ValidTarget_0")
} 


func setupScene( ebus : EventBus , anAbility : Ability ):
	eventBus = ebus
	ability = anAbility

	if( is_inside_tree() && ability ):
		loadData( ability )

func _ready():
	pass

func loadData( newAbility : Ability ):
	ability = newAbility

	nodes.ActionName.set_text( ability.getFullName() )
	nodes.ActionIcon.set_texture( load( ability.getIconPath() ) )
	nodes.TargetArea.set_text( ability.getTargetTypeString() )
	nodes.RichText.set_text("We are testing some shit")

	var abilityValidFrom = ability.getValidFromArray()
	for key in validFrom:
		if( abilityValidFrom.has( int(key) ) ):
			validFrom[key].set_self_modulate( ICON_COLORS.VALID )
		else:
			validFrom[key].set_self_modulate( ICON_COLORS.INVALID )

	var abilityValidTargets = ability.getValidTargetsArray()
	for key in validTargets:
		if( abilityValidTargets.has( int(key) ) ):
			validTargets[key].set_self_modulate( ICON_COLORS.VALID )
		else:
			validTargets[key].set_self_modulate( ICON_COLORS.INVALID )




