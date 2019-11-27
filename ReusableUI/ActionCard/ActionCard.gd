extends VBoxContainer

var action = null

func _ready():
	pass

func initCard( action ):
	self.action = action

	Log.d( action )

