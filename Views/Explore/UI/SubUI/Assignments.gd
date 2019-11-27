extends PanelContainer

var eventBus = null

var bases = {
	"unassigned" : get_node("Main/Left/VBox")
}

func _ready():
	self.eventBus.emit("SubUIAnyOpenEnd")

func setEvents( eventBus : EventBus ):
	self.eventBus = eventBus