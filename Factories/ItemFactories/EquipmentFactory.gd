extends ItemFactory

func _ready():
	self.itemFolder = "res://JsonData/Equipment/"
	self._loadData()

func generateEquipmentObject( key: String , numberToGenerate: int = 0 ):
	if( !self.dataDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = self.dataDictionary[key]
	var newEquipment = Equipment.new( key )

	for key in itemDict:
		newEquipment[key] = itemDict[key]

	newEquipment.itemOwned = numberToGenerate
	newEquipment.itemIsCrewEquipable = true

	return newEquipment

func generateDebugEquipment():
	var equipment = {}

	equipment["TerranShieldGenerator"] = self.generateEquipmentObject( "TerranShieldGenerator", 6 )
	equipment["TerranMedKit"] = self.generateEquipmentObject( "TerranMedKit", 6 )
	equipment["TerranFragGrenade"] = self.generateEquipmentObject( "TerranFragGrenade", 6 )
	equipment["TerranEmpGrenade"] = self.generateEquipmentObject( "TerranEmpGrenade", 6 )

	equipment = self._cleanDictionary(equipment)

	return equipment