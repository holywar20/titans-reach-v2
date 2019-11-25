extends Node2D

onready var systemBase = get_node("System")		# All system objects should be added to this node.
onready var starShip	= get_node("Starship")	# The Starship Node. #TODO Dynamically load this from a ship class.

var eventBus = EventBusStore.getEventBus( EventBusStore.BUS.EXPLORE )
var globalEventBus = EventBusStore.getGlobalEventBus()

var planetDict = {}
var starDict = {}

func _ready():
	self.globalEventBus.emit( "ExploreScreen_Open_Begin" , [ "EXPLORE" ] )

	var star = StarFactory.generateRandomStar( Star.TEXTURE.FULL )
	star.set_global_position( Vector2( 0 , 0 ) )
	self.systemBase.add_child( star )

	var planets = PlanetFactory.generateAllPlanetsFromStar( star )
	
	for planet in planets:
		if( planet ):
			var orbitSize = star.getOrbitalDistance( planet.orbit )
			var randomRadian = randf() * 3.14 * 2
			var orbitalPosition = Vector2( cos(randomRadian) , sin(randomRadian) )
			planet.set_global_position( orbitalPosition * orbitSize )
			self.systemBase.add_child( planet )
		else:
			pass
	## TODO - Clicking self event
	## TODO - clicking a planet event

	self.globalEventBus.emit( "ExploreScreen_Open_End" , [ "EXPLORE" ] )

func _unhandled_input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		self.eventBus.emit("GeneralCancel") 

func _exit_tree():
	self.globalEventBus.emit("ExploreScreen_Close_Begin" , [ "EXPLORE" ] )
	# Any clean up we care to do? 
	self.globalEventBus.emit("ExploreScreen_Close_End" , [ "EXPLORE" ] )

func _clearStarSystem():
	var myChildren = self.systemBase.get_children()
	for child in myChildren:
		child.queue_free()

func _positionStarship( someVector ):
	self.starShip.set_global_position( someVector )