extends Node

func _ready():
	pass

onready var starScene = load("res://ReusableGameObjects/Star/Star.tscn")

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
		"tempHi" : 3700 , "tempLo": 2400 ,
		"color" : Color.tomato
	},
	"K" : { "classification" : "K", "className" : "Orange Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .45   , "massHi" : .8   ,   "radius" :  .6 , 
		"boilLine": 1    , "freezeLine": 3 , "orbitSize" : .9 , "habitableChance" : 60, 
		"tempHi" : 3700 , "tempLo": 5200 ,
		"color" : Color.burlywood
	},
	"G" : { "classification" : "G", "className" : "Yellow Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .8    , "massHi" : 1.04 ,   "radius" :  .7 , 
		"boilLine": 2    , "freezeLine": 4 , "orbitSize" : 1 , "habitableChance" : 50 ,
		"tempHi" : 5200 , "tempLo": 6000 ,
		"color" : Color.cornflower 
	},	
	"F" : { "classification" : "G", "className" : "Yellow-White Dwarf", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 1.04  , "massHi" : 1.4  ,   "radius" :  .8 , 
		"boilLine": 3    , "freezeLine": 5 , "orbitSize" : 1.1 , "habitableChance" : 40,
		"tempHi" : 7500 , "tempLo": 6000  ,
		"color" : Color.whitesmoke
	},
	"A" : { "classification" : "A", "className" : "A-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",
		"massLo" : 1.4   , "massHi" : 2.1  ,   "radius" :  1, 
		"boilLine": 4    , "freezeLine": 6 , "orbitSize" : 1.2 , "habitableChance" : 30 ,
		"tempHi" : 10000 , "tempLo": 7500, 
		"color" : Color.lightskyblue 
	},
		
	"B" : { "classification" : "B", "className" : "B-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",
		"massLo" : 2.1   , "massHi" : 16  ,   "radius" :  1.5, 
		"boilLine": 5    , "freezeLine": 7 , "orbitSize" : 1.3, "habitableChance" : 20 ,
		"tempHi" : 10000 , "tempLo": 30000, 
		"color" : Color.cyan
	},
		
	"O" : { "classification" : "O", "className":	"O-Type Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 16    , "massHi" :  40  ,   "radius" : 1.6  , 
		"boilLine": 6    , "freezeLine": 8 , "orbitSize" : 1.4 , "habitableChance" : 10 ,
		"tempHi" : 50000 , "tempLo": 30000 ,
		"color" : Color.lightsteelblue
	},
		
	"N" : { "classification" : "N","className" : "Neutron Star", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png",  
		"massLo" : 1.4, "massHi": 3.0	   , "radius" : .2  , 
		"boilLine": 1    , "freezeLine": 2 , "orbitSize" : 1  , "habitableChance" : 0,
		"tempHi" : 100000 , "tempLo": 10000 ,
		"color" : Color.ivory
	},
		
	"R" : { "classification" : "R","className" : "Red Giant", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : .8 , "massHi": 5.0 , "radius" :  1.6 , 
		"boilLine": 4    , "freezeLine": 7 , "orbitSize" : 1.8, "habitableChance" : 20 ,
		"tempHi" : 5200 , "tempLo": 24000 ,
		"color" : Color.darkred
	},
		
	"H" : { "classification" : "H", "className" : "Hyper Giant", 
		"textureFragment" : "res://TextureBank/Stars/celestial_blank.png", 
		"massLo" : 40 , "massHi": 120 , "radius" :  1.3 , 
		"boilLine": 8    , "freezeLine": 9 , "orbitSize" : 2.4, "habitableChance" : 10  ,
		"tempHi" : 100000 , "tempLo": 30000,
		"color" : Color.ivory
	},
}

const starDescriptions = {
	"M" : "Also known as Red Dwarfs, M-Class stars are small stars that burn very slowly as a result of their relatively low pressure within their cores. This low rate of fusion also means the star could theoretically burn for Trillions of years. Habitable planets around Red Dwarfs are rare, as the stars are prone to wild swings in stellar output, dimming or flaring up as much as 40% in minutes. Also any planet that could have liquid water would need to be very close to the star and end up tidally locked.",
	"K" : "Also known as Orange Dwarfs, K Class stars are 5 times as common as G Class Stars, and most habitable planets in the galaxy orbit such a star. They have stable output over billions of years, and the stars are so long lived, that not a single K-Class star has expanded into a red giant. They have extremely stable but somewhat low tempatures over their life times and so the most useful will be those that orbit extremely close to their home star.",
	"G" : "Also known as Yellow-White Dwarfs, The G-Class star is prototyped by a very well known star, The Sun. G-Class stars have a relatively long life time but are relativey energetic over most of their lives. After between 8 and 12 Billion Years, a G-Class star will normally expand into a massive red giant, increasing their lumonisity thousand fold and swallowing most of their inner planets.",
	"F" : "F-Class stars are highly energetic stars that are stable for a relatively short billion to 2 billion years. Life is possible in a system like this but is very rare. Life from  F-Class star especially must be hardy, as the baleful light of the star can easily strip atmospheres. Life bearing worlds will tend to be extremely high mass with strong magnetic fields and active volcanism.",
	"A" : "",
	"B" : "",
	"O" : "",
	"N" : "Neutron Stars are the left over corpses of stars destroyed in a supernova",
	"R" : "A Red-Giant is what was once a very normal star, expanded and bloated by years of accumulating helium ash on their cores. Not large enough to burn these heavy materials, the outer layers expand while the core contracts. Red-Giant systems are incredibly dangerous, especially once you get close to the beast. The Star can take months to circumnaviate safely at sublight, and the bath of radiation makes most forms of radiative cooling completely ineffective.",
	"H" : "Hypergiants are 80 to 100 solar mass stars that burn with more energy in a second than a sun-like star does in a year. These massive nuclear furnaces churn through material so rapidly that they are fundementally unstable. Every year they slough off enormous amounts of their mass, while the core contracts ever denser, producing incredible amounts of heat and energy. Hypergiant systems are essentially almost uninhabitable. Even the best radiation shielding can only last against the onslaught of the star for a few hours, and regular outpourings of gas and material liken it more to a constant explosion than the gentle caress of a stellar wind. Worlds around Hypergiants are rare, almost always pure balls of Magma that have yet to cool since the stars formation. Hypergiants also often serve as Nexus Stars. It's high gravity can make it hard to open stable rip routes, but once open travel to and from Hypergiant systems is extremely fast."
}

func generateRandomStar( textureSize : int , thisSeed = 100000 ):
	seed( thisSeed )
	randi()

	var pro = _getRandomPrototypeStar( thisSeed )

	var myStar = starScene.instance()
	myStar['starSeed']			= thisSeed
	myStar['description']		= starDescriptions[pro['classification']]
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

	myStar['color'] = pro['color']

	var firstNameIdx = randi() % starSystemFirstNames.size()
	var lastNameIdx = randi() % starSystemFirstNames.size()
	myStar.setName( starSystemFirstNames[firstNameIdx] , starSystemLastNames[lastNameIdx] )

	myStar['mass'] = Common.randDiffPercents( pro['massLo'] , pro['massHi'] )
	myStar['mass'] = Common.randDiffPercents( pro['tempLo'] , pro['tempHi'] )

	return myStar

func _getRandomPrototypeStar( thisSeed : int ):
	seed( thisSeed )
	randi()

	var random = randi()%100+1
	var myStarClass = "M"
	var weightCount = 0
	
	for star in randomStarTable:
		
		weightCount += randomStarTable[star]
		if( weightCount >= random ):
			myStarClass = star
			break
	
	return starPrototypes[myStarClass]