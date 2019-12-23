extends ItemFactory

func _ready():
	itemFolder = "res://JsonData/Weapons/"
	_loadData()

func generateWeaponObject( key: String, numberToGenerate : int = 0):
	if( !dataDictionary.has( key ) ):
		print("Frame key of " + key + " is missing")
		return null
	
	var itemDict = dataDictionary[key]
	var newWeapon = Weapon.new( key )

	for key in itemDict:
		newWeapon[key] = itemDict[key]

	newWeapon.itemOwned = numberToGenerate
	newWeapon.itemIsCrewEquipable = true

	return newWeapon

func generateDebugWeapons():
	var weapons = {}

	weapons["TerranAssaultRifle"] = generateWeaponObject( "TerranAssaultRifle" , 3 )
	weapons["TerranMinigun"] = generateWeaponObject( "TerranMinigun" , 1 )
	weapons["TerranShotGun"] = generateWeaponObject("TerranShotgun" , 3)
	weapons["TerranHammer"] = generateWeaponObject( "TerranHammer" , 1 )
	weapons["TerranPistol"] = generateWeaponObject("TerranPistol" , 10)
	weapons["TerranSword"] = generateWeaponObject( "TerranSword"  , 3 )
	
	weapons = _cleanDictionary( weapons )

	return weapons