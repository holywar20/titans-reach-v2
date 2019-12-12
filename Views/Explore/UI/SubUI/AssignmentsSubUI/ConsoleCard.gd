extends HBoxContainer

var eventBus = null 
var consoleCategoryName = "Needs a name!"

var dragLockScene = load("res://ReusableUI/DragLock/DragLock.tscn")

onready var nodes = {
	"Name" : get_node("Name"),
	"Consoles" 	: get_node("Consoles")
}

func setupScene( eventBus : EventBus , consoleName : String ):
	self.eventBus = eventBus
	self.consoleCategoryName = consoleName

func addConsole( console : Console ):
	var lock = dragLockScene.instance()
	lock.setupScene( self.eventBus  , console , lock.RELATIONSHIPS.CREW_CONSOLE , console.consoleName )
	
	self.nodes.Consoles.add_child( lock )

func _ready():
	self.nodes.Name.set_text( self.consoleCategoryName )
