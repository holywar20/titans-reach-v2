extends Node

func _ready():
	pass

var starSystemFirstNames = [
	"Abbadon" , "Alpophis", "Margeddon" , "Callistamere" , "Gypsy" , "Orlus" , "Cylus" , "Verune" , "Callus" , "Infidel" , "Wayward" , "Titans"
]

var starSystemLastNames = [
	"Theta" , "Omega", "Epsilon" , "Alpha", "Bravo" , "Tango" , "Danger", "Prime" , "Primus" , "Mundi" , "Crash" , "Reach"
]

var randomStarTable = {
	"M" : 20 , "K" : 15 , "G" : 15 , "F" : 15 , 
	"A" : 10,  "B" : 10 , "O" : 2,
	"N" : 2 ,  "R" : 10 , "H" : 1 
}

# TODO - load all this shit from a json file.
var starPrototypes = {
	"M" : { "classification" : "M" , "className" : "Red Dwarf", 
		"massLo" : .08   , "massHi" : .45  ,   "radius" :  .4 , 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"boilLine": 0    , "freezeLine": 2 , "orbitSize" : .8 , "habitableChance" : 20  ,  
		"tempHi" : 3700 , "tempLo": 2400 },
		
	"K" : { "classification" : "K", "className" : "Orange Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .45   , "massHi" : .8   ,   "radius" :  .6 , 
		"boilLine": 1    , "freezeLine": 3 , "orbitSize" : .9 , "habitableChance" : 60, 
		"tempHi" : 3700 , "tempLo": 5200 },
		
	"G" : { "classification" : "G", "className" : "Yellow Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .8    , "massHi" : 1.04 ,   "radius" :  .7 , 
		"boilLine": 2    , "freezeLine": 4 , "orbitSize" : 1 , "habitableChance" : 50 ,
		"tempHi" : 5200 , "tempLo": 6000 },
		
	"F" : { "classification" : "G", "className" : "Yellow-White Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 1.04  , "massHi" : 1.4  ,   "radius" :  .8 , 
		"boilLine": 3    , "freezeLine": 5 , "orbitSize" : 1.1 , "habitableChance" : 40,
		"tempHi" : 7500 , "tempLo": 6000  },
		
	"A" : { "classification" : "A", "className" : "A-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",
		"massLo" : 1.4   , "massHi" : 2.1  ,   "radius" :  1, 
		"boilLine": 4    , "freezeLine": 6 , "orbitSize" : 1.2 , "habitableChance" : 30 ,
		"tempHi" : 10000 , "tempLo": 7500 },
		
	"B" : { "classification" : "B", "className" : "B-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",
		"massLo" : 2.1   , "massHi" : 16  ,   "radius" :  1.5, 
		"boilLine": 5    , "freezeLine": 7 , "orbitSize" : 1.3, "habitableChance" : 20 ,
		"tempHi" : 10000 , "tempLo": 30000 },
		
	"O" : { "classification" : "O", "className":	"O-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 16    , "massHi" :  40  ,   "radius" : 1.6  , 
		"boilLine": 6    , "freezeLine": 8 , "orbitSize" : 1.4 , "habitableChance" : 10 ,
		"tempHi" : 50000 , "tempLo": 30000 },
		
	"N" : { "classification" : "N","className" : "Neutron Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",  
		"massLo" : 1.4, "massHi": 3.0	   , "radius" : .2  , 
		"boilLine": 1    , "freezeLine": 2 , "orbitSize" : 1  , "habitableChance" : 0,
		"tempHi" : 100000 , "tempLo": 10000 },
		
	"R" : { "classification" : "R","className" : "Red Giant", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .8 , "massHi": 5.0 , "radius" :  1.6 , 
		"boilLine": 4    , "freezeLine": 7 , "orbitSize" : 1.8, "habitableChance" : 20 ,
		"tempHi" : 5200 , "tempLo": 24000 },
		
	"H" : { "classification" : "H", "className" : "Hyper Giant", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 40 , "massHi": 120 , "radius" :  1.3 , 
		"boilLine": 8    , "freezeLine": 9 , "orbitSize" : 2.4, "habitableChance" : 10  ,
		"tempHi" : 100000 , "tempLo": 30000 },
}

enum TEXTURE{ FULL, SMALL , ICON }

func generateRandomStar( textureSize : int , thisSeed = 100000 ):
	seed( thisSeed )
	randi()

	var pro = self._getRandomPrototypeStar( thisSeed )

	var myStar = Star.new()
	myStar['starSeed']			= thisSeed
	myStar['classification'] 	= pro['classification']
	myStar['className']  		= pro['className']
	myStar['radius'] 				= pro['radius']
	myStar['boilLine'] 			= pro['boilLine']
	myStar['freezeLine']			= pro['freezeLine']
	myStar['orbitSize'] 			= pro['orbitSize']

	# TODO - Randomize somehow different star classes. 
	myStar['fullTexturePath']	= pro['textureFragment']# TODO - define these a bit better.
	myStar['smallTexturePath'] = pro['textureFragment']
	myStar['iconTexturePath']	= pro['textureFragment'] 

	if( textureSize ==  self.TEXTURE.FULL ):
		myStar.set_texture( load( myStar.fullTexturePath ) )
	elif ( textureSize == self.TEXTURE.SMALL ):
		myStar.set_texture( load( myStar.smallTexturePath ) )
	elif( textureSize == self.TEXTURE.ICON ):
		myStar.set_texture( load( myStar.TEXTURE.ICON ) )

	var idx = randi() % self.starSystemFirstNames.size()
	myStar['firstName'] = self.starSystemFirstNames[idx]

	idx = randi() % self.starSystemFirstNames.size()
	myStar['lastName'] = self.starSystemLastNames[idx]

	myStar['mass'] = Common.randDiffPercents( pro['massHi'], pro['massLo'] )
	myStar['mass'] = Common.randDiffPercents( pro['tempHi'], pro['tempLo'] )
	
	return myStar

func _getRandomPrototypeStar( thisSeed : int ):
	seed( thisSeed )
	randi()

	var random = randi()%100+1
	var myStarClass = "M"
	var weightCount = 0
	
	for star in self.randomStarTable:
		
		weightCount += self.randomStarTable[star]
		if( weightCount >= random ):
			myStarClass = star
			break
	
	return self.starPrototypes[myStarClass]