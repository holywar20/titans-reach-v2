extends Node

class_name Narrative

# basic options 
var narrativeTitle = null
var narrativeImage = null
var narrativeText = null

# Optional options
var childNarratives = []
var terminationEvent = null
var eventParams = null
var ownOptionKey = null
var ownOptionTitle = null
var ownOptionDetail = null 

func getClass():
	return "Narrative"

func isClass( compareString : String ):
	return compareString == "Narrative"

func getOwnOption():
	var dictionary = {
		"Title"  : ownOptionTitle,
		"Detail" : ownOptionDetail,
		"Key"		: ownOptionKey
	} 

func getOptions():
	var optionArray = []

	for child in childNarratives:
		optionArray.append( child.getOwnOption() )

func getNext( optionKey : String ):
	pass

func terminateNarrative( optionSelected ):
	if( terminationEvent ):
		print( "Resolving " , optionSelected )