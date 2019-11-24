extends Node

var randomPlanetTable = {
	"LessTboilLine" :        { "L" : 20, "M" : 10, "G": 20 ,"IG" : 0,  "T" : 0 ,  "B" : 30, "I" : 0,  "S" : 20, "H": 0},
	"EqualboilLine" :        { "L" : 10, "M" : 10, "G": 20 ,"IG" : 0,  "T" : 10 , "B" : 30, "I" : 0,  "S" : 20, "H": 0},
	"BetweenBoilAndFreeze" : { "L" : 5,  "M" : 10, "G": 20 ,"IG" : 0,  "T" : 20 , "B" : 30, "I" : 0,  "S" : 15, "H": 10},
	"EqualfreezeLine" :      { "L" : 5,  "M" : 10, "G": 10 ,"IG" : 10, "T" : 10 , "B" : 30, "I" : 5,  "S" : 10, "H": 10},
	"GreaterfreezeLine":     { "L" : 5,  "M" : 10, "G": 10 ,"IG" : 20, "T" : 0 , "B" : 15, "I" : 15,  "S" : 5,  "H": 20}
}

var planetDictionary = { 
	1 : NO_PLANET_DICT, 2 : NO_PLANET_DICT,3 : NO_PLANET_DICT ,
	4 : NO_PLANET_DICT, 5 : NO_PLANET_DICT,6 : NO_PLANET_DICT ,
	7 : NO_PLANET_DICT ,8 : NO_PLANET_DICT,9 : NO_PLANET_DICT
}

func _ready():
	pass

func generatePlanet( orbit, starData , decorators ):
	var allowedPlanets = {}

	if( orbit < starData['boilLine'] ):
		allowedPlanets = randomPlanetTable["LessTboilLine"]
	if( orbit == starData['boilLine'] ):
		allowedPlanets = randomPlanetTable["EqualboilLine"]
	if( orbit > starData['boilLine'] && orbit < starData['freezeLine'] ):
		allowedPlanets = randomPlanetTable["BetweenBoilAndFreeze"]
	if( orbit == starData['freezeLine'] ):
		allowedPlanets = randomPlanetTable["EqualfreezeLine"]
	if( orbit > starData['freezeLine'] ):
		allowedPlanets = randomPlanetTable["GreaterfreezeLine"]

	var random = randi()%100 + 1
	var weightCount = 0
	var myPlanetClass = null

	for planet in allowedPlanets:
		
		weightCount += allowedPlanets[planet]
		if( weightCount >= random ):
			myPlanetClass = planet
			break

	var myPlanet = Planet.new()
	myPlanet.initPlanet( orbit, starData, myPlanetClass , decorators.fullName )

	return myPlanet