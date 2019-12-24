extends Node
# TODO - Actually get this bitch workin

const ABILITY_DATA_DIRECTORY = "res://JsonData/Abilities/"

var MANDATORY_DMG_EFFECT_VARS = [ 'dmgTrait' , 'dmgType' , 'dmgMod' , 'toHitTrait', 'toHitMod' ]

var abilityDictionary = {}

func _ready():
	var files = []
	var dir = Directory.new()
	
	if( dir.open( ABILITY_DATA_DIRECTORY ) == OK ):
		dir.list_dir_begin( true, true) # Skips hidden and navigational files

		while true: 
			var file = dir.get_next()
			if file == "":
				break
			else:
				files.append(file)

		dir.list_dir_end()
		
		for fileName in files:
			var path = ABILITY_DATA_DIRECTORY + fileName
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

func getAbilityByKey( key ):

	if( abilityDictionary.has( key ) ):
		var abilityData = abilityDictionary[key]
		var ability = buildAbilityFromDict( abilityData )

		return ability
	else:
		print("There was an error getting the Ability")
		#Log.add( Log.ALERT , "ActionGenerator : There was an issue finding ability:" + key )

func buildAbilityFromDict( dict ):
	var ability = _fillAndValidateAbility( dict )
	if( !ability ):
		print( "ability failed to build")
		return false
	
	# ability.calculateSelf()
	
	return ability

func _fillAndValidateDamageEffect( ability, effectData ):
	var isValid = true
	for keyName in MANDATORY_DMG_EFFECT_VARS:
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

func _fillAndValidateAbility( dict ):
	var ability = Ability.new()
	
	for key in dict:
		ability[key] = dict[key]

	for x in range(0 , ability.validTargets.size() ):
		ability.validTargets[x] = int( ability.validTargets[x] )
	for x in range(0 , ability.validFrom.size() ):
		ability.validFrom[x] = int( ability.validFrom[x] )

	ability.damageHiBase = int( ability.damageHiBase )
	ability.damageLoBase = int( ability.damageLoBase )
	# Next we type force all our integer values that should be integers into integers because Godot turns everything into real numbers from Json imports
	

	return ability

