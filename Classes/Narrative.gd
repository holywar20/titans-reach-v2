extends Node

class_name Narrative

# basic options 
var narrativeTitle = null
var narrativeImage = null
var narrativeText = null
var parentAnomoly = null

# Optional options
var childNarratives = []
var terminationEvent = null
var eventParams = null
var ownOptionKey = null
var ownOptionTitle = null
var ownOptionDetail = null 

# Flags
var isLeavable = false # Allows user to hit 'end' by closing the window. Not all narratives permit ending this way.

func getClass():
	return "Narrative"

func isClass( compareString : String ):
	return compareString == "Narrative"

func getOwnOption():
	var optionDict = {
		"Title"  : ownOptionTitle,
		"Detail" : ownOptionDetail,
		"Key"		: ownOptionKey
	}

	return optionDict

func getOptions():
	var optionDict = {}

	for child in childNarratives:
		var option = child.getOwnOption()
		optionDict[option.Key] = option

	return optionDict

# Returns narrative by option key, returns null if this narrative is terminating
func getNext( optionKey : String ):
	
	var next = null
	for narrative in childNarratives:
		if( narrative.ownOptionKey == optionKey ):
			next = narrative

	return next


func terminateNarrative( optionSelected ):
	if( terminationEvent ):
		print( "Resolving " , optionSelected )