extends Node

const PLANET_CHANCE_PER_ORBIT = 100 # percent chance a planet will be found any particular orbit.

var currentSeed = 10000

func _ready():
	pass

func generateRandomSystem( thisSeed = self.currentSeed ):

	var connections = self._generateNewConnections( thisSeed )
	var decorators = self._generateDecorators( thisSeed )
	var myPlanets = self._generateAllRandomPlanets( thisSeed , myStar , decorators )	

	var myStar = StarFactory.generateRandomStar( thisSeed )
	
	var myPlanets = "IMPLIMENT ME!"

	var starSystemDictionary = {
		'star' 			: myStar,
		'planets'		: myPlanets,
		'connections'	: connections
		# TODO - Events, Encounters, Text, etc
	}
	
	return starSystemDictionary

func _generateNewConnections( thisSeed ): # TODO - need this to be much more sophisticated. 
	seed( thisSeed )
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

func _generateAllRandomPlanets( thisSeed ):
	seed( thisSeed )
	randi()
	# TODO Generate Planets using PlanetFactory