extends Control

onready var menu = get_node("Menu")
onready var root = get_node("/root/Root")


func _ready():
	pass # Replace with function body.

func _onMenuButtonToggled( toggle ):
	if( toggle ):
		menu.hide()
	else:
		menu.show()

func _onStartBattlePressed():
	root.loadScreen( "BATTLE" )

func _onExploreSystemPressed():
	root.loadScreen( "EXPLORE" )
