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
	'KINETIC'	: "KINETIC", 
	'THERMAL'	: "THERMA",
	'TOXIC'		: "TOXIC", 
	'EM'			: "EM", 
	'HEALING'	: "HEALING"	,
	'NONE' 		: "NONE"
}

const EFFECT_TYPE = {
	"DAMAGE" 	: "Damage" , 
	"HEALING"	: "Healing", 
	"STATUS"		: "Status", 
	"PASSIVE"	: "Passive", 
}

const MOVE_TYPES = {
	"ANY_ALLOWED"	: { "String" : "Any" } ,
	"RANDOM" 		: { "String" : "Random" } ,
	"UP"				: { "String" : "Up"} ,
	"BACK"			: { "String" : "Back" } ,
	"DOWN"			: { "String" : "Down" },
	"FORWARD" 		: { "String" : "Forward" }
}

const TARGET_AREA = {
	"SELF"		: { "areaType" : "SELF" 	, "count" : 1 , "string" : "Self" },
	"SINGLE" 	: { "areaType" : "SINGLE"	, "count" : 1 , "string" : "Single" },
	"COLUMN"		: { "areaType" : "COLUMN"	, "count" : 3 , "string" : "Self" },
	"ROW" 		: { "areaType" : "ROW"		, "count" : 3 , "string" : "Row" },
	"ROW_DECAY"	: { "areaType" : "ROW_DECAY" , "count" : 2 , "string" : "Row Decay" },
	"CROSS" 		: { "areaType" : "CROSS"	, "count" : 5 , "string" : "Cross" },
	"ALL" 		: { "areaType" : "ALL"		, "count" : 9 , "string" : "All" },
}

const TARGET_TYPES  = {
	'ALLY_UNITS' : 'ALLY_UNITS' ,'ENEMY_UNIT' :'ENEMY_UNIT',
	'ALLY_FLOOR' : 'ALLY_FLOOR' ,'ENEMY_FLOOR': 'ENEMY_FLOOR',
	'SELF' : 'SELF'
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

func doesTargetEnemyUnits():
	
	var offensive = null
	if( targetType == TARGET_TYPES.ENEMY_FLOOR || targetType == TARGET_TYPES.ENEMY_UNIT ):
		offensive = true
	else:
		offensive = false

	var doesTargetEnemy = null
	if( offensive && actor.isPlayer || !offensive && !actor.isPlayer ):
		doesTargetEnemy = true
	else:
		doesTargetEnemy = false

	return doesTargetEnemy

func getTargetType():
	return targetType

func getIconPath():
	return iconPath

func getTargetTypeString( targetType = null ):
	var targetTypeString = null 
	var myTargetType = null

	if(targetType):
		myTargetType = targetType
	else:
		myTargetType = targetType

	if( myTargetType == TARGET_TYPES.PLAYER ):
		targetTypeString = "Ally"
	elif( myTargetType == TARGET_TYPES.ENEMY ):
		targetTypeString = "Enemy"
	elif( myTargetType== TARGET_TYPES.PLAYER_FLOOR ):
		targetTypeString = "Enemy Floor"
	elif( myTargetType == TARGET_TYPES.ENEMY_FLOOR ):
		targetTypeString = "Ally Floor"
	elif( myTargetType == TARGET_TYPES.SELF ):
		targetTypeString = "Self"
	
	return targetTypeString

func getTargetAreaString( targetArea = null ):
	var myAreaType = null
	
	if( targetArea ):
		myAreaType = targetArea
	else:
		myAreaType = targetArea

	return ""

# Note should is also used for an action validity test. 
func getValidTargets():
	var targetingArray = [ [ false , false , false ] , [ false, false , false] , [ false, false, false] ]

	for x in range(0 , targetingArray.size() ):
		for y in range( 0 , targetingArray[x].size() ):
			if( validTargets.has( y ) ):
				targetingArray[x][y] = true
		
	return targetingArray

func isLearned():
	return abilityLearned

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