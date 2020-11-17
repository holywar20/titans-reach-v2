extends Node

class_name StarSystem

var systemSeed = null
var star : Star
var planets = []
var anoms = []
var connections = []
var position : Vector2

func _init( _star, _planets, _anoms , _connections , _position ):
	star = _star
	planets = _planets
	anoms = _anoms
	connections = _connections
	position = _position

	systemSeed = star.starSeed
