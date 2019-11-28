extends TextureRect

var eventBus = null 
var matchCallBack = null
var match = null

func _setScene( eventBus : EventBus , matchTest , match ):
	self.eventBus = eventBus
	self.eventBus = eventBus

func _ready():
	pass

func _is_clicked():
	pass

func _draggableAccepted():
	self.eventBus.emit("DraggableAccepted")

func _draggableRejected():
	self.eventBus.emit("DraggableRejected")

func _draggableReceived( draggable ):
	pass
	# Unpack dragable
	# Run matchTest back
	# if -- false 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
