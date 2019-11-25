extends PanelContainer

var eventBus = EventBusStore.getEventBus( EventBusStore.BUS.EXPLORE )

var bases = {
	"unassigned" : get_node("Main/Left/VBox")
}

func _ready():


	self.eventBus.emit("SubUIAnyOpenEnd")
