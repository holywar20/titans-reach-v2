extends Node

const MAX_ANOMS_PER_SYSTEM = 10
const MIN_ANOMS_PER_SYSTEM = 3

var anomolyScene = load("res://ReusableGameObjects/Anomoly/Anomoly.tscn")

func _ready():
	pass

func generateAnomoly( parentCelestial , eventBus = null ):
	var anom = anomolyScene.instance()

	if( eventBus ):
		anom.setEvents( eventBus )
	
	anom.set_global_position( Vector2( 0 , 0 ) )
	# TODO - work out global position based on random math & parent celestial
	# will need offsets for system / planet / orbit size. not sure best way to do that yet.
	
	return anom


func generateSystemAnomolies( planets : Planet , star : Star , anomolySeed : int ):
	seed( anomolySeed )
	randi()

	var numOfAnoms = Common.randDiffValues( MIN_ANOMS_PER_SYSTEM , MAX_ANOMS_PER_SYSTEM )

	for x in range( 1 , numOfAnoms ):
		pass

	# Each planet should get at least 1 anomoly, for orbiting
	# Generate additional anomolies for stations
	# Generate additional anomolies for discoverable orbital events
	for planet in planets:
		pass

	# Then generate an anomoly for the star
