extends Node2D

# All system objects should be added to this node.
onready var systemBase = get_node("System")
onready var anomBase = get_node("Anomolies")
onready var shipAvatar = get_node("PlayerShip")
onready var celestialBase = get_node("ViewPortCanvas/ViewportContainer/Celestials")

onready var starAvatarScene = load("res://ReusableGameObjects/Star/StarAvatar.tscn")

var eventBus = null
var globalEventBus = EventBusStore.getGlobalEventBus()

var planets = []

var star = null
var ship = null
var anoms = []
var connections = []

func _ready():
	globalEventBus.emit( "ExploreScreen_Open_Begin" , [ "EXPLORE" ] )
	eventBus.emit("CelestialsLoadingOnMap")

	ship = Starship.new()
	shipAvatar.setEvents( eventBus )
	shipAvatar.setStarship( ship )

	var starDictionary : StarSystem = StarSystemFactory.generateRandomSystem( 100000 )
	
	star = starDictionary.star
	planets = starDictionary.planets
	anoms = starDictionary.anoms
	connections = starDictionary.connections

	_buildStar( star )
	_buildPlanets( star , planets )
	_buildAnoms( star , planets , eventBus )

	# TODO - Hoist this into a loadSolarSystem method.
	##TODO - Clicking self event
	globalEventBus.emit( "ExploreScreen_Open_End" , [ "EXPLORE" ] )
	eventBus.emit("CelestialsLoadedOnMap" , [ planets, star , null ] )

func _exit_tree():
	globalEventBus.emit("ExploreScreen_Close_Begin" , [ "EXPLORE" ] )
	# Any clean up we care to do? 
	globalEventBus.emit("ExploreScreen_Close_End" , [ "EXPLORE" ] )

func _buildStar( star : Star ):

	# TODO - ability to have binary and or multiple kinds of stars
	star.set_global_position( Vector2( 0 , 0 ) )
	star.setEvents( eventBus )
	systemBase.add_child( star )

	var starAvatar = starAvatarScene.instance()
	starAvatar.setupScene( star )
	starAvatar.set_translation( Vector3(0 , 0 ,0 ) )
	celestialBase.add_child( starAvatar )

func _buildPlanets( star , planets ):
	for planet in planets:
		if( planet ):
			# Set up 2d Planet
			var orbitSize = star.getOrbitalDistance( planet.orbit )
			planet.set_global_position( planet.radial * orbitSize )
			planet.setEvents( eventBus )
			systemBase.add_child( planet )

			# Now add 3d Avatar
			var planetAvatar = planet.instanceAvatar()
			var planetPos = planet.get_global_position()
			var planetTranslation = Common.translate2dPositionTo3d( planetPos )
			planetAvatar.set_translation( planetTranslation )
			celestialBase.add_child( planetAvatar )
			
		else:
			pass

func _buildAnoms( star , planets, eventBus ):
	for anom in anoms:
		anom.setEvents( eventBus )
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
