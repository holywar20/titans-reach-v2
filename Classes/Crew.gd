extends Node

class_name Crew

const BASE_WEIGHT = 3
const BASE_HP = 12
const BASE_MORALE = 8
const TRAIT_RESIST_BONUS = 5

# Cosmetics
var fullname = ["First" , "nickname" , "Last"]
var sex  = null
var height = 2.1
var mass = 95
var race = "Terran" # TODO add ability for crewman to be many races
var homeWorld = "Earth" # TODO Link homeworld to in game worlds which can potentially be discovered.
var age = 100
var bio = "four score and seven years ago. Yeah. I'm abraham Lincoln Bitch."
var texturePath = null
var smallTexturePath = null

var id = null
var cp = 0
var cpSpent = 0

# Status flags
var isDead = false
var isPlayer = true

# Other State
var station = null
var currentStanceKey = null
var gear = {
	"Frame" : null, "LWeapon" : null,  "RWeapon" : null , "CEquip" : null , "LEquip" : null , "REquip" : null
}


# A dictionary of keys, keyed by a 'source'. When it is not needed, actions are stored as simple keys and built as needed.
var allAbilityKeys = {
	"Basic"  : [ "Move" , "Brawl" , "Defend" ],
	"Talent" : [] ,
	"Gear"	: []
}

# store off all this users abilities
var actions = []
var passives = []
var stances = []
var triggered = []
var instants = []

var temporaryPassives = {}


# TODO make this an enum index
# enum TRAITS { NONE , STR , DEX , PER, INT, CHA }
const TRAITS = {
	"CHA" : "Charisma" , "INT" : "Intelligence" , "DEX" : "Dexerity" ,  "STR" : "Strength" , "PER" : "Perception"
}

var traits = {
	'STR' : { "name" : "STR", "fullName": "Strength" 	, "value": 0, "total" : 0 , "equip" : 0 , "talent": 0 ,"mod" : 0 },
	'CHA' : { "name" : "CHA", "fullName": "Charisma" 	, "value": 0, "total" : 0 , "equip" : 0 , "talent": 0 ,"mod" : 0 },
	'PER' : { "name" : "PER", "fullName": "Perception"	, "value": 0, "total" : 0 , "equip" : 0 , "talent": 0 ,"mod" : 0 },
	'DEX' : { "name" : "DEX", "fullName": "Dexerity" 	, "value": 0, "total" : 0 , "equip" : 0 , "talent": 0 ,"mod" : 0 },
	'INT' : { "name" : "INT", "fullName": "Intelligence", "value": 0, "total" : 0 , "equip" : 0 , "talent": 0 ,"mod" : 0 }
}

var carryWeight = { "value": 0, "total" : 0 , "mod" : 0 , 'current' : 0 }
var hp = { "value": 18, "total" : 18 , "mod" : 0 , 'current' : 0 }
var morale = { "value": 18, "total" : 18 , "mod" : 0  , 'current': 0}

var damageReduction = { 
	'kinetic': 	{ "value" : 0, "total" : 0 , "mod" : 0 },
	'thermal': 	{ "value" : 0, "total" : 0 , "mod" : 0 }, 
	'toxic': 	{ "value" : 0, "total" : 0 , "mod" : 0 }, 
	'EM':			{ "value" : 0, "total" : 0 , "mod" : 0 }, 
}

var resists = {
	"STR" : {
		"Move"		: { "name" : "Move"		, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Forces target to move 
		"Weaken"		: { "name" : "Weaken"	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Target deals less damage + Loses armor
	} , 
	"PER" : {
		"Surprise" 	: { "name" : "Surprise"	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Target suffers extra damage on attacks
		"Blind" 		: { "name" : "Blind" 	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Target has penalty to actions
	} ,
	"INT" : {
		"Confuse"	: { "name" : "Confuse"	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Target does random action
		"Charm" 		: { "name" : "Charm"		, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 }, # Target does random action to benifit enemy
	},
	"DEX" : {
		"Balance"	: { "name" : "Balance"	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 } , # Target loses defense & Saves
		"Disarm" 	: { "name" : "Disarm"	, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 } , # Target can't use a weapon
	},
	"CHA" : {
		"Lock"		: { "name" : "Lock"		, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 } , # Target can't use certain powers
		"Slow"		: { "name" : "Slow"		, "value" : 0, "total" : 0 , "equip" : 0 , "talent" : 0, "mod" : 0 } , # Target loses AP
	}
}


# Overrides
func get_class(): 
	return "Crew"

func is_class( name : String ): 
	return name == "Crew"

func _init():
	id = Common.genRandomKey()

func calculateSelf( newCharacter = false ):

	_getAbilityKeysFromGear()
	_getAbilityKeysFromTalents()

	_loadPassiveAbilitiesFromSavedKeys()
	# Load passive abilities

	_calculateTraits()
	_loadAbilitiesFromSavedKeys()

	_calculateResists()
	_calculateCarryWeight()
	_calculateDerivedStats( newCharacter )

func _getAbilityKeysFromGear():
	allAbilityKeys.Gear = []
	
	for key in gear:
		if( gear[key] ):
			var myAbilityKeys = gear[key].getAbilities()
			for abilityKey in myAbilityKeys:
				allAbilityKeys.Gear.append( abilityKey )

func _getAbilityKeysFromTalents():
	pass

func _loadPassiveAbilitiesFromSavedKeys():
	pass

func _loadAbilitiesFromSavedKeys():
	actions = []
	stances = []
	triggered = []
	instants = []
	passives = []

	for category in allAbilityKeys:
		for key in allAbilityKeys[category]:
			var ability = ItemDB.getCoreAbility( key , self )

			if( ability ):
				ability.setActor( self )

				if( ability.abilityType == ability.ABILITY_TYPES.ACTION ):
					actions.append( ability )
				
				if( ability.abilityType == ability.ABILITY_TYPES.STANCE ):
					stances.append( ability )

				if( ability.abilityType == ability.ABILITY_TYPES.TRIGGERED ):
					triggered.append( ability )

				if( ability.abilityType == ability.ABILITY_TYPES.PASSIVE ):
					passives.append( ability )

				if( ability.abilityType == ability.ABILITY_TYPES.INSTANT ):
					instants.append( ability )
			# Parse key, put it in category that cares about it.

func assign( console = null ):
	station = console

func isAssigned():
	if( station ):
		return true
	else:
		return false

func _validateItemTransaction( item , itemSlot ):	
	# TODO - Maybe post an error message on the crewman object which we can query later?
	var isValid = true

	if( ( item.itemCarryWeight + carryWeight.current ) > carryWeight.total  ):
		isValid = false 
	
	if( item.getRemaining() <= 0 ): # not enough of the item
		isValid = false
	# TODO - maybe restrictions for various kinds of status effects?
	
	return isValid

func itemTransaction( item , itemSlot , sourceItemSlot = null ):
	var isValid = true
	if( item ):
		isValid = _validateItemTransaction( item , itemSlot )

	if( isValid ):
		# First figure out the old item.
		var oldItem = assignItem( item, itemSlot )
		
		if( sourceItemSlot ):
			assignItem( oldItem , itemSlot )

		if( oldItem && !sourceItemSlot ):
			oldItem.subFromAssigned()

		if( item ):
			item.addToAssigned()
		
		calculateSelf()
		
	return isValid

func assignItem( item, itemSlot ):
	var oldItem = gear[itemSlot]
	gear[itemSlot] = item
	
	return oldItem

func _calculateTraits():
	for key in traits:
		traits[key].total = traits[key].value + traits[key].mod

func _calculateCarryWeight():
	carryWeight.total = BASE_WEIGHT + carryWeight.mod + traits.STR.total
	
	var current = 0
	for key in gear:
		if( gear[key] ):
			current = current + gear[key].itemCarryWeight
		
	carryWeight.current = current

func _calculateDerivedStats( newCharacter = false ):
	
	hp.total = BASE_HP + hp.mod + traits.STR.total
	morale.total = BASE_MORALE + morale.mod + traits.CHA.total

	if( newCharacter ):
		hp.current = hp.total
		morale.current = morale.total

func _calculateResists():
	resists.STR.Weaken.value 	= traits.STR.total * TRAIT_RESIST_BONUS
	resists.STR.Move.value 		= traits.STR.total * TRAIT_RESIST_BONUS
	resists.PER.Surprise.value 	= traits.PER.total * TRAIT_RESIST_BONUS
	resists.PER.Blind.value 		= traits.PER.total * TRAIT_RESIST_BONUS
	resists.INT.Confuse.value 	= traits.INT.total * TRAIT_RESIST_BONUS
	resists.INT.Charm.value 		= traits.INT.total * TRAIT_RESIST_BONUS
	resists.DEX.Balance.value 	= traits.DEX.total * TRAIT_RESIST_BONUS
	resists.DEX.Disarm.value 	= traits.DEX.total * TRAIT_RESIST_BONUS
	resists.CHA.Lock.value 		= traits.CHA.total * TRAIT_RESIST_BONUS
	resists.CHA.Slow.value 		= traits.CHA.total * TRAIT_RESIST_BONUS

	resists.STR.Weaken.total 	= resists.STR.Weaken.value 	+ resists.STR.Weaken.mod
	resists.STR.Move.total 		= resists.STR.Move.value 	+ resists.STR.Move.mod
	resists.PER.Surprise.total 	= resists.PER.Surprise.value + resists.PER.Surprise.mod
	resists.PER.Blind.total 		= resists.PER.Blind.value 	+ resists.PER.Blind.mod
	resists.INT.Confuse.total 	= resists.INT.Confuse.value + resists.INT.Confuse.mod
	resists.INT.Charm.total 		= resists.INT.Charm.value	+ resists.INT.Charm.mod
	resists.DEX.Balance.total 	= resists.DEX.Balance.value + resists.DEX.Balance.mod
	resists.DEX.Disarm.total 	= resists.DEX.Disarm.value 	+ resists.DEX.Disarm.mod
	resists.CHA.Lock.total 		= resists.CHA.Lock.value 	+ resists.CHA.Lock.mod
	resists.CHA.Slow.total 		= resists.CHA.Slow.value 	+ resists.CHA.Slow.mod

func getId():
	return id

func getGearAt( key : String ):
	return gear[key]

func getNickName():
	return fullname[1]

func getFullName():
	return fullname[0] + ' "' + fullname[1] + '" ' + fullname[2]

func getCPointString():
	if( !isDead ):
		return str(cpSpent) + " / " + str(cp)
	else:
		return "0 / 0"

func getMassString():
	return str(mass) + " Kg"

func getHeightString():
	return str(height) + " cm"

func getWorldString():
	return homeWorld

func getAgeString():
	return str( age ) + " yrs"

func getRaceString():
	return race

func getSexString():
	return sex

func getHPStatBlock():
	return hp

func getHitPointString():
	return str(hp.current) + " / " + str(hp.total)

func getMoraleStatBlock():
	return morale

func getMoraleString():
	return str(morale.current) + " / " + str(morale.total)

func getWeightStatBlock():
	return carryWeight

func getWeightString():
	return str( carryWeight.current ) + " / " + str(carryWeight.total )

func getTexturePath( large = false ):
	if( large ):
		return texturePath
	else:
		return smallTexturePath

func getBonus( primaryTrait : String , secondaryTrait : String ):
	return traits[primaryTrait].total + ( traits[secondaryTrait].total / 2 )

func getTraitTotal( trait : String ):
	if( traits.has( trait ) ):
		return traits[trait].total
	else:
		print("Dev Error: requested a trait that doesn't exist:" , trait )
		return null

func getTraitStatBlock( trait ):
	if( traits.has( trait ) ):
		return traits[trait].duplicate()
	else: 
		return null

func getAllTraitStatBlocks():
	return traits.duplicate()

func getResistStatBlock( resist ):
	if( resists.has( resist ) ):
		return resists[resist].duplicate()
	else:
		return null

func getAllResistStatBlocks():
	return resists.duplicate()

func getFightableStatus():
	var isFightable = true

	if( isDead() ):
		isFightable = false

	return isFightable

# "Frame" : null, "LWeapon" : null,  "RWeapon" : null , "CEquip" : null , "LEquip" : null , "REquip" : null
func getAllWeaponStrings():
	var stringArray = []
	if( gear.LWeapon ):
		stringArray.append( gear.LWeapon.getItemDisplay( true ) )
	if ( gear.RWeapon ):
		stringArray.append( gear.RWeapon.getItemDisplay( true ) )

	if( stringArray.size() == 0 ):
		stringArray.append("None")
	
	return stringArray


func getAllFrameStrings():
	var stringArray = []
	if( gear.Frame ):
		stringArray.append( gear.Frame.getItemDisplay( true ) )
	else:
		stringArray.append("None")
	
	return stringArray

func getAllEquipmentStrings():
	var stringArray = []
	if( gear.LEquip ):
		stringArray.append( gear.LEquip.getItemDisplay( true ) )
	if( gear.REquip ):
		stringArray.append( gear.REquip.getItemDisplay( true ) )
	if( gear.CEquip ):
		stringArray.append( gear.LEquip.getItemDisplay( true ) )

	if( stringArray.size() >= 0 ):
		stringArray.append("None")
	
	return stringArray

func getStation():
	return station

func getAllActions():
	return actions

func getAllStances():
	return stances

func getAllInstants():
	return instants

func isDead():
	return isDead

func applyDamage( damage , damageType ):
	# TODO impliment damage reduction
	hp.current = hp.current - damage;
	
	if( hp.current <= 0 ):
		hp.current = 0;
		isDead = true
	
	return isDead

func applyHealing( healing ):

	hp.current = hp.current + healing;

	if( hp.current >= hp.total ):
		hp.current = hp.total

func applyStatusEffect( percentileRoll , effect):
	pass

func rollInit():
	var init = randi()%20 + traits.PER.total
	return init
