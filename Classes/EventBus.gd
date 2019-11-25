extends Node

class_name EventBus

const USES_PAYLOAD = true
const IGNORES_PAYLOAD = false

var noLogEvents = []
var eventStore = {}
var events = {}

# TODO - Make Global
const RAND_KEY_SIZE = 8
const RAND_KEY_SET = "ABCDEFGHIJKLMPNOPQRSTUVWXYZ0123456789"

func _ready():
	pass

func addEvents( eventStrings ):
	for eventName in eventStrings:
		self.add_user_signal( eventName )
		events[eventName] = 0

func emit( eventName , payLoad = null ):
	print("Emitting , " , eventName , payLoad )
	if( payLoad ):
		self.emit_signal( eventName , payLoad )
	else:
		self.emit_signal( eventName )

func register( eventName: String , ref : Node , functionName : String ):
	print("Registering for event , " , eventName )
	self.events[eventName] = events[eventName] + 1
	self.connect( eventName , ref , functionName )

func unregister( eventName ,  key ):
	if( !eventName || !key):
		# TODO - Add this to some form of logging
		return false # Need a valid key & name. Bailing for sake of app stability in the face of potentially bad refrences. 

	if( self.eventStore[eventName].has( key ) ):
		self.eventStore[eventName].erase( key )

# TODO - Make Global
func genRandomKey():
	var myKey = ""
	# TODO - a better way for random that doesn't involve string concatenation.

	for keyItem in range( self.RAND_KEY_SIZE ):
		var myKeyValue = randi()% self.RAND_KEY_SET.length()
		
		myKey += RAND_KEY_SET[myKeyValue]
	
	return myKey