extends VBoxContainer

onready var tabBase		= get_node("Dynamic/Tab-Bind")

var eventBus = EventBusStore.getEventBus( EventBusStore.BUS.EXPLORE )

var subUIOpen = "None"

const MENU = { 
	'ASSIGNMENTS'	: "res://Views/Explore/UI/SubUI/Assignments.tscn" , 
	'CREW' 			: "res://Views/Explore/UI/SubUI/Crew.tscn" , 
	'EQUIPMENT'		: "res://Views/Explore/UI/SubUI/Equipment.tscn" ,  
	'SHIP'			: "res://Views/Explore/UI/SubUI/Ship.tscn" , 
	'CARGO'			: "res://Views/Explore/UI/SubUI/Cargo.tscn" , 
	'STARMAP'		: "res://Views/Explore/UI/SubUI/Starmap.tscn" ,  
}

func _ready():
	pass

func menuButtonPressed( menuTarget : String ):
	for tab in self.tabBase.get_children():
		tab.queue_free()

	if( self.subUIOpen == menuTarget ):
		self.eventBus.emit( "SubUICloseBegin" )
		self.subUIOpen = "None"
	else:
		self.subUIOpen = menuTarget
		self.eventBus.emit("SubUIOpenBegin")
		var subUI = load( self.MENU[menuTarget] )
		self.tabBase.add_child( subUI.instance() )