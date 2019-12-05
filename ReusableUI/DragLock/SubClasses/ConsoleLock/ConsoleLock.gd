extends "res://ReusableUI/DragLock/DragLock.gd"

# crewman should come from the draggable payload
var crewman = null

# console should come from ConsoleLock inititilization
var console = null

func setupScene( eventBus : EventBus , displayName : String , console : Console ):
	# TODO - add Code for setting size for the drag lock somehow.
	self.eventBus = eventBus
	self.displayName = displayName
	self.console = console

	self.eventBus.register( "DraggableReleased" , self , "_onDraggableReleased" )

func _ready():
	pass # Replace with function body.

func _gui_input ( guiEvent : InputEvent ):
	if( guiEvent.is_action_pressed( "GUI_SELECT" ) && self.crewman ):
		self._createDraggable( guiEvent , self.crewman )
		self.eventBus.emit("CrewmanSelected" , [ self.crewman ] )

func _onDraggableReleased( crewman : Crew  , draggableDroppedLocation : Vector2 ):
	# TODO  figure out a way to add a validation function
	var inArea = false
	if( self._isInArea( draggableDroppedLocation ) ):
		inArea = true

	var assignableStatus : String = self.console.isAssignable( crewman )

	if( inArea ):
		if( assignableStatus == self.console.ASSIGNABLE ):
			self.console.assignCrewman( crewman )
			self.crewman = crewman
			self.nodes.Image.set_texture( load( crewman.smallTexturePath ) )

			self.eventBus.emit( "DraggableAccepted" )
			self.eventBus.emit( "CrewAssignmentChanged" )
		else:
			self.eventBus.emit( "DraggableRejected" , [ assignableStatus ] )
	else:
		if( self.myDraggableBeingDragged ):
			self.console.assignCrewman()
			self.crewman = null
			self.nodes.Image.set_texture( load( self.DEFAULT_TEXTURE ) )
			self.myDraggableBeingDragged = false

			self.eventBus.emit( "DraggableAccepted" )
			self.eventBus.emit( "CrewAssignmentChanged" )
		else:
			# Do Nothing. The draggable in question has nothing to do with you
			pass
