extends Resource

class_name DmgEffect

const ROLL = {
	"damageRolls" : null , "toHitRolls"	: null , "animationKey" : null, "damageType" : "KINETIC"
}

# TODO - a bunch of work here is needed.
const HIT_STRING = "You rolled %s to hit %s, and you dealt %s %s dmg."
const MISS_STRING = "You rolled %s to hit %s. You missed."

const DMG_DISPLAY_STRING = "This attack deals %s damage to %s targets in an %area"
const HEAL_DISPLAY_STRING = ""

const SELF_DMG_STRING = ""
const SELF_HEAL_STRING = ""

var successString = null
var failString = null

const DMG_TYPES = { 
	'KINETIC'	: "KINETIC", 'THERMAL'	: "THERMAL", 'TOXIC'	: "TOXIC", 'EM' : "EM", 'HEALING': "HEALING"	,'NONE' 	: "NONE"
	}

const TRAITS = {
	"STR" : "STR" , "INT" : "INT" , "DEX" : "DEX" , "CHA" : "CHA"
}

# These should all be filled from saved params 
var dmgType = DMG_TYPES.KINETIC
var dmgTrait = null
var dmgTraitMod = null
var dmgBaseMod = 1

var toHitTrait = null
var toHitBaseMod = 0
var toHitTraitMod = 0

var alwaysHit = false
var targetArea = null
var targetType = null
var animationKeys = [ "DEFAULT" ] # TODO not sure how to ref these yet.

# Calculate self determines the value for these
var dmgTotalMod = 1
var toHitTotalMod = 0

func get_class():
	return "DmgEffect"

func is_class( className ):
	return className == "DmgEffect"

func _init():
	pass

func calculateSelf( ability : Ability , actor ):
	
	if( dmgTrait ):
		var statBlock = actor.getTraitStatBlock( dmgTrait )
		var traitValue = statBlock.total

		dmgTotalMod = ( traitValue * dmgTraitMod ) + dmgBaseMod
	else:
		dmgTotalMod = dmgBaseMod

	if( toHitTrait ):
		var statBlock = actor.getTraitStatBlock( toHitTrait )
		var traitValue = statBlock.total
		
		toHitTotalMod = ( traitValue * toHitTraitMod ) + toHitBaseMod
	else:
		toHitTotalMod = toHitBaseMod

func rollEffect( ability : Ability , actor : Crew ):
	calculateSelf( ability , actor )

	var rollSet = ROLL.duplicate()
	rollSet.damageRolls = []
	rollSet.toHitRolls = []
	rollSet.animationKey = animationKeys

	var numRolls = Ability.TARGET_AREA_DATA[targetArea].count

	for x in range( 0 , numRolls ):
		
		var dmgHi = ability.damageHiBase * dmgTotalMod
		var dmgLo = ability.damageLoBase * dmgTotalMod
		var dmgRoll = Common.randDiffValues( dmgLo, dmgHi )

		var toHitRoll = 0
		if( alwaysHit ):
			toHitRoll = Ability.MAX_TO_HIT
		else:
			toHitRoll = randi() % 99 + ( ability.toHitBase + toHitTotalMod )
		
		rollSet.damageRolls.append( dmgRoll )
		rollSet.toHitRolls.append( toHitRoll )

	return rollSet

func displayEffect():
	pass