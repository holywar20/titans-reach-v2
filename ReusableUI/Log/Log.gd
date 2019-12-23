extends Node

onready var logNode = get_node("Text")

func _ready():
	_clear()

func add( data ):
	# TODO - add crap like line numbers, and maybe a switch for a call stack, etc
	logNode.set_text( logNode.get_text() + "\n" + str(data) )

func _clear():
	logNode.set_text( "" );

func showType( displayItem ):
	var itemType = null
	
	match typeof(displayItem):
		TYPE_INT: 
			itemType = "Integer"
		TYPE_BOOL:
			itemType = "Bool"
		TYPE_REAL: 
			itemType = "Real"
		TYPE_STRING:
			itemType = "String"
		TYPE_VECTOR2:
			itemType = "Vector2"
		TYPE_RECT2: 
			itemType = "Rect2"
		TYPE_VECTOR3:
			itemType = "Vector3"
		TYPE_TRANSFORM2D: 
			itemType = "Transoform 2D"
		TYPE_PLANE:
			itemType = "Plane"
		TYPE_QUAT: 
			itemType = "Quat"
		TYPE_AABB:
			itemType = "AABB"
		TYPE_BASIS: 
			itemType = "Basis"
		TYPE_TRANSFORM:
			itemType = "Transform"
		TYPE_COLOR: 
			itemType = "Color"
		TYPE_NODE_PATH:
			itemType = "NodePath"
		TYPE_RID: 
			itemType = "RID"
		TYPE_OBJECT:
			itemType = "Object"
		TYPE_COLOR: 
			itemType = "Color"
		TYPE_DICTIONARY:
			itemType = "Dictonary"
		TYPE_ARRAY: 
			itemType = "Array"
		TYPE_RAW_ARRAY:
			itemType = "Raw Array"
		TYPE_INT_ARRAY:
			itemType = "Int Array"
		TYPE_REAL_ARRAY:
			itemType = "Real Array"
		TYPE_STRING_ARRAY:
			itemType = "String Array"
		TYPE_VECTOR2_ARRAY:
			itemType = "Vector2 Array"
		TYPE_VECTOR3_ARRAY:
			itemType = "Vector3 Array"
		TYPE_COLOR_ARRAY:
			itemType = "Color Array"
		_:
			itemType = "Unknown!"
			
	add( itemType )