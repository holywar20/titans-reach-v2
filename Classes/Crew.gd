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

var station = null

var cp = 0
var cpSpent = 0
var dead = false

var texturePath = null
var smallTexturePath = null

var carryWeightCapacity = 3
var carryWeight = 0

# store off all this users abilities
var basicActions = []
var actions = []
var passives = []
var stances = []
var instants = []

var temporaryPassives = {}

var primaryTree = null
var secondaryTree = null

var gear = {
	"Frame" : null,
	"Wep1" : null,  "Wep2" : null , 
	"Equip1" : null , "Equip2" : null , "Equip3" : null
}

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

var charWeight = { "value": 4, "total" : 4 , "mod" : 0 , 'current' : 4 }
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

func _init():
	pass

# Overrides
func get_class(): 
	return "Crew"

func is_class( name : String ): 
	return name == "Crew"

func setTextures( sPath : String , lPath : String ):
	self.texturePath = lPath
	self.smallTexturePath = sPath

func assign( console = null ):
	self.station = console

func isAssigned():
	if( self.station ):
		return true
	else:
		return false

func _buildBasicActions():
	pass
	# TODO - impliment actions
	#var myAction = ActionGenerator.getActionByActionKey( "Brawl" )
	#self.actions.append( myAction )
	#Log.log( myAction )

func _ready():
	pass

func calculateTraits():
	for key in self.traits:
		self.traits[key].total = self.traits[key].value + self.traits[key].mod

func calculateDerivedStats( newCharacter = false ):
	
	for p in passives:
		pass # TODO : add ability to go through items and modify MODS.
	
	for key in self.traits:
		self.traits[key].total = self.traits[key].mod + self.traits[key].value
	
	self.carryWeightCapacity = BASE_WEIGHT + self.traits.STR.total
	
	self.hp.total = BASE_HP + self.hp.mod + self.traits.STR.total
	self.morale.total = BASE_MORALE + self.morale.mod + self.traits.CHA.total
	
	if( newCharacter ):
		self.hp.current = self.hp.total
		self.morale.current = self.morale.total

	self._calculateResists()

	if( newCharacter ):
		self.hp.current = self.hp.total
		self.morale.current = self.morale.total

func _calculateResists():
	self.resists.STR.Weaken.value 	= self.traits.STR.total * TRAIT_RESIST_BONUS
	self.resists.STR.Move.value 		= self.traits.STR.total * TRAIT_RESIST_BONUS
	self.resists.PER.Surprise.value 	= self.traits.PER.total * TRAIT_RESIST_BONUS
	self.resists.PER.Blind.value 		= self.traits.PER.total * TRAIT_RESIST_BONUS
	self.resists.INT.Confuse.value 	= self.traits.INT.total * TRAIT_RESIST_BONUS
	self.resists.INT.Charm.value 		= self.traits.INT.total * TRAIT_RESIST_BONUS
	self.resists.DEX.Balance.value 	= self.traits.DEX.total * TRAIT_RESIST_BONUS
	self.resists.DEX.Disarm.value 	= self.traits.DEX.total * TRAIT_RESIST_BONUS
	self.resists.CHA.Lock.value 		= self.traits.CHA.total * TRAIT_RESIST_BONUS
	self.resists.CHA.Slow.value 		= self.traits.CHA.total * TRAIT_RESIST_BONUS

	self.resists.STR.Weaken.total 	= self.resists.STR.Weaken.value 	+ self.resists.STR.Weaken.mod
	self.resists.STR.Move.total 		= self.resists.STR.Move.value 	+ self.resists.STR.Move.mod
	self.resists.PER.Surprise.total 	= self.resists.PER.Surprise.value + self.resists.PER.Surprise.mod
	self.resists.PER.Blind.total 		= self.resists.PER.Blind.value 	+ self.resists.PER.Blind.mod
	self.resists.INT.Confuse.total 	= self.resists.INT.Confuse.value + self.resists.INT.Confuse.mod
	self.resists.INT.Charm.total 		= self.resists.INT.Charm.value	+ self.resists.INT.Charm.mod
	self.resists.DEX.Balance.total 	= self.resists.DEX.Balance.value + self.resists.DEX.Balance.mod
	self.resists.DEX.Disarm.total 	= self.resists.DEX.Disarm.value 	+ self.resists.DEX.Disarm.mod
	self.resists.CHA.Lock.total 		= self.resists.CHA.Lock.value 	+ self.resists.CHA.Lock.mod
	self.resists.CHA.Slow.total 		= self.resists.CHA.Slow.value 	+ self.resists.CHA.Slow.mod

func getFrame():
	return self.gear.Frame

func isFrameEquipable( frame: Frame ):
	var potentialNewWeight = 0
	if( self.gear.Frame ): # If a frame is equiped
		potentialNewWeight = ( frame.itemCarryWeight + self.carryWeight ) - frame.itemCarryWeight
	else:
		potentialNewWeight = ( frame.itemCarryWeight + self.carryWeight )
	
	if( potentialNewWeight >= self.carryWeightCapacity ):
		return false
	else:
		return true

func equipFrame( frame: Frame ):
	var equipable = isFrameEquipable( frame )

	if( equipable ): # This is like a transaction. It must all happen here or not at all. TODO - make more robust.
		var oldFrame = self.gear.Frame
		self.gear.Frame = frame

		if( oldFrame ):
			oldFrame.unequip()

		return true
	
	return false

func isWeaponEquipable( weapon : Weapon ):
	pass

func equipWeapon():
	pass

func equipEquipment():
	pass

func isEquipmentEquipable( equipment : Equipment ):
	pass


func getPrimaryTreeString():
	if ( self.primaryTree ) :
		return self.primaryTree.treeName
	else:
		return "No tree assigned."; 

func getSecondaryTreeString():
	if( self.secondaryTree ):
		return self.secondaryTree.treeName
	else:
		return "No tree Assigned.";

func getNickName():
	return self.fullname[1]

func getFullName():
	return self.fullname[0] + ' "' + self.fullname[1] + '" ' + self.fullname[2]

func getCPointString():
	if( !self.dead ):
		return str(self.cpSpent) + " / " + str(self.cp)
	else:
		return "0 / 0"

func getMassString():
	return str(self.mass) + " Kg"

func getHeightString():
	return str(self.height) + " cm"

func getWorldString():
	return self.homeWorld

func getAgeString():
	return str( self.age ) + " yrs"

func getRaceString():
	return self.race

func getSexString():
	return self.sex

func getHPStatBlock():
	return self.hp.duplicate()

func getHitPointString():
	return str(self.hp.current) + " / " + str(self.hp.total)

func getMoraleStatBlock():
	return self.morale.duplicate()

func getMoraleString():
	return str(self.morale.current) + " / " + str(self.morale.total)

func getWeightStatBlock():
	return self.charWeight.duplicate()

func getWeightString():
	return str( self.carryWeight ) + " / " + str(self.carryWeightCapacity)

func getBonus( primaryTrait, secondaryTrait ):
	return self.traits[primaryTrait].total + ( self.traits[secondaryTrait].total / 2 )

func getTraitTotal( trait ):
	if( self.traits.has( trait ) ):
		return self.traits[trait].total
	else:
		return null

func getTraitStatBlock( trait ):
	if( self.traits.has( trait ) ):
		return self.traits[trait].duplicate()
	else: 
		return null

func getAllTraitStatBlocks():
	return self.traits.duplicate()

func getResistStatBlock( resist ):
	if( self.resists.has( resist ) ):
		return self.resists[resist].duplicate()
	else:
		return null

func getAllResistStatBlocks():
	return self.resists.duplicate()

func getStation():
		return self.station
# Update all the passive abilities from equipment
func _updatePassives():
	self.passives = []

	#for itemKey in self.equipment:
	#	var myItem = ItemManager.getCrewEquipableItem( itemKey )

	#	for passive in myItem.passives:
	#		self.passives.append( passives )
	#		
	#		if( passive.PASSIVE_TYPE.TRAIT_MOD ):
	#			pass
	#		elif( passive.PASSIVE_TYPE.DERIVED_MOD ):
	#			pass
	#			#self.traits[passive.effect].mod += passive.value
	#		elif( passive.PASSIVE_TYPE.STATUS_EFFECT_BONUS ):
	#			pass
	#		elif( passive.PASSIVE_TYPE.STATUS_EFFECT ):
	#			pass

# Update all temporary passives from status effects / equipment, etc. Essentially passives on a timer. 
func _updateTempPassives():
	self.passives = []
	
	#for passive in self.temporaryPassives:
	#	if( passive.passRound() ):
	#		
	#		if( passive.PASSIVE_TYPE.TRAIT ):
	#			pass
	#		elif( passive.PASSIVE_TYPE.DERIVED ):
	#			pass
	#			#self[passive.effect].mod += passive.value
	#		elif( passive.PASSIVE_TYPE.STATUS_EFFECT):
	#pass
	#	
	#	else:
	#		pass # TODO some kind of code to clean up the passive without blowing the dictionary up.

func _updateEquipmentActions():
	# TODO - impliment
	pass
	#for itemKey in self.equipment:
	#	var myItem = ItemManager.getCrewEquipableItem( itemKey )

	#	for action in myItem.actions:
	#		var crewAction = action.duplicate( 15 )

	#		if( action.actionType == action.ACTION_TYPES.ACTION ):
	#			crewAction.calculateSelf( self )
	#			self.actions.append( crewAction )

	#		if( action.actionType == action.ACTION_TYPES.STANCE ):
	#			crewAction.calculateSelf( self )
	#			self.stances.append( crewAction )

	#		if( action.actionType == action.ACTION_TYPES.INSTANT ):
	#			crewAction.calculateSelf( self )
	#			self.instants.append( crewAction )

func _updateTalentActions():
	pass

func updateAbilities( inBattle = false ):
	
	self._updatePassives()

	if( inBattle ):
		self._updateTempPassives()

	self.calculateTraits()
	self.calculateDerivedStats()
		# TODO - add any bonus's based on trait to action.
	
	self.actions = []
	self.stances = []
	self.instants = []

	self._updateTalentActions()
	self._updateEquipmentActions()

# Return a dictionary of 'modified' crewman actions that include any status effects
func getCrewmanActions():
	# TODO - Impliment
	pass

func applyDamage( damage , damageType ):
	# TODO impliment damage reduction
	self.hp.current = self.hp.current - damage;
	
	if( self.hp.current <= 0 ):
		self.hp.current = 0;
		self.dead = true
	
	return self.hp.current

func applyStatusEffect( percentileRoll , effect):
	pass

func rollInit():
	var init = randi()%20 + self.PER.total
	return init