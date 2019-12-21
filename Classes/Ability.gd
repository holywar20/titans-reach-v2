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
	'KINETIC'	: "Kinetic Dmg", 
	'THERMAL'	: "Thermal Dmg",
	'TOXIC'		: "Toxic Dmg", 
	'EM'			: "EM Dmg", 
	'HEALING'	: "Healing"	,
	'NONE' 		: "NONE"
}

const EFFECT_TYPE = {
	"DAMAGE" 	: "Damage" , 
	"HEALING"	: "Healing", 
	"STATUS"		: "Status", 
	"PASSIVE"	: "Passive", 
}

const TARGET_AREA = {
	"SELF"		: { "areaType" : "SELF" 	, "count" : 1 , "string" : "Self" },
	"SINGLE" 	: { "areaType" : "SINGLE"	, "count" : 1 , "string" : "Single" },
	"COLUMN"		: { "areaType" : "COLUMN"	, "count" : 3 , "string" : "Self" },
	"ROW" 		: { "areaType" : "ROW"		, "count" : 3 , "string" : "Row" },
	"ROW_DECAY"	: { "areaType" : "ROW_DECAY" , "count" : 2 , "string" : "2 in a row" },
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

const HEAL_EFFECT_PROTOTYPE = {
	'healTrait'		: null,
	'healMod'		: null,
	'toHitTrait'	: null,
	'toHitMod'		: null,
	'targetArea'	: null,
	'targetType'	: null,
	'duration'		: null
}

const DMG_EFFECT_PROTOTYPE = {
	'dmgTrait'		: null,
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

func setActor( actor : Crew ):
	self.actor = actor

func appendEffect( effect , effectType ):
	
	match effectType:
		"Damage":
			self.damageEffects.append( effect )
		"Healing":
			self.healingEffects.append( effect )
		"Status" :
			self.statusEffects.append( effect )
		"Passive":
			self.statusEffects.append( effect )

func getTargetType():
	return self.targetType

func getIconPath():
	return self.iconPath

func getTargetTypeString( targetType = null ):
	var targetTypeString = null 
	var myTargetType = null

	if(targetType):
		myTargetType = targetType
	else:
		myTargetType = self.targetType

	if( myTargetType == self.TARGET_TYPES.PLAYER ):
		targetTypeString = "Ally"
	elif( myTargetType == self.TARGET_TYPES.ENEMY ):
		targetTypeString = "Enemy"
	elif( myTargetType== self.TARGET_TYPES.PLAYER_FLOOR ):
		targetTypeString = "Enemy Floor"
	elif( myTargetType == self.TARGET_TYPES.ENEMY_FLOOR ):
		targetTypeString = "Ally Floor"
	elif( myTargetType == self.TARGET_TYPES.SELF ):
		targetTypeString = "Self"
	
	return targetTypeString

func getTargetAreaString( targetArea = null ):
	var myAreaType = null
	
	if( targetArea ):
		myAreaType = targetArea
	else:
		myAreaType = self.targetArea

	return self.AREA_STRINGS[myAreaType]

# Note should is also used for an action validity test. 
func getValidTargets( unitX , unitY ):
	var permittedTargetingArray = [ [] , [] , [] ]

	if( !self.validFrom.has( unitX ) ):
		return false
	
	for x in range(0 , 2):
		for y in range( 0 , 2):
			if( self.validTargets.has( y ) ):
				permittedTargetingArray[x].append( y )
		
	return permittedTargetingArray

func isLearned():
	return self.abilityLearned

# This method takes a CrewClass object ( maybe other types later ), and does all the math on it
func calculateSelf( actor = null ):
	if( actor ):
		self.setActor( actor )
	else:
		# TODO - Build a dummy character so actions can exist in their 'naked, unmodified form'
		pass

	for effect in damageEffects:
		effect = self._calculateDamageEffect( effect )

	for effect in passiveEffects:
		effect = self._calculatePassiveEffect( effect )

	for effect in healingEffects:
		effect = self._calculateHealingEffect( effect )

	for effect in statusEffects:
		effect = self._calculateStatusEffect( effect )

func _calculateDamageEffect( effect ):
	pass

func _calculatePassiveEffect( effect ):
	pass

func _calculateHealingEffect( effect ):
	pass

func _calculateStatusEffect( effect ):
	pass

func makeRollFromEffect( effect ):
	var roll = self.ROLL_PROTOTYPE.duplicate()

	roll.damageRolls	= []
	roll.toHitRolls	= []
	roll.statusRoll	= []

	roll.effectType = effect.effectType
	roll.damageType = effect.damageType
	roll.effectString = self.EFFECT_TEMPLATE_STRINGS[roll.effectType]

	if( effect.targetArea ):
		roll.potentialTargets = self.AREA_COUNT[effect.targetArea]
		roll.targetArea 		 = self.targetArea
		roll.targetType 		 = self.targetType 
	else:
		roll.potentialTargets = self.AREA_COUNT[self.targetArea]
		roll.targetArea		 = effect.targetArea
		roll.targetType		 = effect.targetType

	return roll 

func rollEffectRolls():
	var rollArray = []
	
	for effect in self.effects:
		var roll = makeRollFromEffect( effect )

		for x in roll.potentialTargets:
			var toHitRoll = 0
			if( self.toHitTotal >= self.MAX_TO_HIT ): # if action itself always hits, use that
				toHitRoll = self.MAX_TO_HIT
			elif( effect.alwaysHit == true ): # otherwise, check if effect always hits
				toHitRoll = self.MAX_TO_HIT
			else: # else make a tohit roll
				toHitRoll = Common.randDiffPercents( 99 , 0 ) + ( self.toHitTotal * effect.toHitMod )
			
			roll.toHitRolls.append( toHitRoll )

			var dmgRoll = 0 # Calucalate damage and apply to dmg roll
			if( effect.effectType == self.EFFECT_TYPE.DAMAGE ):
				dmgRoll = Common.randDiffValues( self.dmgHiTotal , self.dmgLoTotal ) * effect.dmgMod
			elif( effect.effectType == self.EFFECT_TYPE.HEALING ):
				dmgRoll = Common.randDiffValues( self.dmgHiTotal , self.dmgLoTotal ) * effect.dmgMod
				dmgRoll = -dmgRoll # Healing is always considered 'negative'
		
			roll.damageRolls.append(dmgRoll)
		rollArray.append(roll)

	return rollArray

func getEffectDisplayArray():
	var displayArray = []

	for effect in self.damageEffects:
		var toHitString = ""
		var effectString = ""
		var targetString = ""

		if( effect.dmgType != self.DMG_TYPES.NONE ):
			effectString = "[color=red] " + str(self.dmgLoTotal * effect.dmgMod) + " - " + str( self.dmgHiTotal  * effect.dmgMod ) + " " + effect.dmgType + " [/color]"
		else:
			effectString = ""

		if( self.toHitTotal >= 200 ):
			toHitString = ""
		else:
			toHitString = "( [color=green]" + str( self.toHitTotal * effect.toHitMod ) + " %[/color] )"
		
		# Get target type. Use the default action area if effect has no target
		if( effect.targetArea ):
			targetString = "to " + self.TARGET_AREA[effect.targetArea].string
		else:
			targetString = "to " + self.targetArea.string

		#if( effect.targetType ):
		#	targetString = targetString + " ( [color=blue]"  + self.TARGET_AREA[effect.targetArea].string )+ "[/color] )"
		#else:
		#	targetString = targetString + " ( [color=blue]"  + self.getTargetTypeString() + " [/color] )"

		displayArray.append(toHitString + " " + effectString + " " + targetString )

	return displayArray