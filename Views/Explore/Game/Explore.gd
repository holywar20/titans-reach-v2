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
	self.globalEventBus.emit( "ExploreScreen_Open_Begin" , [ "EXPLORE" ] )
	self.eventBus.emit("CelestialsLoadingOnMap")

	# TODO - take a seed
	self._buildStar()
	self._buildPlanets()
	self._buildAnoms()

	self.ship = Starship.new()
	self.shipAvatar.setEvents( self.eventBus )
	self.shipAvatar.setStarship( self.ship )

	# TODO - Hoist this into a loadSolarSystem method.
	##TODO - Clicking self event
	self.globalEventBus.emit( "ExploreScreen_Open_End" , [ "EXPLORE" ] )
	self.eventBus.emit("CelestialsLoadedOnMap" , [ planets, star, null ] )

func _exit_tree():
	self.globalEventBus.emit("ExploreScreen_Close_Begin" , [ "EXPLORE" ] )
	# Any clean up we care to do? 
	self.globalEventBus.emit("ExploreScreen_Close_End" , [ "EXPLORE" ] )

func _buildStar():
	self.star = StarFactory.generateRandomStar( Star.TEXTURE.FULL )
	self.star.set_global_position( Vector2( 0 , 0 ) )
	self.star.setEvents( self.eventBus )
	self.systemBase.add_child( star )

func _buildPlanets():
	self.planets = PlanetFactory.generateAllPlanetsFromStar( star )

	for planet in planets:
		if( planet ):
			var orbitSize = star.getOrbitalDistance( planet.orbit )
			planet.set_global_position( planet.radial * orbitSize )
			planet.setEvents( self.eventBus )
			self.systemBase.add_child( planet )
		else:
			pass

func _buildAnoms():
	var anom = AnomolyFactory.generateAnomoly( null , self.eventBus )
	self.anomBase.add_child( anom ) 

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func _unhandled_input( event ):
	if( event.is_action_pressed("GUI_UNSELECT") ):
		self.eventBus.emit("GeneralCancel") 

func _clearStarSystem():
	var myChildren = self.systemBase.get_children()
	for child in myChildren:
		child.queue_free()

func _positionStarship( someVector ):
	self.starShip.set_global_position( someVector )