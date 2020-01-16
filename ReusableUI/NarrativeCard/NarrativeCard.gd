extends PanelContainer


# For hiding the close button. Hiding normally displaces UI, so changing alpha keeps the spacing. 
const UNHIDE_BY_COLOR = Color( 1 , 1 , 1 , 1 )
const HIDE_BY_COLOR = Color( 1 , 1 ,1 , 0)

const TERMINATION_EVENTS = {
	"NarrativeBattleStart"	: "NarrativeBattleStart" ,
	"NarrativeLootStart"		: "NarrativeLootStart",
	"NarrativeOver"			: "NarrativeOver"
}
const TERMINATION_EVENT_DATA = {
	"NarrativeBattleStart": { "ButtonText" : "Start Battle" },
	"NarrativeLootStart"	 : { "ButtonText" : "Get Loot" },
	"NarrativeOver"		 : { "ButtonText" : "Leave" }
}

onready var nodes = {
	"Title" : get_node("VBox/TitleRow/Label") ,
	"Image" : get_node("VBox/MiddleRow/Texture") ,
	"Detail" : get_node("VBox/MiddleRow/Detail") ,
	"TerminationRow" : get_node("VBox/TerminationRow"),
	"TerminationButton" : get_node("VBox/TerminationRow/Button"),
	"CloseButton"	: get_node("VBox/TitleRow/CloseButton")
}

onready var optionBase = get_node("VBox/Choices")
onready var optionScene = load("res://ReusableUI/NarrativeCard/Option.tscn")

var eventBus
var GlobalEventBus

# State variables 
var currentNarrative
var currentOptions

func setupScene( eBus : EventBus ):
	eventBus = eBus
	GlobalEventBus = EventBusStore.getGlobalEventBus()

func _ready():
	eventBus.register("NarrativeOptionSelected" , self , "_onNarrativeOptionSelected")

func loadData( narrative = null ):
	if( !narrative ):
		hide()
		# Maybe this should destroy itself instead?
	else:
		currentNarrative = narrative

		if( currentNarrative.isLeavable ):
			nodes.CloseButton.set_self_modulate( UNHIDE_BY_COLOR )
			nodes.CloseButton.disabled = false
		else:
			nodes.CloseButton.set_self_modulate( HIDE_BY_COLOR )
			nodes.CloseButton.disabled = true

		if( currentNarrative.terminationEvent ):
			nodes.TerminationButton.set_text( TERMINATION_EVENT_DATA[currentNarrative.terminationEvent].ButtonText )
			nodes.TerminationRow.show()
		else:
			nodes.TerminationRow.hide()
		
		nodes.Title.set_text( currentNarrative.narrativeTitle )
		nodes.Image.set_texture( load( currentNarrative.narrativeImage ) )
		nodes.Detail.set_bbcode( currentNarrative.narrativeText )

		# Handle all the options
		for child in optionBase.get_children():
			child.queue_free()
		
		currentOptions = currentNarrative.getOptions()

		for key in currentOptions:
			var optionInstance = optionScene.instance()
			optionInstance.setupScene( eventBus , currentOptions[key] )
			optionBase.add_child( optionInstance )

		show()

func _onNarrativeOptionSelected( optionKey ):
	print( optionKey )
	var nextNarrative = currentNarrative.getNext( optionKey )
	print("Next Narrative!" , nextNarrative )

	loadData( nextNarrative )

func _onCloseButtonPressed():
	_terminateNarrative()

func _terminateNarrative():
	print("Terminating!")
	GlobalEventBus.emit( "ResolveAnomolyPopup" ,  [ currentNarrative.parentAnomoly ] )
	eventBus.emit( currentNarrative.terminationEvent , [ currentNarrative ] )

	queue_free()