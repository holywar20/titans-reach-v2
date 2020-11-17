extends Resource

class_name Effect

const TRAITS = {
	"STR" : "STR" , "INT" : "INT" , "DEX" : "DEX" , "CHA" : "CHA"
}

const EFFECT_TYPES = {
	"DAMAGE" : "DAMAGE" , 
	"HEALING" : "HEALING" , 
	"MOVEMENT" : "MOVEMENT" , 
	"STATUS_EFFECT" : "STATUS_EFFECT"
}

const MOVEMENT_TYPES = {
	"SWAP" : "SWAP",
	"PUSH" : "PUSH",
	"PULL" : "PULL"  
}

# Filled by DB
var key : String = "NONE"
var effectType : String = "DAMAGE"
var toHitTrait : String
var toHitBaseMod : float =  0.0
var toHitTraitMod : float = 0.0

# effectType - Movement
var moveType : String

# effectType - Damage
var dmgType : String
var dmgBaseMod : float = 0.0
var dmgTrait : String 
var dmgTraitMod : float = 0.0

# effectType - Healing
var healBaseMod : float = 0.0
var healTrait : String
var healTraitMod : float = 0.0

# effectType - Status Effects
var statusEffect : String
var statusEffectTrait : String
var statusEffectBaseMod : float = 0.0
var statusEffectTraitMod : float = 0.0


var targetArea : String
var targetType : String
var animationKey : String = ""

# Calculated values 
var alwaysHit = false
var toHitTotalMod = 0
var toHitRolls = []
var resultRolls = []
var fullDisplay = ""
var parentAbility = null;
var parentCrewman = null;

func get_class():
	return "Effect"

func is_class( className ):
	return className == "Effect"

func _init( effectDict : Dictionary , ability : Ability ):
	
	key = effectDict.key
	parentAbility = ability
	parentCrewman = ability.actor
	
	effectType = effectDict.effectType as String
	toHitTrait = effectDict.toHitTrait as String
	toHitBaseMod = effectDict.toHitBaseMod as float
	toHitTraitMod = effectDict.toHitTraitMod as float
	animationKey = effectDict.animationKey as String

	if( effectDict.targetType ):
		targetType = effectDict.targetType as String
		targetArea = effectDict.targetArea as String
	elif( ability !=null ):
		targetType = ability.targetType
		targetArea = ability.targetArea
	else:
		targetType = Ability.TARGET_TYPES.SELF;
		targetArea = Ability.TARGET_AREA.SELF;

	match effectType:
		"MOVEMENT":
			moveType = effectDict.moveType as String
		"DAMAGE":
			dmgType  = effectDict.dmgType as String
			dmgBaseMod = effectDict.dmgBaseMod as float
			dmgTrait = effectDict.dmgTrait as String
			dmgTraitMod = effectDict.dmgTraitMod as float
		"HEALING":
			healBaseMod = effectDict.healBaseMod as float
			healTrait = effectDict.healTrait as String
			healTraitMod = effectDict.healTraitMod as float
		"STATUS":
			statusEffect = effectDict.statusEffect as String
			statusEffectTrait = effectDict.statusEffectTrait as String
			statusEffectBaseMod = effectDict.statusEffectBaseMod as float
			statusEffectTraitMod = effectDict.statusEffectTraitMod as float

func calculateSelf():
	if( toHitTrait ):
		var statBlock = parentCrewman.getTraitStatBlock( toHitTrait )
		var traitValue = statBlock.total
		
		toHitTotalMod = ( traitValue * toHitTraitMod ) + toHitBaseMod
	else:
		toHitTotalMod = toHitBaseMod

	_postCalculateSelf()

# Override for any preexecution calculation
func _postCalculateSelf():
	pass

func rollEffect():
	calculateSelf()

	var numRolls = Ability.TARGET_AREA_DATA[targetArea].count
	toHitRolls  = _rollToHit( numRolls )
	resultRolls = _rollResult( numRolls )

# Figures out which targets would be valid, based upon x ,y grid coordinates
func getOffsetMatrix( myX , myY ):
	var template = Ability.TARGET_AREA_DATA[targetArea].targetMatrix
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

# Override for any rolls you want this effect to store
func _rollResult( numRolls : int ):
	var rolls = []

	if( effectType == self.EFFECT_TYPES.DAMAGE ):
		for x in range( 0 , numRolls ):
			var loDmg = parentAbility.damageLoBase + ( parentCrewman.getTraitTotal( dmgTrait ) * dmgTraitMod )
			var hiDmg = 0
			var dmgRoll = Common.randDiffValues( loDmg , hiDmg );
			rolls.append( dmgRoll )

	return rolls;

func _rollToHit( numRolls : int ):
	var rolls = []
	
	for x in range( 0 , numRolls ):
		var toHitRoll = 0
		if( alwaysHit ):
			toHitRoll = Ability.MAX_TO_HIT
		else:
			toHitRoll = randi() % 99 + ( parentAbility.toHitBase + toHitTotalMod )
			rolls.append( toHitRoll )
			
	return rolls

func displayEffect():
	var totalString = "{toHit}% to hit."

	var total = parentAbility.toHitBase + toHitTotalMod
	totalString = totalString.format( { "toHit" : int( total ) } ) + _postDisplayEffect()

	return totalString

# Override to add a display line to this effect
func _postDisplayEffect():
	var effectSubString = ""

	return effectSubString
