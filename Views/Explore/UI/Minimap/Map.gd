extends Panel

const ORBIT_DISTANCE = 13 # space that seperates each orbit
const ORBIT_OFFSET = 13 #  Space we need to accomidate the sun.
const LINE_SEGMENTS = 20

var mapSize = get_size()
var center = Vector2( (mapSize.x / 2 ) , (mapSize.y / 2 ) )

var eventBus = null

var celestials = {
	'Star'		: get_node("Star"),
	# 'Anomolies'	: get_node("Anomolies")
	'Planets'	: get_node("Planets"),
	#'Ship'		: get_node("Ship"),
}

func _ready():
	pass

func setEvents( eBus : EventBus ):
	eventBus = eBus

	eventBus.register("CelestialsLoadedOnMap", self, "_initMap")

func _initMap( planets, star , anomolies ):
	celestials.Star.set_self_modulate( star.getColor() )
	
	var orbit = 0
	for planet in planets:
		orbit = orbit + 1
		var position = ( planet.radial * _getPlanetDistance( orbit ) ) + center
		
		var texture = Sprite.new()
		texture.set_texture( load( planet.getIconTexturePath() ) )
		texture.set_self_modulate( planet.getColor() )
		texture.set_global_position( position )
		celestials.Planets.add_child( texture )

	# TODO - do something with anomolies

func _draw():
	for x in range( 1 , 9 ):
		var myRadius = _getPlanetDistance( x )
		var myOrbitColor = Color( .2, .4, .2 , float(x) / 20 + .5 )
		_drawCircle( center , myRadius , myOrbitColor )

func _drawCircle( center, radius, color, lineWidth = 2 ):
	var points_arc = PoolVector2Array()

	for segment in range( LINE_SEGMENTS + 1 ):
		var angle_point = ( segment * 360 ) / LINE_SEGMENTS - 90
		var point = center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius
		points_arc.push_back(point)
	
	for index_point in range( LINE_SEGMENTS ):
		draw_line( points_arc[index_point], points_arc[index_point + 1], color , lineWidth )

func _starClicked():
	pass

func _planetClicked():
	pass

func _getPlanetDistance( orbit ):
	return ORBIT_OFFSET + ( orbit * ORBIT_DISTANCE )