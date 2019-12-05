extends HBoxContainer

var eventBus = null 
var consoleName = "Needs a name!"

var dragLockScene = load("res://ReusableUI/DragLock/SubClasses/ConsoleLock/ConsoleLock.tscn")

onready var nodes = {
	"Name" : get_node("Name"),
	"Consoles" 	: get_node("Consoles")
}

func setupScene( eventBus : EventBus , consoleName : String ):
	self.eventBus = eventBus
	self.consoleName = consoleName

func addConsole( console : Console ):
	var lock = dragLockScene.instance()
	lock.setupScene( self.eventBus , console.consoleName , console )
	
	self.nodes.Consoles.add_child( lock )

func _ready():
	self.nodes.Name.set_text( self.consoleName )
