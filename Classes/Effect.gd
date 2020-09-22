extends Resource

class_name Effect

const TRAITS = {
	"STR" : "STR" , "INT" : "INT" , "DEX" : "DEX" , "CHA" : "CHA"
}

const EFFECT_TYPES = {
	"DAMAGE" : "DAMAGE" , "HEALING" : "HEALING"
}

# Filled by DB
var key : String = "NONE"
var effectType : String = "DAMAGE"
var toHitTrait : String
var toHitBaseMod : float =  0.0
var toHitTraitMod : float = 0.0

# effectType - Damage
var dmgType : String
var dmgBaseMod : float
var dmgTrait : String 
var dmgTraitMod : float

# effectType - Healing
var healBaseMod : float
var healTrait : String
var healTraitMod : float

# effectType - Status Effects
var statusEffect : String
var statusEffectTrait : String
var statusEffectBaseMod : float
var statusEffectTraitMod : float

# effectType - Movement
# TODO - figure out how to define this.likely just a constant with some behavior attached to it.
# IE Pull, Push + a vector, or free move ( user selects )

# effectType - Status effect
var targetArea : String = "SELF"
var targetType : String = "SELF"
var animationKey : String = ""

# Calculated values 
var alwaysHit = false
var toHitTotalMod = 0
var toHitRolls = []
var resultRolls = []
var fullDisplay = ""

func get_class():
	return "Effect"

func is_class( className ):
	return className == "Effect"

func _init( effectDict : Dictionary ):
	
	key = effectDict.key
	effectType = effectDict.effectType as String
	toHitTrait = effectDict.toHitTrait as String
	toHitBaseMod = effectDict.toHitBaseMod as float
	toHitTraitMod = effectDict.toHitTraitMod as float
	targetType = effectDict.targetType as String
	targetArea = effectDict.targetArea as String
	animationKey = effectDict.animationKey as String

	match effectType:
		"DAMAGE":
			dmgType  = effectDict.dmgType
			dmgBaseMod = effectDict.dmgBaseMod
			dmgTrait = effectDict.dmgTrait
			dmgTraitMod = effectDict.dmgTraitMod
		"HEALING":
			healBaseMod = effectDict.healBaseMod
			healTrait = effectDict.healTrait
			healTraitMod = effectDict.healTraitMod
		"STATUS":
			statusEffect = effectDict.statusEffect
			statusEffectTrait = effectDict.statusEffectTrait
			statusEffectBaseMod = effectDict.statusEffectBaseMod
			statusEffectTraitMod = effectDict.statusEffectTraitMod
	
	print( self )


func calculateSelf( ability : Ability , actor : Crew ):
	if( toHitTrait ):
		var statBlock = actor.getTraitStatBlock( toHitTrait )
		var traitValue = statBlock.total
		
		toHitTotalMod = ( traitValue * toHitTraitMod ) + toHitBaseMod
	else:
		toHitTotalMod = toHitBaseMod

	_postCalculateSelf( ability , actor  )

# Override for any preexecution calculation
func _postCalculateSelf( ability : Ability , actor : Crew ):
	pass

func rollEffect( ability : Ability , actor : Crew ):
	calculateSelf( ability , actor )
	
	var numRolls = Ability.TARGET_AREA_DATA[targetArea].count
	toHitRolls  = _rollToHit( ability , actor , numRolls )
	resultRolls = _rollResult( ability , actor , numRolls )

# Override for any rolls you want this effect to store
func _rollResult( ability : Ability , actor : Crew , numRolls : int ):
	return []

func _rollToHit( ability : Ability , actor : Crew , numRolls : int ):
	var rolls = []
	
	for x in range( 0 , numRolls ):
		var toHitRoll = 0
		if( alwaysHit ):
			toHitRoll = Ability.MAX_TO_HIT
		else:
			toHitRoll = randi() % 99 + ( ability.toHitBase + toHitTotalMod )
			rolls.append( toHitRoll )
			
	return rolls

func displayAbilityResult( ability : Ability  ):
	pass 

func _postDisplayAbilityResolt( ability : Ability ):
	pass

func displayEffect( ability : Ability ):
	var totalString = "{toHit}% to hit."

	var total = ability.toHitBase + toHitTotalMod
	totalString = totalString.format( { "toHit" : int( total ) } ) + _postDisplayEffect( ability )

	return totalString

# Override to add a display line to this effect
func _postDisplayEffect( ability : Ability ):
	var effectSubString = ""

	return effectSubString
