extends HBoxContainer

var eventBus = null 
var consoleCategoryName = "Needs a name!"

var dragLockScene = load("res://ReusableUI/DragLock/DragLock.tscn")

onready var nodes = {
	"Name" : get_node("Name"),
	"Consoles" 	: get_node("Consoles")
}

func setupScene( eBus : EventBus , consoleName : String ):
	eventBus = eBus
	consoleCategoryName = consoleName

func addConsole( console : Console ):
	var lock = dragLockScene.instance()
	lock.setupScene( eventBus  , console , lock.RELATIONSHIPS.CREW_CONSOLE , console.consoleName , console.consoleName )
	
	nodes.Consoles.add_child( lock )

func _ready():
	nodes.Name.set_text( consoleCategoryName )
