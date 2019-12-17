extends Node

class_name ItemFactory

var itemFolder = null
var dataDictionary = {}

func _ready():
	pass

func _loadData():
	var files = []
	var dir = Directory.new()
	
	if( dir.open( self.itemFolder ) == OK ):
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
		for fileName in files:
			var path = self.itemFolder + fileName
			var file = File.new()
			file.open( path , file.READ )

			var text = file.get_as_text()
			var json = JSON.parse( text )
			var dict = json.get_result()

			for key in dict:
				self.dataDictionary[key] = dict[key]
	else:
		print("Files for FrameFactory didn't load. Something went wrong.")

# helper method that cleans up item dictionaries.
# TODO - this worth it as a helper method instead? seems generically useful for cleaning up old keys defensively.
func _cleanDictionary( dictionary : Dictionary ):
	
	# Dictionaries in Godot do not support iteration while deleting, so we make a list, and delete on that.
	var keysToErase = []

	for key in dictionary:
		if( !dictionary[key] ):
			keysToErase.append( key )
		
	for key in keysToErase:
		dictionary.erase( key )

	return dictionary
