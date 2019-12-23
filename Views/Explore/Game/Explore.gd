extends Node2D

# All system objects should be added to this node.
onready var systemBase = get_node("System")
onready var anomBase = get_node("Anomolies")
onready var shipAvatar = get_node("PlayerShip")

var eventBus = null
var globalEventBus = EventBusStore.getGlobalEventBus()

var star = null
var planets = null
var ship = null

func _ready():
	globalEventBus.emit( "ExploreScreen_Open_Begin" , [ "EXPLORE" ] )
	eventBus.emit("CelestialsLoadingOnMap")

	# TODO - take a seed
	_buildStar()
	_buildPlanets()
	_buildAnoms()

	ship = Starship.new()
	shipAvatar.setEvents( eventBus )
	shipAvatar.setStarship( ship )

	# TODO - Hoist this into a loadSolarSystem method.
	##TODO - Clicking self event
	globalEventBus.emit( "ExploreScreen_Open_End" , [ "EXPLORE" ] )
	eventBus.emit("CelestialsLoadedOnMap" , [ planets, star, null ] )

func _exit_tree():
	globalEventBus.emit("ExploreScreen_Close_Begin" , [ "EXPLORE" ] )
	# Any clean up we care to do? 
	globalEventBus.emit("ExploreScreen_Close_End" , [ "EXPLORE" ] )

func _buildStar():
	star = StarFactory.generateRandomStar( Star.TEXTURE.FULL )
	star.set_global_position( Vector2( 0 , 0 ) )
	star.setEvents( eventBus )
	systemBase.add_child( star )

func _buildPlanets():
	planets = PlanetFactory.generateAllPlanetsFromStar( star )

	for planet in planets:
		if( planet ):
			var orbitSize = star.getOrbitalDistance( planet.orbit )
			planet.set_global_position( planet.radial * orbitSize )
			planet.setEvents( eventBus )
			systemBase.add_child( planet )
		else:
			pass

func _buildAnoms():
	var anom = AnomolyFactory.generateAnomoly( null , eventBus )
	anomBase.add_child( anom ) 

func setEvents( eBus : EventBus ):
	eventBus = eBus

func _unhandled_input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		eventBus.emit("GeneralCancel") 

func _clearStarSystem():
	var myChildren = systemBase.get_children()
	for child in myChildren:
		child.queue_free()

func _positionStarship( someVector ):
	pass
	#starShip.set_global_position( someVector )