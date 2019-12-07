extends HBoxContainer

# TODO - have this populate by a class of some kind so we can configure the labels.
func setupScene( elements ):
	for x in range( 0 , elements.size() ):
		var label = Label.new()
		label.set_h_size_flags( Label.SIZE_EXPAND_FILL )
		label.set_text( str( elements[x] ) )
		
		if( x == 0 ):
			label.size_flags_stretch_ratio = 2
		else:
			label.set_align( label.ALIGN_CENTER )
			
		self.add_child( label )

func _ready():
	pass

func clear():
	for child in self.get_children():
		self.queue_free()