extends VBoxContainer

var action = null

func _ready():
	pass

func initCard( action ):
	action = action

	Log.d( action )

