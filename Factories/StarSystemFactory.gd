extends Node

const PLANET_CHANCE_PER_ORBIT = 100 # percent chance a planet will be found any particular orbit.

var currentSeed = null
var sectorPosition = Vector2( 0 , 0 )

# TODO - Turn this stars, connections and planets into objects
# Break out the generation methods, so it's possible to generate the same thing given a seed.

func _ready():
	pass

func generateRandomSystem( mySeed , x = 0 , y = 0 ):

	var myStar = StarFactory.generateRandomStar( Star.TEXTURE.FULL , mySeed )
	var connections = _generateNewConnections( mySeed )
	var myPlanets = _generateAllRandomPlanets( mySeed , myStar )	
	var myAnoms = _generateAnomolies( mySeed, myStar , myPlanets )

	var starSystem : StarSystem = StarSystem.new( myStar , myPlanets, myAnoms, connections, Vector2( x , y ) )

	return starSystem

func _generateNewConnections( mySeed ): # TODO - need this to be much more sophisticated. 
	seed( mySeed )
	randomize()

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
	randomize()

	var planets = PlanetFactory.generateAllPlanetsFromStar( star )

	return planets
			
func _generateAnomolies( mySeed, star , planets ):
	seed( mySeed )
	randomize()

	var anoms = AnomolyFactory.generateSystemAnomolies( planets, star )

	return anoms