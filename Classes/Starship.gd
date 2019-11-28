extends Node

class_name Starship

class Console:
	var name = "Captain"
	var type = "Command"
	var description = "The Comm"
	var priTrait = "CHA"
	var secTrait = "STR"

# Starship metadata
var suffix = "Destiny"
var prefix = "USS"

var consoles = []

func init():
	self.consoles.append( Console.new() )
	self.consoles.append( Console.new() )
	self.consoles.append( Console.new() )
	self.consoles.append( Console.new() )