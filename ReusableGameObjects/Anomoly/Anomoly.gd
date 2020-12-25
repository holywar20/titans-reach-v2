extends Area2D

class_name Anomoly

const ROTATION_SPEED = 1

onready var nodes = {
	"Sprite" : get_node("Sprite")
}

const ANOM_TYPES = {
	"SALVAGE"		: "SALVAGE" , 
	"ORBIT_EVENT" 	: "ORBIT_EVENT" , 
	"ORBIT_DOCK"	: "ORBIT_DOCK",
	"ORBIT"			: "ORBIT" 
}

const ANOM_TYPE_DATA = {
	"SALVAGE" : {
		"DistanceRange" : [ 100 , 1000 ],
		"Texture" 	: "res://icon.png",
		"ShowText"	: "{ShipType} - Wreck",
		"DefaultParams" : {
			"isForced" : true,
			"isVisible" : true
		}
	},
	"ORBIT_EVENT"	: { 
		"DistanceRange" : [ 0 , 100 ],
		"Texture" 	: "res://icon.png",
		"ShowText"	: "Orbit {Planet}",
		"DefaultParams" : {
			"isForced" : true
		}
	} ,
	"ORBIT_DOCK"		: { 
		"DistanceRange" : [ 0 , 100 ], 
		"Texture" 	: "res://TextureBank/Ships/base1-small.png",
		"ShowText"	: "Dock with {Station} orbiting {Planet}",
		"DefaultParams" : {
			"isVisible" : true 
		}
	} ,
	"ORBIT"			: { 
		"DistanceRange" : [ 0 , 1 ],
		"Texture" 	: "res://icon.png",
		"ShowText"	: "Orbit {Planet}",
		"DefaultParams": {
			
		}
	}
}

# other objects
var parentPlanet = null
var parentStar = null
var eventBus = null

# Class data
var anomSeed = null
var anomType = ANOM_TYPES.SALVAGE

# Flags
var isRotating = false
var isDockable = false
var isVisible = false
var isForced = false

var defaultNarrative = null
var resolvedNarrative = null


# Calculated data
var distanceFromParent = 0
var radial = Vector2()

func _ready():
	var data = ANOM_TYPE_DATA[anomType]
	nodes.Sprite.set_texture( load(data.Texture) )
	
	if( isVisible ):
		nodes.Sprite.show()
	else:
		nodes.Sprite.hide()

	if( isRotating ):
		pass
	
	set_global_position( parentPlanet.get_global_position() + ( radial * distanceFromParent ) )

# Setters
func setEvents( eBus : EventBus ):
	eventBus = eBus

func setParents( planet : Planet , star : Star ):
	parentPlanet = planet
	parentStar = star 

func setAnomType( newAnomType ):
	
	if( !newAnomType ):
		anomType = ANOM_TYPES.SALVAGE
	else:
		anomType = newAnomType

	# Set any parameters we care about
	var params = ANOM_TYPE_DATA[anomType].DefaultParams
	for key in params:
		set( key , params[key] )
	
	# Figure out position
	var randomRadian = randf() * 3.14 * 2
	radial = Vector2( cos(randomRadian) , sin(randomRadian) )
	var dist = ANOM_TYPE_DATA[anomType].DistanceRange
	distanceFromParent = Common.randDiffValues( dist[0] , dist[1] )

func getNarrative():
	# Add support for multiple narritives
	return defaultNarrative

# Getters
func getShowText():
	var data = ANOM_TYPE_DATA[anomType]
	var text = ""

	if( anomType == ANOM_TYPES.SALVAGE ):
		text = data.ShowText.format( { "Faction" : "The Accord"} )
	elif( anomType == ANOM_TYPES.ORBIT_EVENT ):
		text = data.ShowText.format( { "Planet" : ""})
	elif( anomType == ANOM_TYPES.ORBIT_DOCK ):
		text = data.ShowText.format( { "Station" : "XYZ" , "Planet" : parentPlanet.getFullName() } )
	elif( anomType == ANOM_TYPES.ORBIT ):
		text = data.ShowText.format( {"Planet" : parentPlanet.getFullName() } )

	return text

func _onAreaClicked():
	if( eventBus ):
		eventBus.emit( "AnomolyClicked" , [ defaultNarrative ] )