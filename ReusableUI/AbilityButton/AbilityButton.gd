extends Button

var ability = null
var eventBus = null

func setupScene( eventBus : EventBus, ability : Ability , disabled ):
	self.eventBus = eventBus
	self.ability = ability

	self.set_disabled( disabled )
	self.set_button_icon( load( ability.getIconPath() ) )

func _onButtonClicked():
	print("button clicked!")
	print(self.ability.abilityType )
	print( self.ability.ABILITY_TYPES.ACTION )

	if( self.ability.abilityType == self.ability.ABILITY_TYPES.ACTION ):
		self.eventBus.emit("ActionButtonClicked" , [ self.ability ] )
	if( self.ability.abilityType == self.ability.ABILITY_TYPES.STANCE ):
		self.eventBus.emit("StanceButtonClicked" , [ self.ability ])

func toggleDisabled( true ):
	self.set_disabled( true )

func _ready():
	pass