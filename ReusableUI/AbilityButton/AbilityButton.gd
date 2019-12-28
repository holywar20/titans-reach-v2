extends Button

var ability = null
var eventBus = null

func setupScene( eBus : EventBus, newAbility : Ability , disabled ):
	eventBus = eBus
	ability = newAbility

	set_disabled( disabled )
	set_button_icon( load( ability.getIconPath() ) )

func _onButtonClicked():
	if( ability.abilityType == ability.ABILITY_TYPES.ACTION ):
		eventBus.emit("ActionButtonClicked" , [ ability ] )
	if( ability.abilityType == ability.ABILITY_TYPES.STANCE ):
		eventBus.emit("StanceButtonClicked" , [ ability ])

func toggleDisabled( true ):
	set_disabled( true )

func _ready():
	pass