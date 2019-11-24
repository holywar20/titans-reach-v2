extends Node

onready var systemBase  = get_node("System")		# All system objects should be added to this node.
onready var starShip		= get_node("Starship")	# The Starship Node. #TODO Dynamically load this from a ship class.

# The event bus.
var eventBus = GameWorld.getEventBus( "EXPLORE" )

onready var planetScene = load("res://TravelMap/CelestialBodies/Planet.tscn")
onready var starScene = load("res://TravelMap/CelestialBodies/Star.tscn")

const AU = 1000 # Scaling factor for all planet orbits
const PLANET_SCALE = 10 #Scaling factor for all planet sizes

var starName = null
var decorators = []
var planetDict = {}
var starDict = {}

var events = [
	"StarClickedStart" , "StarClickedEnd" ,
	"PlanetClickedStart" , "PlanetClickedEnd",
	# TODO - Add click handlers for events that don't exist yet.
]

func _process( delta ):
	pass
	#self.miniMap.update()

func _ready():
	var star = StarFactory.generateRandomStar( StarFactory.TEXTURE.FULL )
	star.set_global_position( Vector2(0 , 0) )
	self.systemBase.add_child( star )

	## TODO - CLicking a planet event
	## TODO --clicking an object event
	## TODO - Clicking self event
	## TODO - clicking a planet event
	## self.updateTime()

func _exit_tree():
	pass

# TODO - we probally needs this. 
func _unhandled_input( ev ):
	if( Input.is_mouse_button_pressed( BUTTON_LEFT ) ):
		pass
	if( Input.is_mouse_button_pressed( BUTTON_RIGHT ) ):
		pass

func updateTravelSelect( itemType = null, itemData = null ):
	pass
	# TODO - send a signal through event bus to distant end. 

func _clearStarSystem():
	var myChildren = self.systemBase.get_children()
	for child in myChildren:
		child.queue_free()

func _positionStarship( someVector ):
	self.starShip.set_global_position( someVector )

func gotoNewStarSystem( mySeed , someRadialVector = 0):
	self._clearStarSystem()
	# var dict = StarSystemGenerator.generateRandomSystem( mySeed )
	# self.populateStarSystem( dict.star , dict.planets, dict.connections, dict.decorators )

func populateStarSystem( starDict , planetDict , connections, decorators ):
	self._clearStarSystem()
	# TODO add minimap link + events
	
	self.starDict = starDict
	self.planetDict = planetDict

	self.starName = decorators.fname + " " + decorators.lname
	self.decorators = decorators
	self.systemName.set_text( self.starName )

	var myStarInstance = self.starScene.instance()
	myStarInstance.constructStar( starDict , connections , decorators  )
	self.systemBase.add_child( myStarInstance )
	
	var myPosition = null
	var lastPosition = null

	for orbit in planetDict:
		var planetObject = planetDict[orbit]
		if( planetObject.planetClass == "None" ):
			continue
		
		var myPlanetInstance = self.planetScene.instance()
		myPlanetInstance.set_name( planetObject.planetName )
		self.systemBase.add_child( myPlanetInstance )
		var orbitSize = AU + ( starDict['orbitSize'] * orbit * AU )
		
		var randomRadian = randf() * 3.14 * 2
		myPosition = Vector2( cos(randomRadian) , sin(randomRadian) )
		
		planetObject.radial = myPosition

		myPlanetInstance.set_global_position( myPosition * orbitSize )
		myPlanetInstance.constructPlanet( planetObject )
		
		myStarInstance.setOrbit(orbit , orbitSize )
		self.miniMap.placeNewPlanet( orbit, myPosition , planetObject.planetColor )

		lastPosition = myPosition * orbitSize
	
	myStarInstance.update()
	self._positionStarship( ( lastPosition ) + Vector2( 50, 50 ) ) # currently just orbits last planet on entering system. 