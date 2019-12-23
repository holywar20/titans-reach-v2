extends VBoxContainer

const INVALID_TARGET = Color( .8, .3 , .3 )
const VALID_TARGET = Color( .3, .8, .3)

# TODO - Figure out what's missing here.
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

func _ready():
	pass 

func loadItemData( item ):
	nodes.name.set_text( item.itemDisplayName )
	nodes.icon.set_texture( load(item.itemTexturePath) )

	_clearDisplay()

	if ( item.is_class("Weapon") ):
		_displayAsWeapon( item )
	if ( item.is_class("Frame") ):
		_displayAsFrame( item )
	if ( item.is_class("Equipment") ):
		_displayAsEquipment( item )

func _setTargeting( action ):
	nodes.targeting.set_visible( true )
	nodes.targetType.set_text( action.getTargetTypeString() )

	var validFrom = action.validFrom
	for x in range(3):
		var fromNode = nodes.targetFrom.get_node( "P_" + str( x ) )

		if( validFrom.has(x) ):
			fromNode.set_self_modulate( INVALID_TARGET )
		else :
			fromNode.set_self_modulate( VALID_TARGET )
		
	var validTargets = action.validTargets
	for x in range( 3 ): 
		var targetNode = nodes.targetTo.get_node( "T_" + str( x ) )

		if( validTargets.has(x) ):
			targetNode.set_self_modulate( VALID_TARGET )
		else: 
			targetNode.set_self_modulate( INVALID_TARGET )

func showCountLine( item = null ):
	if( item ):
		nodes.countLine.set_visible( true )
		nodes.countValue.set_text( str( item.getRemaining() ) )
		nodes.massValue.set_text( item.getMassDisplay() )
		nodes.volumeValue.set_text( item.getVolumeDisplay() )
	else:
		nodes.countLine.set_visible( false )

func _clearDisplay():
	
	nodes.description.set_visible( false )
	nodes.targeting.set_visible( false )

	nodes.subHeader.set_visible( false )
	nodes.subHeaderType.set_visible( false )
	nodes.subHeaderWeight.set_visible( false )

	nodes.countLine.set_visible( false )

func _displayAsWeapon( item  ):

	nodes.targeting.set_visible( true )
	nodes.subHeader.set_visible( true )

	nodes.subHeaderWeight.set_visible( true )
	nodes.subHeaderWeight.set_text( "Weight : " + str( item.itemCarryWeight ) )

	#Log.log(   item.getAllActionDisplay() )
	#_displayLines( item.getAllActionDisplay() )

func _displayAsEquipment( item  ):
	nodes.targeting.set_visible( true )
	nodes.subHeader.set_visible( true )

	nodes.subHeaderType.set_visible( true )
	nodes.subHeaderType.set_text( "Consumable" ) # TODO : add passive, once passive items are implimented

	nodes.subHeaderWeight.set_visible( true )
	nodes.subHeaderWeight.set_text( "Weight : " + str( item.itemCarryWeight ) )

	#_displayLines( item.getAllActionDisplay() )

func _displayAsFrame( item ):
	nodes.subHeader.set_visible( true )

	nodes.subHeaderType.set_visible( true )
	nodes.subHeaderType.set_text( item.frameClassString )

	nodes.subHeaderWeight.set_visible( true )
	nodes.subHeaderWeight.set_text( "Weight : " + str( item.itemCarryWeight ) )

	var lines = [ 
		"Damage Reduction : [color=green]" + str( item.frameArmorValue ) + "[/color]",
		"Inititive Penalty : [color=red]" + str( item.frameArmorValue ) + "[/color]"
	]

	_displayLines( lines )
	# TODO add iterator over item actions, if they exist
	nodes.description.set_visible( true )

func _displayLines( lines , append = false ):
	if( !append ):
		nodes.description.set_bbcode("")

	for line in lines:
		nodes.description.append_bbcode( line + "\n")