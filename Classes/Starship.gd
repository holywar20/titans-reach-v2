extends Node

class_name Starship

# Starship metadata
var suffix = "Destiny"
var prefix = "USS"

var consoles = []

var command = [
	{
		"Name" : "Captain" ,
		"Description" : "El Capitan",
		"Category" : Console.CATEGORY.COMMAND,
		"PriTrait" : "CHA",
		"SecTrait" : "STR",
		"Effects" : {
			"moraleTotal" : 1 
		}
	} , {
		"Name" : "Navigator" ,
		"Description" : "Navigator",
		"Category" : Console.CATEGORY.COMMAND,
		"PriTrait" : "PER",
		"SecTrait" : "DEX",
		"Effects" : {
			"shipSpeed" : 2 
		}
	}
]

# Hoist all this into another class, potentially a factory or just a plain data file.
func _init():
	for c in command:
		consoles.append( Console.new( c.Name, c.Description, c.Category, c.PriTrait, c.SecTrait, c.Effects ) )

func get_class(): 
	return "Starship"

func is_class( name : String ): 
	return name == "Starship"

func getConsoles():
	return consoles