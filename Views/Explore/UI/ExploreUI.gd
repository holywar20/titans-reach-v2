extends Node

onready var miniMapContainer	= get_node("TravelUI/Bg")
onready var miniMapShowButton = get_node("TravelUI/ButtonContainer")
onready var miniMap 				= get_node("TravelUI/Bg/VBox/MiniMap")
onready var systemName			= get_node("TravelUI/Bg/VBox/StarName")

# for the context menu. May be good in a seperate scene, but works  here for now. 
const ALL_CONTEXT		= "TravelUI/Context"

const CONTEXT_LABEL	= "TravelUI/Context/ObjectType"
const STAR_CONTEXT	= "TravelUI/Context/Star"
const PLANET_CONTEXT	= "TravelUI/Context/Planet"

# TODO Place these in their own scene.
onready var timeNode = get_node("TravelUI/Bg/VBox/Date/Data")
onready var fuelNode = get_node("TravelUI/Bg/VBox/Fuel/Data")
onready var rationNode = get_node("TravelUI/Bg/VBox/Rations/Data")
onready var inkNode = get_node("TravelUI/Bg/VBox/Rations/Data")

onready var starContext = {
	'mass' : get_node( "TravelUI/Context/Star/VBox/Mass/Data" ),
	'class': get_node( "TravelUI/Context/Star/VBox/Class/Data"),
	'temp' : get_node( "TravelUI/Context/Star/VBox/Temp/Data"),
	'img'  : get_node( "TravelUI/Context/Star/Img"),
	'zone' : get_node( "TravelUI/Context/Star/VBox/Zone")
}

onready var planetContext = {
	"mass" 			: get_node("TravelUI/Context/Planet/VBox/Mass/Data"),
	"class"			: get_node("TravelUI/Context/Planet/VBox/Class/Data"),
	"temp" 			: get_node("TravelUI/Context/Planet/VBox/Temp/Data"),
	"img" 			: get_node("TravelUI/Context/Planet/Img"),
	"habitable"  	: get_node("TravelUI/Context/Planet/VBox/Habitable/Data")
}

func updateTime():
	self.timeNode.set_text( World.getTime() )
	self.fuelNode.set_text( str(ItemManager.getFuel() ) +" m3" )
	self.rationNode.set_text( str(ItemManager.getFood() )  + " m3" )

func _updatePlanetContext( planetData ):	
	self.planetContext['mass'].set_text( str( planetData.mass ) + " Terran M.")
	self.planetContext['class'].set_text( str( planetData.className ) )

	self.planetContext['temp'].set_text( str(planetData.temperature) )
	self.planetContext['habitable'].set_text( "No" )

	self.planetContext['img'].set_texture( planetData.largeTexture )
	self.planetContext.img.set_self_modulate( planetData.planetColor )

	get_node( self.CONTEXT_LABEL ).set_text( planetData.planetName )

func _updateStarContext( starData ):
	self.starContext['mass'].set_text( str(starData['Mass']) + " Solar M.")
	self.starContext['temp'].set_text( str(starData['Temp']) + "K" )
	self.starContext['class'].set_text( starData['ClassName'] + "(" + starData['Class'] + ")" )
	
	self.starContext['img'].set_texture( load( starData['SmallTexturePath'] )  )
	self.starContext['zone'].set_text( "Orbits : " + str(starData['boilLine']) + "-" + str(starData['freezeLine']) )

	get_node( self.CONTEXT_LABEL ).set_text( self.starName )
# Called when the node enters the scene tree for the first time.

func onMinimapTogglePressed():
	var myState = self.miniMapContainer.visible

	if( myState ):
		self.miniMapContainer.hide()
		self.miniMapShowButton.show()
	else:
		self.miniMapContainer.show()
		self.miniMapShowButton.hide()

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
