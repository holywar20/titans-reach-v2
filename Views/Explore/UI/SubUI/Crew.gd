extends PanelContainer

var eventBus = null
var playerCrew = null 

var bases = {
	"unassigned" : get_node("Main/Left/VBox")
}

func setupScene( eventBus : EventBus , playerCrew ):
	self.eventBus = eventBus
	self.playerCrew = playerCrew

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")