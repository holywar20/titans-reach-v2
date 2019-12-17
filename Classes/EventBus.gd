extends Node

class_name EventBus

var events = {} # A count of all the things registered for an event

func get_class(): 
	return "EventBus"

func is_class( name : String ): 
	return name == "EventBus"

func addEvents( eventStrings ):
	for eventName in eventStrings:
		self.add_user_signal( eventName )
		self.events[eventName] = 0

# Currently only supports up to 5 arguments. Godot signals don't use variable numbers of arguments.
# So yes - this ugly code exists, but it gets the job done, and it's contained here and can't spread.
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

# TODO - Godot permits the connection to functions that don't exist. We could add some sanity checking here. 
# I should impliment logging first, so we have a place to dump non-fatal errors rather than just a print statment.
func register( eventName: String , ref : Node , functionName : String ):
	# print("Registering for event , " , eventName )
	self.events[eventName] = events[eventName] + 1
	self.connect( eventName , ref , functionName )

func unregister( eventName : String,  key ):
	# TODO  how would you unsubscribe from an event? Do we need this functionality?
	pass