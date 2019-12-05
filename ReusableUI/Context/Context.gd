extends PanelContainer

var eventBus = null

onready var nodes = {
	"ObjectName"	: get_node("VBox/ObjectName"),
	"DetailText"	: get_node("VBox/Detail/DetailText"),
	"Texture"		: get_node("VBox/Detail/Texture"),
	"MainText"		: get_node("VBox/Panel/MainText")
}

func _ready():
	self.set_visible( false )

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus

	self.eventBus.register( "StarClickedStart"	, self , "onStarClickedStart" )
	self.eventBus.register( "PlanetClickedStart"	, self , "onPlanetClickedStart")

	self.eventBus.register( "GeneralCancel" , self, "onGeneralCancel")

# Methods that respond to events
func onStarClickedStart( star : Star ):
	self.fillStarInfo( star )

func onPlanetClickedStart( planet : Planet ):
	self.fillPlanetInfo( planet )

func onGeneralCancel():
	self.resetContext()

# State manipulation of the context panel
func fillPlanetInfo( planet : Planet ):
	self.set_visible( true )

	self.nodes.ObjectName.set_text( planet.fullName )
	self.nodes.DetailText.set_bbcode( planet.getDetailText() )
	self.nodes.MainText.set_bbcode( planet.description )
	
	self.nodes.Texture.set_self_modulate( planet.color )

func fillStarInfo( star : Star ):
	self.set_visible( true )
	
	self.nodes.ObjectName.set_text( star.getName() )
	self.nodes.DetailText.set_bbcode("Star!")
	self.nodes.MainText.set_bbcode( star.description )

	self.nodes.Texture.set_self_modulate( star.color )

func resetContext():
	self.set_visible( false )

	self.nodes.ObjectName.set_text("")
	self.nodes.DetailText.set_bbcode("")
	self.nodes.MainText.set_bbcode("")
