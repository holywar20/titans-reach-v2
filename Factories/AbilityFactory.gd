extends Node
# TODO - Actually get this bitch workin

const ABILITY_DATA_DIRECTORY = "res://JsonData/Abilities/"

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
	var ability = _validateAndFillAbility( dict )

	if( !ability ):
		print( "ability failed to build")
		return false

	# Replace damageEffects ( currently a raw dictionary ), and turn them into damageEffect objects 
	var properEffects = []
	for effect in ability.damageEffects:
		properEffects.append( _validateAndFillDamageEffect( ability , effect ) )
	ability.damageEffects = properEffects
	
	# Replace healingEffects( currently a raw dictionary ), and turn them into healingEffect objects
	properEffects = []
	for effect in ability.healingEffects:
		properEffects.append( _validateAndFillHealingEffect( ability , effect ) )
	ability.healingEffects = properEffects

	return ability

func _validateAndFillAbility( dict ):
	var ability = Ability.new()
	
	for key in dict:
		ability[key] = dict[key]

	for x in range(0 , ability.validTargets.size() ):
		ability.validTargets[x] = int( ability.validTargets[x] )
	for x in range(0 , ability.validFrom.size() ):
		ability.validFrom[x] = int( ability.validFrom[x] )

	if( ability.damageHiBase && ability.damageLoBase ):
		ability.damageHiBase = int( ability.damageHiBase )
		ability.damageLoBase = int( ability.damageLoBase )

	return ability

func _validateAndFillHealingEffect( ability , effectData ):
	var isValid = true
	var healingEffect = HealingEffect.new()

	for idx in effectData:
		if ( idx in healingEffect ):
			healingEffect[idx] = effectData[idx]
		else:
			print("Ability Error : found a key named " , idx , " that doesnt exist in the damage effect for ability ", ability.getFullName() )

	# Add in any default values from ability
	if( !healingEffect.targetArea ):
		healingEffect.targetArea = ability.targetArea
	if( !healingEffect.targetType ):
		healingEffect.targetType = ability.targetType

	# Now hardcode any type fixes we want to do
	healingEffect.healTraitMod = float( healingEffect.healTraitMod )
	healingEffect.healBaseMod = float( healingEffect.healBaseMod )
	healingEffect.toHitBaseMod = float( healingEffect.toHitBaseMod )
	healingEffect.toHitTraitMod = float( healingEffect.toHitTraitMod )
	
	return healingEffect


func _validateAndFillDamageEffect( ability, effectData ):
	var isValid = true
	var dmgEffect = DmgEffect.new()

	for idx in effectData:
		if ( idx in dmgEffect ):
			dmgEffect[idx] = effectData[idx]
		else:
			print("Ability Error : found a key named " , idx , " that doesnt exist in the damage effect for ability ", ability.getFullName() )

	# Add in any default values from ability
	if( !dmgEffect.targetArea ):
		dmgEffect.targetArea = ability.targetArea
	if( !dmgEffect.targetType ):
		dmgEffect.targetType = ability.targetType

	# Now hardcode any type fixes we want to do
	dmgEffect.dmgTraitMod = float( dmgEffect.dmgTraitMod )
	dmgEffect.dmgBaseMod = float( dmgEffect.dmgBaseMod )
	dmgEffect.toHitBaseMod = float( dmgEffect.toHitBaseMod )
	dmgEffect.toHitTraitMod = float( dmgEffect.toHitTraitMod )
	
	return dmgEffect

func _fillAndValidateStatusEffect( ability, effectData ):
	return null

func _fillAndValidateHealingEffect( ability, effectData ):
	return null

func _fillAndValidatePassiveEffect( ability, effectData ):
	return null



