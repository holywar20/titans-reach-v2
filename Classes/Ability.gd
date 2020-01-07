extends Node

class_name Ability

const USE_TRAIT = true 
const NO_USE_TRAIT = false 

# Used to sort effects
const ABILITY_TYPES = { 
	"STANCE" : "STANCE", 
	"INSTANT": "INSTANT", 
	"ACTION" : "ACTION",  
	"TRIGGERED" : "TRIGGERED", 
	"PASSIVE" : "PASSIVE" 
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
		"string" : "Column" ,
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
var validTargets = null
var validFrom = null
var targetType = null
var targetArea = null
var iconPath = null

var damageHiBase = 0
var damageLoBase = 0
var healingHiBase = 0
var healingLoBase = 0
var toStatusEffectBase = 0
var toHitBase = 80

var damageEffects = []
var statusEffects = []
var passiveEffects = []
var healingEffects = []
var movementEffects = []

# Data that will mutate and change. 
var abilityLearned = false
var actor = null

func _init():
	setActor( CrewFactory.getDummyCrewman() )

func setActor( newActor : Crew ):
	actor = newActor

	calculateSelf()

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

func getTargetAreaCount():
	return TARGET_AREA_DATA[targetType].count

func getTargetAreaString():
	return TARGET_AREA_DATA[targetType].string

func getTargetAreaMatrix():
	return TARGET_AREA_DATA[targetType].targetMatrix

func getTargetTypeString():
	var targetTypeString = TARGET_TYPE_DATA[targetType].string
	var myTargetArea = TARGET_AREA_DATA[targetArea].string
	
	return myTargetArea + " vs. " + targetTypeString

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
		for effect in damageEffects:
			effect = effect.calculateSelf( self , actor )
	else:
		# TODO - Build a dummy character so actions can exist in their 'naked, unmodified form'
		pass

func rollEffectRolls():
	var effectArray = []
	
	for effect in damageEffects:
		effect.rollEffect( self , actor )
		effectArray.append( effect )

	for effect in healingEffects:
		effect.rollEffect( self, actor )
		effectArray.append( effect )

	return effectArray

func getDisplayText():
	var displayArray = getEffectDisplayArray()
	var displayString = PoolStringArray( displayArray ).join(" , ")

	return displayString

func getEffectDisplayArray():
	var displayArray = []

	for effect in damageEffects:
		displayArray.append( effect.displayEffect( self ) )
	
	for effect in healingEffects:
		displayArray.append( effect.displayEffect( self ) )

	return displayArray