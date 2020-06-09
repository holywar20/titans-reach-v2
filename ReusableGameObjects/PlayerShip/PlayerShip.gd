extends RigidBody2D

var rotationSpeed = 5
var rotationAcceleration = .1

# TODO - Set lower speed when not debugging, should be about 200 for acceleration & 500 for velocityMaxForward
var acceleration = 200
var velocityMaxForward = 1000

const MAX_ZOOM_IN = .5
const MAX_ZOOM_OUT = 6
const ZOOM_STEP = .05
const ROTATION_SPEED_THRESHOLD = 5
const MOVEMENT_SPEED_THRESHOLD = 1


var vectorDirection = Vector2(0,0)
var speed = 0

onready var myCamera = get_node("Camera")
onready var area2D = get_node("ShipArea") # I need this for collision detection of areas for some reason. Rigid2D Bodies can't poll for areas, only for bodies, and i'm using mostly areas.
onready var ship = get_node("Ship")
onready var viewPortCamera = get_node("../ViewPortCanvas/ViewportContainer/Celestials/Camera")

var eventBus = null
var starship = null

func _ready():
	set_position( Vector2( 0 ,100 ) )

func setEvents( eBus : EventBus ):
	eventBus = eBus

func setStarship( starship : Starship ):
	starship = starship

func _onAreaEntered( area : Area2D ):
	var objects = area2D.get_overlapping_areas()
	eventBus.emit( "PlayerContactingAreasUpdated" , [ objects ] )

func _onAreaExited( area : Area2D ):
	var objects = area2D.get_overlapping_areas()

	for x in range( 0, objects.size() ) :
		if( objects[x].get_name() == area.get_name() ):
			objects.erase( area )
			break
	
	eventBus.emit( "PlayerContactingAreasUpdated" , [ objects ] )

func _unhandled_input( ev ):
	# TODO - add some smoothing to this to make it look nicer.
	if( ev.is_action_pressed( "GUI_ZOOM_IN" ) ):
		var myZoom = myCamera.get_zoom() 
		
		if( myZoom.x > MAX_ZOOM_IN ):
			myCamera.set_zoom( Vector2(myZoom.x - ZOOM_STEP , myZoom.y - ZOOM_STEP) )
	
	if( ev.is_action_pressed( "GUI_ZOOM_OUT" ) ):
		var myZoom = myCamera.get_zoom() 
		
		if( myZoom.x < MAX_ZOOM_OUT ):
			myCamera.set_zoom( Vector2(myZoom.x + ZOOM_STEP  , myZoom.y + ZOOM_STEP  ) )

func _physics_process( delta ):
	if( Input.is_key_pressed( KEY_LEFT ) ):
		goRotation( -1, delta )

	if( Input.is_key_pressed( KEY_RIGHT ) ):
		goRotation( +1, delta )
	
	if( Input.is_key_pressed( KEY_UP ) ):
		accelerate( 1 , delta )
	elif( speed > 0 ):
		decelerate( delta )
	
	var angularVelocity = get_angular_velocity()
	var linearVelocity  = get_linear_velocity()
	
	if( abs(linearVelocity.x) <= ROTATION_SPEED_THRESHOLD ):
		linearVelocity.x = 0
	if( abs(linearVelocity.y) <= ROTATION_SPEED_THRESHOLD ):
		linearVelocity.y = 0
	if( abs(angularVelocity) <= MOVEMENT_SPEED_THRESHOLD ):
		angularVelocity = 0

	if( linearVelocity.x != 0 || linearVelocity.y != 0 || angularVelocity != 0 ):
		var position = myCamera.get_global_position()
		var viewPortCamPos = viewPortCamera.get_translation()

		var translatedVector3 = Common.translate2dPositionTo3d( position , viewPortCamPos.y )
		viewPortCamera.set_translation( translatedVector3 )
		#TODO - Update time

func goRotation( direction, delta ):
	var newRotationSpeed = get_angular_velocity() + ( rotationSpeed * delta * direction )

	if ( newRotationSpeed > rotationSpeed ):
		newRotationSpeed = 50
	if( newRotationSpeed < (rotationSpeed * -1 ) ):
		newRotationSpeed = -50

	set_angular_velocity( newRotationSpeed )

func decelerate( delta ):
	speed = max(0 , speed - (5 * delta * acceleration ) )
	
	vectorDirection = Vector2( cos( get_rotation() ), sin( get_rotation() ) )
	set_linear_velocity( vectorDirection * speed )

func accelerate( speedFactorIncrease , delta ):
	if( sleeping ):
		sleeping = false
	
	speed = speed + ( speedFactorIncrease * delta * acceleration )
	
	if( speed >= velocityMaxForward ):
		speed = velocityMaxForward
	
	vectorDirection = Vector2( cos( get_rotation() ), sin( get_rotation() ) )
	set_linear_velocity( vectorDirection * speed )

func updateShipStats():
	pass
	# rotationSpeed = ShipManager.getStatTotal( 'agility' )
	# acceleration  = ShipManager.getStatTotal( 'impulse' )

	# velocityMaxForward = acceleration * 5
	# velocityMaxBackward = acceleration * 5