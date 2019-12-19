extends Control

onready var menu = get_node("Menu")
onready var root = get_node("/root/Root")


func _ready():
	pass # Replace with function body.

func _onMenuButtonToggled( toggle ):
	if( toggle ):
		self.menu.hide()
	else:
		self.menu.show()

func _onStartBattlePressed():
	self.root.loadScreen( "BATTLE" )

func _onExploreSystemPressed():
	self.root.loadScreen( "EXPLORE" )