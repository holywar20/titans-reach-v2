extends Node
const DEBUG = true
const ROUND_PRECISION = 1000 

const RAND_KEY_SIZE = 10
const RAND_KEY_POSSIBLE_VALUES = 35
const SEED_SIZE = 100000000

const DRAGGABLE_LAYER = "/root/Root/Draggable"

var randSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345689" 

func _ready():
	pass

func randDiffValues( low, hi ):
	hi 	= int( round( hi  * self.ROUND_PRECISION ) ) # To deal with fractions and modulo  Also this caps precision at 4 decimals
	low 	= int( round( low * self.ROUND_PRECISION ) )

	var diff = hi - low
	var random = null
	
	if( diff == 0 ):
		random = hi
	else:
		random = ( randi() % diff + low ) / self.ROUND_PRECISION
	
	return random

func randDiffPercents( high , low ):
	var random = randi()%100 + 1.0
	var diff = ( high - low ) * ( random / 100 )
	var newValue = diff + low
	
	return newValue
	
func drawArc( center, radius, angle_from, angle_to, color , drawNode , lineWidth):
	
	var nb_points = 128
	var points_arc = PoolVector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points - 90
		var point = center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius
		points_arc.push_back(point)
	
	for index_point in range(nb_points):
		drawNode.draw_line( points_arc[index_point], points_arc[index_point + 1], color , lineWidth )

func drawCircle( center, radius, color, drawNode, lineWidth , segments ):
	var points_arc = PoolVector2Array()
	
	for segment in range( segments+1):
		var angle_point = ( segment * 360 ) / segments - 90
		var point = center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius
		points_arc.push_back(point)
	
	for index_point in range(segments):
		drawNode.draw_line( points_arc[index_point], points_arc[index_point + 1], color , lineWidth )


func bubbleSortArrayByDictKey( arrayToSort, dictKey ):
	
	var swap = null
	var performedASwap = false
	var stayInLoop = true

	while( stayInLoop == true ):
		for i in range(0 , arrayToSort.size()-1 ):
			if( arrayToSort[i][dictKey] > arrayToSort[i+1][dictKey] ):
				swap = arrayToSort[i]
				arrayToSort[i] = arrayToSort[i+1]
				arrayToSort[i+1] = swap
				performedASwap = true
		
		if( performedASwap == true ):
			performedASwap = false
		else:
			stayInLoop = false
	return arrayToSort

func genRandomKey():
	var myKey = ""
	
	for keyItem in range(RAND_KEY_SIZE):
		var myKeyValue = randi()%RAND_KEY_POSSIBLE_VALUES
		
		myKey += randSet[myKeyValue]
	
	return myKey

func genRandomSeed():
	return randi() % self.SEED_SIZE + 1

func findNodeInGroup( groupName , nodeName ):
	
	var arrayOfNodes = get_tree().get_nodes_in_group( groupName )
	
	for node in arrayOfNodes:
		if( node.get_name() == nodeName ):
			return node
	
	return null

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)

	dir.list_dir_end()

	return files