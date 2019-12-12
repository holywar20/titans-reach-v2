extends ItemFactory

func _ready():
	self.itemFolder = "res://JsonData/Frames/"
	self._loadData()

func generateFrameObject( key : String,  numberToGenerate : int = 0 ):
	
	if( !self.dataDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = self.dataDictionary[key]
	var newFrame = Frame.new( key )
	
	# Index through dictionary, and apply any values onto the pboject.
	for key in itemDict:
		newFrame[key] = itemDict[key]

	newFrame.itemOwned = numberToGenerate

	# set any metadata specific to frames & Equipment
	newFrame.itemIsCrewEquipable = true

	# Now index into the dictionary constant and populate those values
	var constVals = newFrame.FRAME_CLASS_DATA[newFrame.frameClass]
	for key in constVals:
		newFrame[key] = constVals[key] 

	# TODO - if not common, roll any random attributes. OR potentially set them manually in code.
	
	return newFrame

func generateDebugFrames():
	var frames = {}

	frames["TerranLightFrame"] = self.generateFrameObject( "TerranLightFrame" , 10 )
	frames["TerranMediumFrame"] = self.generateFrameObject( "TerranMediumFrame" , 6 )
	frames["TerranHeavyFrame"] = self.generateFrameObject( "TerranHeavyFrame"  , 3 )
	frames["TerranAssaultFrame"] = self.generateFrameObject( "TerranAssaultFrame" , 1 )
	
	frames = self._cleanDictionary( frames )

	return frames