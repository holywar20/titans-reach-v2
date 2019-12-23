extends Node

var planetScene = load("res://ReusableGameObjects/Planet/Planet.tscn")

# Percents should add up to 100, or else behavior may get weird.
var randomPlanetTable = {
	"LessTboilLine" :        { "L" : 20, "M" : 10, "G": 20 ,"IG" : 0,  "T" : 0 ,  "B" : 30, "I" : 0,  "S" : 20, "H": 0},
	"EqualboilLine" :        { "L" : 10, "M" : 10, "G": 20 ,"IG" : 0,  "T" : 10 , "B" : 30, "I" : 0,  "S" : 20, "H": 0},
	"BetweenBoilAndFreeze" : { "L" : 5,  "M" : 10, "G": 20 ,"IG" : 0,  "T" : 20 , "B" : 30, "I" : 0,  "S" : 15, "H": 10},
	"EqualfreezeLine" :      { "L" : 5,  "M" : 10, "G": 10 ,"IG" : 10, "T" : 10 , "B" : 30, "I" : 5,  "S" : 10, "H": 10},
	"GreaterfreezeLine":     { "L" : 5,  "M" : 10, "G": 10 ,"IG" : 20, "T" : 0 , "B" : 15, "I" : 15,  "S" : 5,  "H": 20}
}

# TODO - map these commodities to the item system, or maybe make Item constants that refer to specific item keys
var planetMinerals = [
	"Meneshium" , "Lead" , "Gold" , "Tin" , "Mercury" , "Cobolt" , "Nickel" , "Iron" 
]

var planetClassData = {
	"L" : {
		"classification" : "L" , "className" : "Lava",
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 25,
		"atmosphere" : "Sulfur Dioxide",
		"color" : Color.crimson
	} , "M" : {
		"classification" : "M" , "className" : "Mesoplanet" ,
		"massHi" : .6  , "massLo" : .05 ,
		"radiusHi" : .4  , "radiusLo" : .7,
		"biosphereChance" : 0,
		"atmosphere": "None",
		"color" : Color.brown 
	} , "G" : {
		"classification" : "G" , "className" : "Gas Giant",
		"massHi" : 80  , "massLo" : 22 ,
		"radiusHi" : 2 	, "radiusLo": 1.8,
		"biosphereChance" : 0,
		"atmosphere": "Hydrogen, Helium",
		"color" : Color.darkorange 
	} ,"IG" : {
		"classification" : "IG" , "className" : "Ice Giants" ,
		"massHi" : 21  , "massLo" : 3 ,
		"radiusHi" : 1.3  , "radiusLo" : 1.2,
		"biosphereChance" : 0 ,
		"atmosphere" : "Hydrogen, Helium, Water",
		"color" : Color.darkcyan
	}, "T" : {
		"classification" : "T" , "className" : "Terran",
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 50,
		"atmosphere" : "Nitrogen, Oxygen",
		"color" : Color.darkolivegreen
	}, "B" : {
		"classification" : "L" , "className" : "Barren",
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 0,
		"atmosphere" : "Carbon Dioxide",
		"color" : Color.brown
	}, "I" : {
		"classification" : "L" , "className" : "Ice" ,
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 25,
		"atmosphere" : "Nitrogen, Oxygen",
		"color" : Color.cadetblue 
	}, "S" : {
		"classification" : "L" , "className" : "Storm",
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 0,
		"atmosphere" : "Hydrogen Cynanide",
		"color" : Color.darkviolet 
	} , "H" : {
		"classification" : "H" , 'className' : "Hydrocarbon",
		"massHi" : 1.4  , "massLo" : .6 ,
		"radiusHi" : 1.3  , "radiusLo" : .7,
		"biosphereChance" : 0,
		"atmosphere" : "Methane, Nitrogen",
		"color" : Color.beige
	}
}

const DESCRIPTION = {
	"L" : """Lava
	""" , 
	"M" : """Mesoplanet
	""" , 
	"G" : """Gas Giant
	""" , 
	"IG" : """Ice Giant
		""" , 
	"T" : """Terran
		""" , 
	"B" : """Barren
		""" , 
	"I" : """Ice
		""" , 
	"S" : """Storm
		""" , 
	"H" : """Hydrocarbon
	""" , 
}

func _ready():
	pass

func generateAllPlanetsFromStar( myStar ):
	seed( myStar.starSeed )
	randi()
	
	var planetArray = []

	for orbit in range( 0 , myStar.ORBIT_COUNT ):
		if( randi() % 100 < myStar.chanceOfPlanetPerOrbit ):
			planetArray.append( generateOnePlanet( orbit, myStar ) )
			myStar.setOrbitState( orbit, true )
		else:
			planetArray.append( null )
			myStar.setOrbitState( orbit, false )
			continue # No planet at this orbit. Moving on. 

	return planetArray

func generateOnePlanet( orbit,  myStar ):
	var planetClass = _rollPlanetType( orbit, myStar)
	var myPlanet = _rollPlanetDetails( orbit, planetClass , myStar )
	return myPlanet


func _rollPlanetDetails( orbit, planetClass , star ):
	var p = planetClassData[planetClass]

	var planet = planetScene.instance()
	
	planet.fullName = star.getName() + " " + str(orbit + 1) # TODO - Make roman Numerals. Also should add ability for 'uniquely' named planets.
	planet.planetSeed = null
	planet.orbit = orbit
	planet.classification = p.classification
	planet.className = p.className
	planet.color = p.color
	
	planet.description = DESCRIPTION[p.classification]

	planet.atmopshere = p.atmosphere
	
	var randomRadian = randf() * 3.14 * 2
	
	planet.radial = Vector2( cos(randomRadian) , sin(randomRadian) )
	planet.radius = Common.randDiffPercents( p['radiusHi'], p['radiusLo'] )
	planet.mass = Common.randDiffPercents( p['massHi'] , p['massLo'] )
	planet.temp = 200 # TODO - base this on some formula

	planet.fullTexturePath = "res://TextureBank/Stars/celestial_blank.png"
	planet.iconTexturePath = "res://TextureBank/Stars/celestial_blank_icon.png"

	return planet

func _rollPlanetType( orbit ,star ):
	var allowedPlanets = {}

	if( orbit < star.boilLine ):
		allowedPlanets = randomPlanetTable["LessTboilLine"]
	elif( orbit == star.boilLine ):
		allowedPlanets = randomPlanetTable["EqualboilLine"]
	elif( orbit > star.boilLine && orbit < star.freezeLine ):
		allowedPlanets = randomPlanetTable["BetweenBoilAndFreeze"]
	elif( orbit == star.freezeLine ):
		allowedPlanets = randomPlanetTable["EqualfreezeLine"]
	if( orbit > star.freezeLine ):
		allowedPlanets = randomPlanetTable["GreaterfreezeLine"]

	var random = randi()%100 + 1
	var weightCount = 0
	var myPlanetClass = null

	for planet in allowedPlanets:
		
		weightCount += allowedPlanets[planet]
		if( weightCount >= random ):
			myPlanetClass = planet
			break

	return myPlanetClass
