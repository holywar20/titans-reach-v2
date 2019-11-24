extends Panel 

const BASE_SCALE = 100

const ORBIT_DISTANCE = 13 # space that seperates various planets
const ORBIT_OFFSET = 10 # space that is available
const LINE_SEGMENTS = 30

var planetTexture = load("res://BorrowedArt/planetblank-small.png")

var planetDict = {}
var starDict = {}
var scaleFactor = 1

var centerPoint = Vector2( 0 , 0 )

onready var myStarNode = get_node("Star")
onready var shipNode = get_node("Ship")
onready var planetBase = get_node("Planets")

var shipMovementUpdateEventKey = null 
var timeUpdateEventKey = null

func _ready():
	self.shipMovementUpdateEventKey = EventBus.register( EventBus.GLOBAL_STARSHIP_MOVEMENT , self, "moveShipPosition", true)
	
	var mapSize = self.get_size()
	self.centerPoint = Vector2( (mapSize.x / 2 ) , (mapSize.y / 2 ) )

func _exit_tree():
	EventBus.unregister( EventBus.GLOBAL_STARSHIP_MOVEMENT , self.shipMovementUpdateEventKey )

func initMap( planetDict , starDict ):
	self.planetDict = planetDict
	self.starDict = starDict
	self.scaleFactor = self.BASE_SCALE / starDict.orbitSize

	var myTexture = load( self.starDict.IconTexturePath )
	self.myStarNode.set_texture( myTexture )

func clear():
	var planets = self.planetBase.get_children()
	
	if( planets ):
		for planet in planets:
			planet.queue_free()

func _draw():
	var orbit = 0

	for planet in self.planetDict:
		orbit = orbit + 1
		
		if( planet ):
			var orbitColor = Color( .2, .4, .2 , float(orbit) / 20 + .5  )
			var orbitDistance =  ( self.ORBIT_DISTANCE * orbit ) + self.ORBIT_OFFSET
			self.drawCircle( centerPoint , orbitDistance , orbitColor , 2 )

func moveShipPosition( rotation , shipPosition ):
	
	self.shipNode.set_rotation( rotation )
	self.shipNode.position = self.centerPoint + ( shipPosition / self.scaleFactor )

func placeNewPlanet( orbit , radial, color ):
	
	var orbitDistance =  ( self.ORBIT_DISTANCE * orbit ) + self.ORBIT_OFFSET
	var position =  ( radial * orbitDistance ) + self.centerPoint

	var newPlanet = Sprite.new()

	newPlanet.set_texture( self.planetTexture )
	newPlanet.set_self_modulate( color )
	newPlanet.set_global_position( position )
	self.planetBase.add_child( newPlanet )
	
func drawCircle( center, radius, color, lineWidth  ):
	var points_arc = PoolVector2Array()

	for segment in range( self.LINE_SEGMENTS + 1 ):
		var angle_point = ( segment * 360 ) / self.LINE_SEGMENTS - 90
		var point = center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius
		points_arc.push_back(point)
	
	for index_point in range( self.LINE_SEGMENTS ):
		self.draw_line( points_arc[index_point], points_arc[index_point + 1], color , lineWidth )