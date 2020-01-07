extends Effect

class_name HealingEffect

# filled by Json 
var healTrait = null
var healTraitMod = 0
var healBaseMod = 0

# Calculated values
var healTotalMod = 1

func get_class():
	return "HealingEffect"

func is_class( className ):
	return className == "HealingEffect"

func _calculateSelfSubclass( ability : Ability, actor: Crew ):
	if( healTrait ):
		var statBlock = actor.getTraitStatBlock( healTrait )
		var traitValue = statBlock.total

		healTotalMod = ( traitValue * healTraitMod ) + healBaseMod
	else:
		healTotalMod = healBaseMod

func _rollResult( ability : Ability , actor : Crew , numRolls : int ):
	var rolls = []

	for x in range( 0 , numRolls ):
		var healHi = ability.healingHiBase * healTotalMod
		var healLo = ability.healingLoBase * healTotalMod
		var healRoll = Common.randDiffValues( healLo , healHi )

		rolls.append( healRoll )

	return rolls

func _postDisplayEffect( ability : Ability ):
	var effectSubString = "Heals [color=green]{lo}-{hi} hp in a {area}"

	var healHi = ability.healingHiBase * healTotalMod
	var healLo = ability.healingLoBase * healTotalMod

	effectSubString = effectSubString.format({
		"hi" : str( healHi ) ,
		"lo" : str( healLo ) ,
		"area" : ability.getTargetTypeString()
	})

	return effectSubString