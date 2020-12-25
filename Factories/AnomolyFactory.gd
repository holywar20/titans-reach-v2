extends Node

const MAX_ANOMS_PER_SYSTEM = 10
const MIN_ANOMS_PER_SYSTEM = 3

var anomolyScene = load("res://ReusableGameObjects/Anomoly/Anomoly.tscn")

const TEST_NARRATIVE = {
	"START" 	: {
		"narrativeTitle" : "Starting a narrative",
		"narrativeText"  : "A Narrative has started on this thing",
		"narrativeImage" : "res://icon.png" ,
		"childNarratives" : [ "BattleTest" , "LootTest" , "END" ]
	} , 
	"BattleTest" : {
		"narrativeTitle" : "Accord Scavengers attack you!",
		"narrativeText"  : "Start a fight text" ,
		"narrativeImage" : "res://icon.png" ,
		"ownOptionTitle" : "Battle!",
		"ownOptionText"  : "Start a fight!",
		"terminationEvent"  : "NarrativeBattleStart",
		"eventParams" : {
			"Faction" : "THE_ACCORD",
			"EnemyNum": 5 ,
			"EnemyCP" : 30
		}
	} ,
	"LootTest"	: {
		"narrativeTitle" : "You found Salvage!",
		"narrativeText"  : "Find salvage Text" ,
		"narrativeImage" : "res://icon.png" ,
		"ownOptionTitle" : "Loot!",
		"ownOptionText"  : "Loot some shit!",
		"terminationEvent" : "NarrativeLootStart",
		"eventParams" : {
			"Items" : {
				"Key" : "TerranAssaultRifle" , "Rarity" : "Common" , "Number" : 1 
			}
		}
	} ,
	"END"	: {
		"narrativeTitle" : "You leave.",
		"narrativeText"  : "Leaving ..." ,
		"narrativeImage" : "res://icon.png" ,
		"ownOptionTitle" : "Leave",
		"ownOptionText"  : "You leave, getting nothing, but taking no risk",
		"terminationEvent" : "NarrativeOver",
		"isLeavable" : true
	}
}

func _ready():
	pass

func generateAnomoly( parentCelestial, star , eventBus = null , typeOverride = null, anomolySeed = null ):
	var anom = anomolyScene.instance()

	if( anomolySeed ):
		seed( anomolySeed )
		randi()

	if( eventBus ):
		anom.setEvents( eventBus )

	var narrativeDictionary = generateNarratives( anom )
	anom.defaultNarrative = narrativeDictionary[ "START" ]

	anom.setParents( parentCelestial, star )
	anom.setAnomType( typeOverride )

	return anom

func generateNarratives( anom : Anomoly ):
	var allNarratives = {}

	# Init narative and load params into it
	for key in TEST_NARRATIVE:
		var newNarrative = Narrative.new()
		var narrativeData = TEST_NARRATIVE[key].duplicate()
		
		newNarrative.parentAnomoly = anom # passing in anomoly from refrence in case we need it.

		for param in narrativeData:
			newNarrative.set( param , TEST_NARRATIVE[key][param] )

		if( narrativeData.has("childNarratives") ):
			newNarrative.childNarratives = narrativeData["childNarratives"].duplicate()
		
		newNarrative.ownOptionKey = key
		allNarratives[key] = newNarrative

	# Bind all the narative keys to the actual objects by refrence. 
	for key in allNarratives:
		var narrative = allNarratives[key]

		if( narrative.childNarratives.size() >= 1):
			for x in range( 0 , narrative.childNarratives.size() ):
				#print( narrative.childNarratives[x] )
				narrative.childNarratives[x] = allNarratives[narrative.childNarratives[x]]

	return allNarratives

func generateSystemAnomolies( planets , star : Star , eventBus = null ):
	seed( star.getSeed() )
	randi()
	
	var anomArray = []
	var numOfAnoms = Common.randDiffValues( MIN_ANOMS_PER_SYSTEM , MAX_ANOMS_PER_SYSTEM )

	for x in range( 0 , numOfAnoms ):
		var randomPlanet = randi() % planets.size()
		var anom = generateAnomoly( planets[randomPlanet] , star , eventBus )
		anomArray.append( anom )

	
	for planet in planets:
		var anom = generateAnomoly( planet , star, eventBus , Anomoly.ANOM_TYPES.ORBIT )
		anomArray.append( anom )

		# TODO -- when should a station appear?
		# if( planet.isHabitable ):
		var dock = generateAnomoly( planet , star, eventBus , Anomoly.ANOM_TYPES.ORBIT_DOCK )
		anomArray.append( dock )

	return anomArray
