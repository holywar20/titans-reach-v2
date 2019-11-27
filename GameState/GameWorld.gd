extends Node

# Quick ref for regenerating the seed. 
var systemSeed = 10000

var playerShip = null
var playerCrew = null

func _ready():
	pass

func getSystemSeed():
	return self.systemSeed

func getPlayerShip():
	return playerShip