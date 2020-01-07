extends Resource

class_name Effect

const TRAITS = {
	"STR" : "STR" , "INT" : "INT" , "DEX" : "DEX" , "CHA" : "CHA"
}

# Filled by Json
var toHitTrait = null
var toHitBaseMod = 0
var toHitTraitMod = 0

var alwaysHit = false
var targetArea = null
var targetType = null
var animationKeys = [] 

# Calculated values 
var toHitTotalMod = 0
var toHitRolls = []
var resultRolls = []
var fullDisplay = ""

func get_class():
	return "Effect"

func is_class( className ):
	return className == "Effect"

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