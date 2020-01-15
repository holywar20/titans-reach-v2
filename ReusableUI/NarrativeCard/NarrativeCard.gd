extends PanelContainer

var parentNarrative
var eventBus

onready var nodes = {
	"Title" : get_node("VBox/TitleRow/Label") ,
	"Image" : get_node("VBox/MiddleRow/Texture") ,
	"Detail" : get_node("VBox/MiddleRow/Detail")
}

func setupScene( ebus : EventBus , narrative = null ):
	eventBus = ebus
	parentNarrative = narrative

	eventBus.register( "AnomolyClicked" , self , "_onAnomolyClicked" )

func _ready():
	hide()

func _onAnomolyClicked( narrative : Narrative ):
	print( narrative )
