extends ItemFactory

func _ready():
	self.itemFolder = "res://JsonData/Weapons/"
	self._loadData()

func generateWeaponObject( key: String, numberToGenerate : int = 0):
	if( !self.dataDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = self.dataDictionary[key]
	var newWeapon = Weapon.new( key )

	for key in itemDict:
		newWeapon[key] = itemDict[key]

	newWeapon.itemOwned = numberToGenerate
	newWeapon.itemIsCrewEquipable = true

	return newWeapon

func generateDebugWeapons():
	var weapons = {}

	weapons["TerranAssaultRifle"] = self.generateWeaponObject( "TerranAssaultRifle" , 3 )
	weapons["TerranMinigun"] = self.generateWeaponObject( "TerranMinigun" , 1 )
	weapons["TerranShotGun"] = self.generateWeaponObject("TerranShotgun" , 3)
	weapons["TerranHammer"] = self.generateWeaponObject( "TerranHammer" , 1 )
	weapons["TerranPistol"] = self.generateWeaponObject("TerranPistol" , 10)
	weapons["TerranSword"] = self.generateWeaponObject( "TerranSword"  , 3 )
	
	weapons = self._cleanDictionary( weapons )

	return weapons