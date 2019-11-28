extends RigidBody2D

var rotationSpeed = 10
var rotationAcceleration = .2

# TODO - Set lower speed when not debugging, should be about 200 for acceleration & 500 for velocityMaxForward
var acceleration = 10000
var velocityMaxForward = 5000

const MAX_ZOOM_IN = .5
const MAX_ZOOM_OUT = 6
const ZOOM_STEP = .05
const ROTATION_SPEED_THRESHOLD = 5
const MOVEMENT_SPEED_THRESHOLD = 1

var vectorDirection = Vector2(0,0)
var speed = 0

onready var myCamera = get_node("Camera")
onready var area2D = get_node("ShipArea") # I need this for collision detection of areas for some reason. Rigid2D Bodies can't poll for areas, only for bodies, and i'm using mostly areas.

var eventBus = null
var starship = null

func _ready():
	self.set_position( Vector2( 0 ,100 ) )

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func setStarship( starship : Starship ):
	self.starship = starship

func _onAreaEntered( area : Area2D ):
	var objects = self.area2D.get_overlapping_areas()
	self.eventBus.emit( "PlayerContactingAreasUpdated" , [ objects ] )

func _onAreaExited( area : Area2D ):
	var objects = self.area2D.get_overlapping_areas()

	for x in range( 0, objects.size() ) :
		if( objects[x].get_name() == area.get_name() ):
			objects.erase( area )
			break
	
	self.eventBus.emit( "PlayerContactingAreasUpdated" , [ objects ] )

func _unhandled_input( ev ):
	# TODO - add some smoothing to this to make it look nicer.
	if( ev.is_action_pressed( "GUI_ZOOM_IN" ) ):
		var myZoom = myCamera.get_zoom() 
		
		if( myZoom.x > self.MAX_ZOOM_IN ):
			myCamera.set_zoom( Vector2(myZoom.x - self.ZOOM_STEP , myZoom.y - self.ZOOM_STEP) )
	
	if( ev.is_action_pressed( "GUI_ZOOM_OUT" ) ):
		var myZoom = myCamera.get_zoom() 
		
		if( myZoom.x < self.MAX_ZOOM_OUT ):
			myCamera.set_zoom( Vector2(myZoom.x + self.ZOOM_STEP  , myZoom.y + self.ZOOM_STEP  ) )

func _physics_process( delta ):
	if( Input.is_key_pressed( KEY_LEFT ) ):
		self.goRotation( -1, delta )

	if( Input.is_key_pressed( KEY_RIGHT ) ):
		self.goRotation( +1, delta )
	
	if( Input.is_key_pressed( KEY_UP ) ):
		self.accelerate( 1 , delta )
	elif( self.speed > 0 ):
		self.decelerate( delta )
	
	var angularVelocity = self.get_angular_velocity()
	var linearVelocity  = self.get_linear_velocity()
	
	if( abs(linearVelocity.x) <= self.ROTATION_SPEED_THRESHOLD ):
		linearVelocity.x = 0
	if( abs(linearVelocity.y) <= self.ROTATION_SPEED_THRESHOLD ):
		linearVelocity.y = 0
	if( abs(angularVelocity) <= self.MOVEMENT_SPEED_THRESHOLD ):
		angularVelocity = 0

	if( linearVelocity.x != 0 || linearVelocity.y != 0 || angularVelocity != 0 ):
		pass
		# BIG TODO - Update time
		# World.addToTime( self.TIME_FACTOR * delta )
		#EventBus.emit( EventBus.GLOBAL_STARSHIP_MOVEMENT ,[ self.get_rotation() , self.get_global_position() ] )

func goRotation( direction, delta ):
	var newRotationSpeed = self.get_angular_velocity() + ( self.rotationSpeed * delta * direction )

	if ( newRotationSpeed > self.rotationSpeed ):
		newRotationSpeed = 50
	if( newRotationSpeed < (self.rotationSpeed * -1 ) ):
		newRotationSpeed = -50

	self.set_angular_velocity( newRotationSpeed )

func decelerate( delta ):
	self.speed = max(0 , self.speed - (5 * delta * acceleration ) )
	
	self.vectorDirection = Vector2( cos( self.get_rotation() ), sin( self.get_rotation() ) )
	self.set_linear_velocity( self.vectorDirection * self.speed )

func accelerate( speedFactorIncrease , delta ):
	if( self.sleeping ):
		self.sleeping = false
	
	self.speed = self.speed + ( speedFactorIncrease * delta * acceleration )
	
	if( self.speed >= self.velocityMaxForward ):
		self.speed = self.velocityMaxForward
	
	self.vectorDirection = Vector2( cos( self.get_rotation() ), sin( self.get_rotation() ) )
	self.set_linear_velocity( self.vectorDirection * self.speed )

func updateShipStats():
	pass
	# self.rotationSpeed = ShipManager.getStatTotal( 'agility' )
	# self.acceleration  = ShipManager.getStatTotal( 'impulse' )

	# self.velocityMaxForward = acceleration * 5
	# self.velocityMaxBackward = acceleration * 5