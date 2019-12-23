extends ItemFactory

func _ready():
	itemFolder = "res://JsonData/Equipment/"
	_loadData()

func generateEquipmentObject( key: String , numberToGenerate: int = 0 ):
	if( !dataDictionary.has( key ) ):
		print("Equipment key of " + key + " is missing")
		return null
	
	var itemDict = dataDictionary[key]
	var newEquipment = Equipment.new( key )

	for key in itemDict:
		newEquipment[key] = itemDict[key]

	newEquipment.itemOwned = numberToGenerate
	newEquipment.itemIsCrewEquipable = true

	return newEquipment

func generateDebugEquipment():
	var equipment = {}

	equipment["TerranShieldGenerator"] = generateEquipmentObject( "TerranShieldGenerator", 6 )
	equipment["TerranMedKit"] = generateEquipmentObject( "TerranMedKit", 6 )
	equipment["TerranFragGrenade"] = generateEquipmentObject( "TerranFragGrenade", 6 )
	equipment["TerranEmpGrenade"] = generateEquipmentObject( "TerranEmpGrenade", 6 )

	equipment = _cleanDictionary(equipment)

	return equipment