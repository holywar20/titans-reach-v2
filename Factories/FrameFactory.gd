extends Node

const FRAME_DATA_DICTIONARY = "res://JsonData/Frames/"

var frameDictionary = {}

func _ready():
	print("Autoloading")
	var files = []
	var dir = Directory.new()
	
	if( dir.open( self.FRAME_DATA_DICTIONARY ) == OK ):
		dir.list_dir_begin( true, true) # Flags to skip hidden and navigational files

		# Loop through files and make an array.
		while true: 
			var file = dir.get_next()
			if file == "":
				break
			else:
				files.append(file)

		dir.list_dir_end()
		
		# loop though array, open each Json, and apply that dictionary
		# Note - this dictionary is only raw data, and doens't turn into objects until
		# other factory methods are called.
		print( "Files" , files )
		for fileName in files:
			var path = self.FRAME_DATA_DICTIONARY + fileName
			var file = File.new()
			file.open( path , file.READ )

			var text = file.get_as_text()
			var json = JSON.parse( text )
			var dict = json.get_result()

			for key in dict:
				print("Keys" , key )
				self.frameDictionary[key] = dict[key]
	else:
		print("Files for FrameFactory didn't load. Something went wrong.")

func generateFrameObject( key : String,  numberToGenerate : int = 0 ):
	
	if( !self.frameDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = self.frameDictionary[key]
	var newFrame = Frame.new( key )

	for key in itemDict:
		newFrame[key] = itemDict[key]

	newFrame.frameOwned = numberToGenerate

	return newFrame

func generateDebugFrames():
	var frames = {}

	frames["TerranLightFrame"] = self.generateFrameObject( "TerranLightFrame" , 10 )
	frames["TerranMediumFrame"] = self.generateFrameObject( "TerranMediumFrame" , 6 )
	frames["TerranHeavyFrame"] = self.generateFrameObject( "TerranHeavyFrame"  , 3 )
	frames["TerranAssaultFrame"] = self.generateFrameObject( "TerranAssaultFrame" , 1 )
	
	return frames