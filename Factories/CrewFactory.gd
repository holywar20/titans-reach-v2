extends Node

func _ready():
	pass


func generateManyCrew( cp , numOfCrew ):
	var crewArray = []

	for x in range(0 , numOfCrew ):
		crewArray.append( generateNewCrew( 30 ) )

	return crewArray

func generateNewCrew( cp = 30 ):
	var crewman = Crew.new()

	return crewman