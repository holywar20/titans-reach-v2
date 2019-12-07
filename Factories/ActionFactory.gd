extends Node
# TODO - Actually get this bitch workin

const ACTION_DATA_DIRECTORY = "res://Resources/ActionData/"

var MANDATORY_DMG_EFFECT_VARS = [ 'dmgTrait' , 'dmgType' , 'dmgMod' , 'toHitTrait', 'toHitMod' ]

var actionDictionary = {}

func _ready():
	var files = []
	var dir = Directory.new()
	
	if( dir.open( self.ACTION_DATA_DIRECTORY ) == OK ):
		dir.list_dir_begin( true, true) # Skips hidden and navigational files

		while true: 
			var file = dir.get_next()
			if file == "":
				break
			else:
				files.append(file)

		dir.list_dir_end()
		
		for fileName in files:
			var path = self.ACTION_DATA_DIRECTORY + fileName
			var file = File.new()
			file.open( path , file.READ )

			var text = file.get_as_text()
			var json = JSON.parse( text )
			var dict = json.get_result()

			for key in dict:
				actionDictionary[key] = dict[key]
	else:
		Log.log("Files didnt load. Something is wrong")

func getActionByActionKey( key ):

	if( self.actionDictionary.has( key ) ):
		var actionData = self.actionDictionary[key]
		var action = self.buildActionFromDict( actionData )

		return action
	else:
		Log.add( Log.ALERT , "ActionGenerator : There was an issue finding action:" + key )

func buildActionFromDict( dict ):
	var action = self._fillAndValidateBaseAction( dict )
	
	if( action ):
		if( dict.has( 'damageEffects' ) ):
			for effect in dict.damageEffects:
				action = self._fillAndValidateDamageEffect( action, effect  )
		
		if( dict.has('passiveEffects') ) :
			for effect in dict.passiveEffects:
				action = self._fillAndValidatePassiveEffect( action, effect )

		if( dict.has('statusEffects') ) :
			for effect in dict.statusEffects:
				action = self._fillAndValidateStatusEffect( action, effect )
		
		if( dict.has('healingEffects') ) :
			for effect in dict.healingEffects:
				action = self._fillAndValidateHealingEffect( action, effect )
	else:
		Log.add( Log.ALERT , "Action Generator: Action didn't build successfully.")
	
	action.calculateSelf()
	
	return action

func _fillAndValidateDamageEffect( action, effectData ):
	var isValid = true
	for keyName in self.MANDATORY_DMG_EFFECT_VARS:
		if( !effectData.has( keyName ) ):
			isValid = false
			Log.add( Log.ALERT , "ActionGenerator : Invalid Effect for ( " + action.key + " , " + keyName + " )" )
	
	if( isValid ):
		var dmgEffect = Action.DMG_EFFECT_PROTOTYPE.duplicate()
		for key in dmgEffect:
			if( effectData.has(key) ):
				dmgEffect[key] = effectData[key]
		
		action.appendEffect( dmgEffect , Action.EFFECT_TYPE.DAMAGE )
	
	return action

func _fillAndValidateStatusEffect( action, effectData ):

	return action

func _fillAndValidateHealingEffect( action, effectData ):
	return action

func _fillAndValidatePassiveEffect( action, effectData ):
	return action

func _fillAndValidateBaseAction( dict ):
	var action = Action.new()
	
	action.key = dict.key
	action.shortName = dict.shortName
	action.fullName = dict.fullName
	action.iconPath = dict.iconPath

	action.damageHiBase =  dict.damageHiBase 
	action.dmgHiTotal = dict.damageHiBase
	action.damageLoBase = dict.damageLoBase
	action.dmgLoTotal  = dict.damageLoBase
	action.toHitBase = dict.toHitBase
	action.toHitTotal =  dict.toHitBase

	if( typeof( dict.validTargets ) == TYPE_ARRAY ):
		action.validTargets = dict.validTargets
	else:
		Log.add( Log.ALERT , "Action is missing a valid validTargets: " + dict.key )
	
	if( typeof( dict.validFrom ) == TYPE_ARRAY ):
		action.validFrom = dict.validFrom
	else:
		Log.add( Log.ALERT , "Action is missing a valid validFrom: " + dict.key )

	if( Action.ACTION_TYPES.has( dict.actionType ) ):
		action.actionType = Action.ACTION_TYPES[dict.actionType]
	else:
		Log.add( Log.ALERT , "Action is missing a valid actionType: " + dict.key )

	if( Action.TARGET_TYPES.has( dict.targetType ) ):
		action.targetType = Action.TARGET_TYPES[dict.targetType]
	else:
		Log.add( Log.ALERT , "Action is missing a valid targetType: " + dict.key )

	if( Action.TARGET_AREA.has( dict.targetArea ) ):
		action.targetArea = dict.targetArea
	else:
		Log.add( Log.ALERT , "Action is missing a valid targetArea: " + dict.key )

	return action

