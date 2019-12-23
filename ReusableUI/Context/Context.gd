extends PanelContainer

var eventBus = null

onready var nodes = {
	"ObjectName"	: get_node("VBox/ObjectName"),
	"DetailText"	: get_node("VBox/Detail/DetailText"),
	"Texture"		: get_node("VBox/Detail/Texture"),
	"MainText"		: get_node("VBox/Panel/MainText")
}

func _ready():
	set_visible( false )

func setEvents( eBus : EventBus ):
	eventBus = eBus

	eventBus.register( "StarClickedStart"	, self , "onStarClickedStart" )
	eventBus.register( "PlanetClickedStart"	, self , "onPlanetClickedStart")

	eventBus.register( "GeneralCancel" , self, "onGeneralCancel")

# Methods that respond to events
func onStarClickedStart( star : Star ):
	fillStarInfo( star )

func onPlanetClickedStart( planet : Planet ):
	fillPlanetInfo( planet )

func onGeneralCancel():
	resetContext()

# State manipulation of the context panel
func fillPlanetInfo( planet : Planet ):
	set_visible( true )

	nodes.ObjectName.set_text( planet.fullName )
	nodes.DetailText.set_bbcode( planet.getDetailText() )
	nodes.MainText.set_bbcode( planet.description )
	
	nodes.Texture.set_self_modulate( planet.color )

func fillStarInfo( star : Star ):
	set_visible( true )
	
	nodes.ObjectName.set_text( star.getName() )
	nodes.DetailText.set_bbcode("Star!")
	nodes.MainText.set_bbcode( star.description )

	nodes.Texture.set_self_modulate( star.color )

func resetContext():
	set_visible( false )

	nodes.ObjectName.set_text("")
	nodes.DetailText.set_bbcode("")
	nodes.MainText.set_bbcode("")
