extends Node

class_name Ability

const USE_TRAIT = true 
const NO_USE_TRAIT = false 

const ABILITY_TYPES = { 
	"STANCE" : "STANCE", 
	"INSTANT": "INSTANT", 
	"ACTION" : "ACTION",  
	"TRIGGERED" : "TRIGGERED", 
	"PASSIVE" : "PASSIVE" 
}

const DMG_TYPES = { 
	'KINETIC'	: "KINETIC", 'THERMAL'	: "THERMAL", 'TOXIC'	: "TOXIC", 'EM' : "EM", 'HEALING'	: "HEALING"	,'NONE' 		: "NONE"
}

const EFFECT_TYPE = {
	"DAMAGE" 	: "Damage" , 
	"HEALING"	: "Healing", 
	"STATUS"		: "Status", 
	"PASSIVE"	: "Passive", 
}

const TARGET_AREA = {
	"SELF" 	: "SELF" , "SINGLE" : "SINGLE" ,"COLUMN" : "COLUMN", "ROW" 	: "ROW" , "ROW_DECAY" : "ROW_DECAY", "CROSS" : "CROSS", "ALL" :  "ALL"
}
const TARGET_AREA_DATA = {
	"SELF"	: { 
		"count" 	: 1 , 
		"string" : "Self" ,
		"targetMatrix"	: null
	},
	"SINGLE" : { 	
		"count" : 1 , 
		"string" : "Single" ,
		"targetMatrix" : [ [ 0 , 0 , 0 ] , [ 0 , 1 , 0 ] , [ 0 , 0 , 0 ] ],
	},
	"COLUMN"		: { 
		"count" : 3 , 
		"string" : "Self" ,
		"targetMatrix" : [ [ 0 , 1 , 0 ] , [ 0 , 1 , 0 ] , [ 0 , 1 , 0 ] ],
	},
	"ROW" 		: { 
		"count" : 3 , 
		"string" : "Row" ,
		"targetMatrix" : [ [ 0 , 0 , 0 ] , [ 1 , 1 , 1 ] , [ 0 , 0 , 0 ] ],
	},
	"ROW_DECAY"	: { 
		"count" : 2 , 
		"string" : "Row Decay" ,
		"targetMatrix" : [ [ 0 , 0 , 0 ] , [ 0 , 1 , 1 ] , [ 0 , 0 , 0 ] ],
	},
	"CROSS" 		: { 
		"count" : 5 , 
		"string" : "Cross" ,
		"targetMatrix" : [ [ 0 , 1 , 0 ] , [ 1 , 1 , 1 ] , [ 0 , 1 , 0 ] ],
	},
	"ALL" 		: { 
		"count" : 9 , 
		"string" : "All" ,
		"targetMatrix" :[ [ 1 , 1 , 1 ] , [ 1 , 1 , 1 ] , [ 1 , 1 , 1 ] ],
	},
}

const TARGET_TYPES  = {
	'ALLY_UNITS' : 'ALLY_UNITS' ,'ENEMY_UNIT' :'ENEMY_UNIT', 'ALLY_FLOOR' : 'ALLY_FLOOR' ,'ENEMY_FLOOR': 'ENEMY_FLOOR', 'SELF' : 'SELF'
}
const TARGET_TYPE_DATA = {
	"ALLY_UNIT" : { "string" : "Ally Units" },
	"ENEMY_UNIT" : { "string" : "Enemy Units" },
	"ALLY_FLOOR" : { "string" : "Ally Area"} ,
	"ENEMY_FLOOR" : { "string" : "Enemy Area"},
	"SELF" : { "string" :"Self" }
}

const DMG_TRAITS = { 
	'STR' : 'STR', 'DEX' : 'DEX', 'CHA' : 'CHA', 'PER' : 'PER', 'INT' : 'INT' , 'ALWAYS' : 'ALWAYS'
}
const HIT_TRAITS = { 
	'STR' : 'STR', 'DEX' : 'DEX', 'CHA' : 'CHA', 'PER' : 'PER', 'INT' : 'INT' , 'ALWAYS' : 'ALWAYS'
}

const MOVE_EFFECT_PROTOTYPE = {
	'moveType'		: null,
	'toHitTrait'	: null,
	'toHitMod' 		: null,
	'toHit'			: null,
	'targetType'	: null,
	'targetArea'	: null,
	'forcedMovement': false,
}

const DMG_EFFECT_PROTOTYPE = {
	'dmgTrait'		: null,
	'dmgTraitMod'	: null,
	'dmgType'		: null,
	'dmgMod'			: 0,
	'dmgTotal'		: null,
	'toHitTrait'	: null,
	'toHitMod'		: null,
	'toHitTotal'	: 0,
	'targetArea'	: null,
	'targetType'	: null,
	'duration'		: null
}

const STATUS_EFFECT_PROTOTYPE = {
	'statusEffect'	: null,
	'toHitTrait'	: null,
	'toHitMod'		: null,
	'targetArea'	: null,
	'targetType'	: null
}

const PASSIVE_EFFECT_PROTOTYPE = {
	'passiveEffect'	: null, 
	'passiveAmount'	: null,
	'passiveTrait' 	: null,
	'toHitTrait'		: null,
	'toHitMod'			: null,
	'targetArea'		: null,
	'targetType'		: null,
	'duration'			: null
}

const ROLL_PROTOTYPE = {

}

const MAX_TO_HIT = 200
const BASE_TO_HIT = 80
const TO_HIT_TRAIT_BONUS = 3
const HI_DMG_TRAIT_MOD = 1
const LO_DMG_TRAIT_MOD = .5

# Meta data. This is loaded from a dictionary and should be validated.
var key = null
var shortName = null
var fullName = null
var abilityType = null
var damageHiBase = null
var damageLoBase = null
var toHitBase = null
var validTargets = null
var validFrom = null
var targetType = null
var targetArea = null
var iconPath = null

var damageEffects = []
var statusEffects = []
var passiveEffects = []
var healingEffects = []
var movementEffects = []

# Data that will mutate and change. 
var abilityLearned = false
var dmgHiTotal = 0
var dmgLoTotal = 0
var toHitTotal = 0
var actor = null

func _init():
	pass

func setActor( newActor : Crew ):
	actor = newActor

func appendEffect( effect , effectType ):
	match effectType:
		"Damage":
			damageEffects.append( effect )
		"Healing":
			healingEffects.append( effect )
		"Status" :
			statusEffects.append( effect )
		"Passive":
			statusEffects.append( effect )

func getValidFromArray():
	return validFrom

func getValidTargetsArray():
	return validTargets

func getFullName():
	return fullName

func getTargetType():
	return targetType

func getIconPath():
	return iconPath

func getTargetTypeString():
	var targetTypeString = TARGET_TYPE_DATA[targetType].string
	var myTargetArea = TARGET_AREA_DATA[targetArea].string
	
	return myTargetArea + " | " + targetTypeString

# Note should is also used for an action validity test. 
func getValidTargets():
	var targetingArray = [ [ false , false , false ] , [ false, false , false] , [ false, false, false] ]

	for x in range(0 , targetingArray.size() ):
		for y in range( 0 , targetingArray[x].size() ):
			if( validTargets.has( y ) ):
				targetingArray[x][y] = true
		
	return targetingArray

# Figures out which targets would be valid, based upon x ,y grid coordinates
func getOffsetMatrix( myX , myY ):
	var template = TARGET_AREA_DATA[targetArea].targetMatrix
	var newMatrix = [ [0,0,0] , [0,0,0] , [0,0,0] ]

	for x in range( 0 , template.size() ):
		for y in range( 0 , template[x].size() ):
			var isValid = true
			var targetX = x + myX - 1
			var targetY = y + myY - 1

			if( targetX < 0 || targetX >= 3 ):
				isValid = false
			
			if( targetX < 0 || targetY >= 3 ):
				isValid = false

			if( template[x][y] == 0 ):
				isValid = false
			
			if( isValid ):
				newMatrix[targetX][targetY] = 1
	
	return newMatrix

# This method takes a Crew object ( maybe other types later ), and does all the math on it
func calculateSelf( newActor = null ):
	if( newActor ):
		setActor( actor )
	else:
		# TODO - Build a dummy character so actions can exist in their 'naked, unmodified form'
		pass

	for effect in damageEffects:
		effect = _calculateDamageEffect( effect )

	for effect in passiveEffects:
		effect = _calculatePassiveEffect( effect )

	for effect in healingEffects:
		effect = _calculateHealingEffect( effect )

	for effect in statusEffects:
		effect = _calculateStatusEffect( effect )

func _calculateDamageEffect( effect ):
	pass

func _calculatePassiveEffect( effect ):
	pass

func _calculateHealingEffect( effect ):
	pass

func _calculateStatusEffect( effect ):
	pass

func makeRollFromEffect( effect ):
	var roll = ROLL_PROTOTYPE.duplicate()

	roll.damageRolls	= []
	roll.toHitRolls	= []
	roll.statusRoll	= []

	roll.effectType = effect.effectType
	roll.damageType = effect.damageType
	# roll.effectString = EFFECT_TEMPLATE_STRINGS[roll.effectType]

	if( effect.targetArea ):
		# roll.potentialTargets = AREA_COUNT[effect.targetArea]
		roll.targetArea 		 = targetArea
		roll.targetType 		 = targetType 
	else:
		# roll.potentialTargets = AREA_COUNT[targetArea]
		roll.targetArea		 = effect.targetArea
		roll.targetType		 = effect.targetType

	return roll 

func rollEffectRolls():
	var rollArray = []
	
	for effect in damageEffects:
		var roll = makeRollFromEffect( effect )

		for x in roll.potentialTargets:
			var toHitRoll = 0
			if( toHitTotal >= MAX_TO_HIT ): # if action itself always hits, use that
				toHitRoll = MAX_TO_HIT
			elif( effect.alwaysHit == true ): # otherwise, check if effect always hits
				toHitRoll = MAX_TO_HIT
			else: # else make a tohit roll
				toHitRoll = Common.randDiffPercents( 99 , 0 ) + ( toHitTotal * effect.toHitMod )
			
			roll.toHitRolls.append( toHitRoll )

			var dmgRoll = 0 # Calucalate damage and apply to dmg roll
			if( effect.effectType == EFFECT_TYPE.DAMAGE ):
				dmgRoll = Common.randDiffValues( dmgHiTotal , dmgLoTotal ) * effect.dmgMod
			elif( effect.effectType == EFFECT_TYPE.HEALING ):
				dmgRoll = Common.randDiffValues( dmgHiTotal , dmgLoTotal ) * effect.dmgMod
				dmgRoll = -dmgRoll # Healing is always considered 'negative'
		
			roll.damageRolls.append(dmgRoll)
		rollArray.append(roll)

	return rollArray

func getEffectDisplayArray():
	var displayArray = []

	for effect in damageEffects:
		var toHitString = ""
		var effectString = ""
		var targetString = ""

		if( effect.dmgType != DMG_TYPES.NONE ):
			effectString = "[color=red] " + str( dmgLoTotal * effect.dmgMod) + " - " + str( dmgHiTotal  * effect.dmgMod ) + " " + effect.dmgType + " [/color]"
		else:
			effectString = ""

		if( toHitTotal >= 200 ):
			toHitString = ""
		else:
			toHitString = "( [color=green]" + str( toHitTotal * effect.toHitMod ) + " %[/color] )"
		
		# Get target type. Use the default action area if effect has no target
		if( effect.targetArea ):
			targetString = "to " + TARGET_AREA[effect.targetArea].string
		else:
			targetString = "to " + targetArea.string

		#if( effect.targetType ):
		#	targetString = targetString + " ( [color=blue]"  + TARGET_AREA[effect.targetArea].string )+ "[/color] )"
		#else:
		#	targetString = targetString + " ( [color=blue]"  + getTargetTypeString() + " [/color] )"

		displayArray.append(toHitString + " " + effectString + " " + targetString )

	return displayArray