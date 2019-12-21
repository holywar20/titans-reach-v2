extends Node
# TODO - Actually get this bitch workin

const ABILITY_DATA_DIRECTORY = "res://Resources/Ability/"

var MANDATORY_DMG_EFFECT_VARS = [ 'dmgTrait' , 'dmgType' , 'dmgMod' , 'toHitTrait', 'toHitMod' ]

var abilityDictionary = {}

func _ready():
	var files = []
	var dir = Directory.new()
	
	if( dir.open( self.ABILITY_DATA_DIRECTORY ) == OK ):
		dir.list_dir_begin( true, true) # Skips hidden and navigational files

		while true: 
			var file = dir.get_next()
			if file == "":
				break
			else:
				files.append(file)

		dir.list_dir_end()
		
		for fileName in files:
			var path = self.ABILITY_DATA_DIRECTORY + fileName
			var file = File.new()
			file.open( path , file.READ )

			var text = file.get_as_text()
			var json = JSON.parse( text )
			var dict = json.get_result()

			for key in dict:
				abilityDictionary[key] = dict[key]
	else:
		print( "There was an error loading ability files.")
		#Log.log("Files didnt load. Something is wrong")

func getActionByAbilityKey( key ):

	if( self.abilityDictionary.has( key ) ):
		var abilityData = self.abilityDictionary[key]
		var ability = self.buildAbilityFromDict( abilityData )

		return ability
	else:
		print("There was an error getting the Ability")
		#Log.add( Log.ALERT , "ActionGenerator : There was an issue finding ability:" + key )

func buildAbilityFromDict( dict ):
	var ability = self._fillAndValidateBaseAbility( dict )
	if( !ability ):
		print( "ability failed to build")
		return false
		#Log.add( Log.ALERT , "ability Generator: ability didn't build successfully.")
	
	# ability.calculateSelf()
	
	return ability

func _fillAndValidateDamageEffect( ability, effectData ):
	var isValid = true
	for keyName in self.MANDATORY_DMG_EFFECT_VARS:
		if( !effectData.has( keyName ) ):
			isValid = false
			#Log.add( Log.ALERT , "ActionGenerator : Invalid Effect for ( " + ability.key + " , " + keyName + " )" )
	
	if( isValid ):
		var dmgEffect = Ability.DMG_EFFECT_PROTOTYPE.duplicate()
		for key in dmgEffect:
			if( effectData.has(key) ):
				dmgEffect[key] = effectData[key]
		
		ability.appendEffect( dmgEffect , ability.EFFECT_TYPE.DAMAGE )
	
	return ability

func _fillAndValidateStatusEffect( ability, effectData ):

	return ability

func _fillAndValidateHealingEffect( ability, effectData ):
	return ability

func _fillAndValidatePassiveEffect( ability, effectData ):
	return ability

func _fillAndValidateBaseAbility( dict ):
	var ability = Ability.new()
	
	ability.key = dict.key
	ability.shortName = dict.shortName
	ability.fullName = dict.fullName
	ability.iconPath = dict.iconPath

	ability.damageHiBase =  dict.damageHiBase 
	ability.dmgHiTotal = dict.damageHiBase
	ability.damageLoBase = dict.damageLoBase
	ability.dmgLoTotal  = dict.damageLoBase
	ability.toHitBase = dict.toHitBase
	ability.toHitTotal =  dict.toHitBase

	if( typeof( dict.validTargets ) == TYPE_ARRAY ):
		ability.validTargets = dict.validTargets
	else:
		pass
		#Log.add( Log.ALERT , "ability is missing a valid validTargets: " + dict.key )
	
	if( typeof( dict.validFrom ) == TYPE_ARRAY ):
		ability.validFrom = dict.validFrom
	else:
		pass
		#Log.add( Log.ALERT , "ability is missing a valid validFrom: " + dict.key )

	if( ability.ABILITY_TYPES.has( dict.abilityType ) ):
		ability.abilityType = ability.ABILITY_TYPES[dict.abilityType]
	else:
		pass
		#Log.add( Log.ALERT , "ability is missing a valid actionType: " + dict.key )

	if( ability.TARGET_TYPES.has( dict.targetType ) ):
		ability.targetType = ability.TARGET_TYPES[dict.targetType]
	else:
		pass
		#Log.add( Log.ALERT , "ability is missing a valid targetType: " + dict.key )

	if( ability.TARGET_AREA.has( dict.targetArea ) ):
		ability.targetArea = dict.targetArea
	else:
		pass
		#Log.add( Log.ALERT , "ability is missing a valid targetArea: " + dict.key )

	return ability

