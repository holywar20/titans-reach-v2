extends VBoxContainer

var eventBus

var optionKey
var optionDetail
var optionTitle

onready var nodes = {
	"Button" : get_node("Button") ,
	"Detail" : get_node("Detail")
}

func setupScene( eBus : EventBus, optionDict ):
	eventBus = eBus
	
	optionKey = optionDict.Key
	optionDetail = optionDict.Detail
	optionTitle = optionDict.Title

func _ready():
	nodes.Button.set_text( optionTitle )
	if( optionDetail ):
		nodes.Detail.set_text( optionDetail )
		nodes.Detail.show()
	else:
		nodes.Detail.hide()

func _onMouseEntered():
	print("Entering!")

func _onMouseExited():
	print("Exiting!")

func _onPressed():
	print("pressed the option!")
	eventBus.emit("NarrativeOptionSelected" , [ optionKey ] )
