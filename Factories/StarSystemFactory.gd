extends Node

const PLANET_CHANCE_PER_ORBIT = 100 # percent chance a planet will be found any particular orbit.

var currentSeed = null

func _ready():
	pass

func generateRandomSystem( mySeed ):

	var myStar = StarFactory.generateRandomStar( Star.TEXTURE.FULL , mySeed )
	var connections = _generateNewConnections( mySeed )
	var myPlanets = _generateAllRandomPlanets( mySeed , myStar )	
	var myAnoms = _generateAnomolies( mySeed, myStar , myPlanets )

	var starSystemDictionary = {
		'star' 			: myStar,
		'planets'		: myPlanets,
		'anoms'			: myAnoms,
		'connections'	: connections
		# TODO - Events, Encounters, Text, etc
	}
	
	return starSystemDictionary

func _generateNewConnections( mySeed ): # TODO - need this to be much more sophisticated. 
	seed( mySeed )
	randi()

	var numConnections = randi()%5 + 3
	var connectionArray = []
	var newConnectionKey = null

	for connection in range( 0, numConnections ):
		newConnectionKey = randi()
		
		connectionArray.append({
			'key' 		: newConnectionKey,
			'degrees'	: null
		})
	
	var currentDegrees = 1
	for connect in connectionArray:
		connect.degrees = randi() % 60 + currentDegrees
		currentDegrees += connect.degrees

func _generateAllRandomPlanets( mySeed , star ):
	seed( mySeed )
	randi()

	var planets = PlanetFactory.generateAllPlanetsFromStar( star )

	return planets
			
func _generateAnomolies( mySeed, star , planets ):
	seed( mySeed )
	randi()

	var anoms = AnomolyFactory.generateSystemAnomolies( planets, star )

	return anoms