extends Node

class_name EventBus

var events = {} # A count of all the things registered for an event

func get_class(): 
	return "EventBus"

func is_class( name : String ): 
	return name == "EventBus"

func hasEvent( eventString ):
	if( events.has( eventString ) ):
		return true
	else:
		return false

func addEvents( eventStrings ):
	for eventName in eventStrings:
		add_user_signal( eventName )
		events[eventName] = 0

# Currently only supports up to 5 arguments. Godot signals don't use variable numbers of arguments.
# So yes - this ugly code exists, but it gets the job done, and it's contained here and can't spread.
func emit( eventName : String , p = [] ):
	if( !hasEvent( eventName) ) :
		print("Dev Warning : the event with eventName: " , eventName , " doesn't exist, but something is trying to emit it")
		return null
	else:
		print("Emitting Event : " , eventName ,  " with Payload " , p )

	if( p.size() >= 5 ):
		emit_signal( eventName , p[0], p[1] , p[2] , p[3] , p[4] )
	elif( p.size() == 4):
		emit_signal( eventName , p[0], p[1] , p[2] , p[3] )
	elif( p.size() == 3 ):
		emit_signal( eventName, p[0] , p[1], p[2] )
	elif( p.size() == 2 ):
		emit_signal( eventName, p[0] , p[1] )
	elif( p.size() == 1 ):
		emit_signal( eventName, p[0] ) 
	elif( true ): # Default
		emit_signal( eventName )

# TODO - Godot permits the connection to functions that don't exist. We could add some sanity checking here. 
# I should impliment logging first, so we have a place to dump non-fatal errors rather than just a print statment.
func register( eventName: String , ref : Node , functionName : String ):
	
	if( !ref.has_method( functionName ) ):
		print("Dev Warning::EventBus.register :  Method doesn't exist on the target node. : " , functionName  )

	events[eventName] = events[eventName] + 1
	connect( eventName , ref , functionName )

func unregister( eventName : String,  key ):
	# TODO  how would you unsubscribe from an event? Do we need this functionality?
	pass