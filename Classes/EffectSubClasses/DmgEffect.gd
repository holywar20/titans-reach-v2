extends Effect

class_name DmgEffect

const DMG_TYPES = { "KINETIC": "KINETIC" , "CORROSIVE": "CORROSIVE" , "THERMAL": "THERMAL" , "EM" : "EM" }
const DMG_TYPES_DATA = { 
	'KINETIC'	: { "color": "gray" , "string" : "Kinetic" }, 
	'THERMAL'	: { "color": "red" , "string" : "Thermal" }, 
	'CORROSIVE'	: { "color": "lime" , "string" : "Corrosive" }, 
	'EM' 			: { "color": "blue" , "string" : "EM" }
	}

# filled by Json 
var damageType = DMG_TYPES.KINETIC
var dmgTrait = null
var dmgTraitMod = 0
var dmgBaseMod = 1

# Calculated values
var dmgTotalMod = 1

func get_class():
	return "DmgEffect"

func is_class( className ):
	return className == "DmgEffect"

func _postCalculateSelf( ability : Ability , actor : Crew ):
	if( dmgTrait ):
		var statBlock = actor.getTraitStatBlock( dmgTrait )
		var traitValue = statBlock.total

		dmgTotalMod = ( traitValue * dmgTraitMod ) + dmgBaseMod
	else:
		dmgTotalMod = dmgBaseMod

func _rollResult( ability : Ability , actor : Crew , numRolls : int ):
	var rolls = []

	for x in range( 0 , numRolls ):
		var dmgHi = ability.damageHiBase * dmgTotalMod
		var dmgLo = ability.damageLoBase * dmgTotalMod
		var dmgRoll = Common.randDiffValues( dmgLo, dmgHi )

		rolls.append( dmgRoll )

	return rolls

# Override to add a display line to this effect
func _postDisplayEffect( ability : Ability ):
	var effectSubString = " Deals [color=red]{lo}-{hi}[/color] [color={dmgColor}]{dmgType}[/color] Damage in a {area}"

	var dmgHi = ability.damageHiBase * dmgTotalMod
	var dmgLo = ability.damageLoBase * dmgTotalMod

	effectSubString = effectSubString.format({
		"hi" : str( int(dmgHi) ) ,
		"lo" : str( int(dmgLo) ) ,
		"dmgType" : _getDmgTypeString(),
		"dmgColor" : _getDmgTypeColor(),
		"area" : ability.getTargetTypeString()
	})

	return effectSubString

# Internal methods specific to this effect.
func _getDmgTypeString():
	return DMG_TYPES_DATA[damageType].string

func _getDmgTypeColor():
	return DMG_TYPES_DATA[damageType].color