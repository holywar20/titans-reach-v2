extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

var coreDB : SQLite
var saveDB : SQLite
var coreDBPath : String = "res://Data/Core";
var saveDBPath : String;

func _ready():
	coreDB = SQLite.new();
	coreDB.path = coreDBPath;
	coreDB.verbose_mode = true;
	coreDB.open_db();

	# Get path for saveDB
	#open it as well.

# Gets a single core Item.
# NOTE : This method returns a core item instance. It's meant for creating new items.
# Any 'saved' items should go into the save file.
func getCoreItem( itemKey : String , numOfItem = 6 , isShallow = false ):
	var itemQuery = """
		SELECT * FROM Items
		WHERE itemKey = '%s'
		"""
	
	itemQuery = itemQuery % [ itemKey ];
	var success = coreDB.query( itemQuery );
	
	var newItem = null;
	if( success ):
		if( coreDB.query_result.size() >= 1 ):
			newItem = _generateItemFromQueryResult( coreDB.query_result[0] , isShallow )
			newItem.itemOwned = numOfItem
		else:
			print("Could not find item : " + itemKey )

	return newItem

func getManyCoreItems( keyArray : Array , isShallow = false ):
	pass

func _generateItemFromQueryResult( queryResult : Dictionary , isShallow = false ):
	var itemType = queryResult.itemType;

	var newItem = null;
	if( itemType == "Weapon" ):
		newItem


func getCoreAbility( abilityKey : String ):
	var abilityQuery = """
		SELECT * FROM Items
		WHERE abilityKey = '%s'
		"""
	
	abilityQuery = abilityQuery % [ abilityKey ];
	var success = coreDB.query( abilityQuery );
	
	var newAbility = null;
	if( success ):
		if( coreDB.query_result.size() >= 1 ):
			newAbility = Ability.new( coreDB.query_result[0] )
		else:
			print("Could not find item : " + abilityKey )

	return newAbility

func getCoreEffect( effectKey : String ):
	var effectQuery = """
		SELECT * FROM Effects
		WHERE effectKey = '%s'
	"""

	effectQuery = effectQuery % [ effectKey ]
	var success = coreDB.query( effectQuery );

	var newAbility = null;
	if( success ):
		if( coreDB.query_result.size >= 1 ):
			newEffect = Effect.new( coreDB.query_result[0] )
		else:
			print("Could not find effect : " + effectKey )

func saveItem( item : Item ):
	pass


# These get methods will first check if a core db record of that key exists. If not, it will pull from savegame item tables.
func getItem( itemName : String ):
	var coreItem = getCoreItem( itemName );
	
	if( coreItem ):
		return coreItem
	else:
		return itemName

func getAbility( abilityName : String ):
	var coreAbility = getCoreAbility( abilityName );

	if( coreAbility ):
		return coreAbility
	else:
		return abilityName

func getEffect( effectName : String ):
	var coreEffect = getCoreEffect( effectName );

	if( coreEffect ):
		return coreEffect
	else:
		return effectName

func generateDebugEquipment():
	var equipment = {}

	#equipment["TerranShieldGenerator"] = new( "TerranShieldGenerator", 6 )
	#equipment["TerranMedKit"] = generateEquipmentObject( "TerranMedKit", 6 )
	#equipment["TerranFragGrenade"] = generateEquipmentObject( "TerranFragGrenade", 6 )
	#equipment["TerranEmpGrenade"] = generateEquipmentObject( "TerranEmpGrenade", 6 )

	return equipment
