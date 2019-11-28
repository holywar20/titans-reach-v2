extends Node

class_name EventBus

# LONG TODO - EventBus Phase 2
var events = {} # A count of all the things registered for an event

func _ready():
	pass

func addEvents( eventStrings ):
	for eventName in eventStrings:
		self.add_user_signal( eventName )
		self.events[eventName] = 0

# Currently only supports up to 5 arguments. Godot signals don't use variable numbers of arguments.
# So yes - this ugly code exists, but it gets the job done, and it's contained here.
func emit( eventName : String , p = [] ):
	# print("Emitting Event : " , eventName ,  " with Payload " , p )

	if( p.size() >= 5 ):
		self.emit_signal( eventName , p[0], p[1] , p[2] , p[3] , p[4] )
	elif( p.size() == 4):
		self.emit_signal( eventName , p[0], p[1] , p[2] , p[3] )
	elif( p.size() == 3 ):
		self.emit_signal( eventName, p[0] , p[1], p[2] )
	elif( p.size() == 2 ):
		self.emit_signal( eventName, p[0] , p[1] )
	elif( p.size() == 1 ):
		self.emit_signal( eventName, p[0] ) 
	elif( true ): # Default
		self.emit_signal( eventName )

func register( eventName: String , ref : Node , functionName : String ):
	print("Registering for event , " , eventName )
	self.events[eventName] = events[eventName] + 1
	self.connect( eventName , ref , functionName )

func unregister( eventName : String,  key ):
	# TODO  how would you unsubscribe from an event?
	pass