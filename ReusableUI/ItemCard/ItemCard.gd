extends VBoxContainer

const INVALID_TARGET = Color( .8, .3 , .3 )
const VALID_TARGET = Color( .3, .8, .3)

onready var nodes = {
	'name'			: get_node( "Header/Text/Name" ),
	'icon'			: get_node( "Header/Icon"),

	'targeting'		: get_node( "Targeting" ) ,
	'targetType'	: get_node( "Targeting/Type"),
	'targetFrom'	: get_node( "Targeting/From"),
	'targetTo'		: get_node( "Targeting/To"),

	'subHeader'		 	: get_node("Header/Text/Subheader"),
	'subHeaderType' 	: get_node("Header/Text/Subheader/Type"),
	'subHeaderWeight'	: get_node("Header/Text/Subheader/Weight"),

	'countLine'			: get_node("CountLine"),
	'countValue'		: get_node("CountLine/Count"),
	'massValue'			: get_node("CountLine/Mass"),
	'volumeValue'		: get_node("CountLine/Volume"),

	'description'		: get_node("Scroll/Text")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func loadItemData( item ):
	self.nodes.name.set_text( item.displayName )
	self.nodes.icon.set_texture( item.texture )

	self._clearDisplay()

	if ( item.category == ItemClass.CATEGORY.WEAPON ):
		self._displayAsWeapon( item )
	if( item.category == ItemClass.CATEGORY.FRAME ):
		self._displayAsFrame( item )
	if( item.category == ItemClass.CATEGORY.EQUIPMENT ):
		self._displayAsEquipment( item )

func _setTargeting( action ):
	self.nodes.targeting.set_visible( true )
	self.nodes.targetType.set_text( action.getTargetTypeString() )

	var validFrom = action.validFrom
	for x in range(3):
		var fromNode = self.nodes.targetFrom.get_node( "P_" + str( x ) )

		if( validFrom.has(x) ):
			fromNode.set_self_modulate( INVALID_TARGET )
		else :
			fromNode.set_self_modulate( VALID_TARGET )
		
	var validTargets = action.validTargets
	for x in range( 3 ): 
		var targetNode = self.nodes.targetTo.get_node( "T_" + str( x ) )

		if( validTargets.has(x) ):
			targetNode.set_self_modulate( VALID_TARGET )
		else: 
			targetNode.set_self_modulate( INVALID_TARGET )

func showCountLine( item = null ):
	if( item ):
		self.nodes.countLine.set_visible( true )
		self.nodes.countValue.set_text( str( item.getCount() ) )
		self.nodes.massValue.set_text( item.getMassDisplay() )
		self.nodes.volumeValue.set_text( item.getVolumeDisplay() )
	else:
		self.nodes.countLine.set_visible( false )

func _clearDisplay():
	
	self.nodes.description.set_visible( false )
	self.nodes.targeting.set_visible( false )

	self.nodes.subHeader.set_visible( false )
	self.nodes.subHeaderType.set_visible( false )
	self.nodes.subHeaderWeight.set_visible( false )

	self.nodes.countLine.set_visible( false )

func _displayAsWeapon( item : ItemClass ):

	self.nodes.targeting.set_visible( true )
	self.nodes.subHeader.set_visible( true )

	self.nodes.subHeaderWeight.set_visible( true )
	self.nodes.subHeaderWeight.set_text( "Weight : " + str( item.carryWeight ) )

	Log.log(   item.getAllActionDisplay() )
	self._displayLines( item.getAllActionDisplay() )

func _displayAsEquipment( item : ItemClass ):
	self.nodes.targeting.set_visible( true )
	self.nodes.subHeader.set_visible( true )

	self.nodes.subHeaderType.set_visible( true )
	self.nodes.subHeaderType.set_text( "Consumable" ) # TODO : add passive, once passive items are implimented

	self.nodes.subHeaderWeight.set_visible( true )
	self.nodes.subHeaderWeight.set_text( "Weight : " + str( item.carryWeight ) )

	self._displayLines( item.getAllActionDisplay() )

func _displayAsFrame( item : ItemClass ):
	self.nodes.subHeader.set_visible( true )

	self.nodes.subHeaderType.set_visible( true )
	self.nodes.subHeaderType.set_text( item.armorClass + " Frame" )

	self.nodes.subHeaderWeight.set_visible( true )
	self.nodes.subHeaderWeight.set_text( "Weight : " + str( item.carryWeight ) )

	var lines = [ 
		"Damage Reduction : [color=green]" + str( item.armorValue ) + "[/color]",
		"Inititive Penalty : [color=red]" + str( item.initPenalty ) + "[/color]"
	]

	self._displayLines( lines + item.getAllActionDisplay() )
	self.nodes.description.set_visible( true )

func _displayLines( lines , append = false ):

	if( !append ):
		self.nodes.description.set_bbcode("")

	for line in lines:
		self.nodes.description.append_bbcode( line )