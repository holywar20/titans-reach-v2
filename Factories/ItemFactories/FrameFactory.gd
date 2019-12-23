extends ItemFactory

func _ready():
	itemFolder = "res://JsonData/Frames/"
	_loadData()

func generateFrameObject( key : String,  numberToGenerate : int = 0 , rarity = null ):
	
	if( !dataDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = dataDictionary[key]
	var newFrame = Frame.new( key )
	
	# Index through dictionary, and apply any values onto the pboject.
	for key in itemDict:
		newFrame[key] = itemDict[key]

	newFrame.itemOwned = numberToGenerate

	# set any metadata specific to Frames that isn't loaded via dictionary
	newFrame.itemIsCrewEquipable = true

	# Now index into the frame dictionary and populate those values
	var constVals = newFrame.FRAME_CLASS_DATA[newFrame.frameClass]
	for key in constVals:
		newFrame[key] = constVals[key] 

	if( rarity ):
		pass
		# TODO - if not common, roll any random attributes. OR potentially set them manually in code.
	
	return newFrame

func generateDebugFrames():
	var frames = {}

	frames["TerranLightFrame"] = generateFrameObject( "TerranLightFrame" , 10 )
	frames["TerranMediumFrame"] = generateFrameObject( "TerranMediumFrame" , 6 )
	frames["TerranHeavyFrame"] = generateFrameObject( "TerranHeavyFrame"  , 3 )
	frames["TerranAssaultFrame"] = generateFrameObject( "TerranAssaultFrame" , 1 )
	
	frames = _cleanDictionary( frames )

	return frames