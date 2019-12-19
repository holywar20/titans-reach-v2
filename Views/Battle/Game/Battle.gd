extends Node2D

onready var playerField = [
	[ get_node("BG/0_0"), get_node("BG/0_1"), get_node("BG/0_2") ] ,
	[ get_node("BG/1_0"), get_node("BG/1_1"), get_node("BG/1_2") ], 
	[ get_node("BG/2_0"), get_node("BG/2_1"), get_node("BG/2_2") ], 
]

onready var enemyField = [
	[ get_node("EBG/0_0"), get_node("EBG/0_1"), get_node("EBG/0_2") ] ,
	[ get_node("EBG/1_0"), get_node("EBG/1_1"), get_node("EBG/1_2") ], 
	[ get_node("EBG/2_0"), get_node("EBG/2_1"), get_node("EBG/2_2") ], 
]

var eventBus
var playerCrew = []
var enemyCrew = []
var battleConfig # No need not to keep as a ref, though we should load config as other variables

# Battle configuration variables

func setupScene( eventBus : EventBus , playerCrew , battleConfigDictionary ):
	self.eventBus = eventBus
	self.playerCrew = playerCrew
	self.battleConfig = battleConfig 

func _ready():
	pass
	# self.bases.instantBase.setupScene( self.eventBus , self.playerCrew )
	# Build instants for enemy ( will need AI code for this . )
	self._setupBattleOrder()
	self._nextPass()

func _setupBattleOrder():
	
	# TODO - Create a pop up to allow this to be changed and saved before battle. For now , hardcode!
	self.playerField[1][0].loadData( self.playerCrew[0] )
	self.playerField[1][1].loadData( self.playerCrew[1] )
	self.playerField[1][2].loadData( self.playerCrew[2] )
	self.playerField[2][1].loadData( self.playerCrew[3] )
	self.playerField[0][1].loadData( self.playerCrew[4])

func _nextPass():
	# Do any special end of pass checks ( Special conditions, etc )
	self._rollInitiative()
	self._nextTurn()

func _rollInitiative():
	var allActors = []
	
	for crew in self.enemyCrew:
		if( crew.getFightableStatus() ):
			allActors.append( crew )
	
	for crew in self.playerCrew:
		if( crew.getFightableStatus() ):
			allActors.append( crew )
	
	var packedArray = []
	for actor in allActors:
		packedArray.append({ 
				"Init": actor.rollInit() , 
				"Actor" : actor
			})
	
	packedArray = Common.bubbleSortArrayByDictKey( packedArray , "Init" )

	self.eventBus.emit("InitiativeRolled" , [ packedArray ] )

func _nextTurn():
	if( self._validateAlive( playerCrew ) ):
		self._loadEndGame()
		return null

	if( self._validateAlive( enemyCrew) ):
		self._loadEndBattle()
		return null

	
func _validateAlive( someCrew ):
	var deadCount = 0
	for crewman in someCrew:
		if( crewman.isDead() == true ):
			deadCount = deadCount + 1
	
	return deadCount >= someCrew.size()

func _pickAction():
	pass

func _loadEndGame():
	# Fire local event
	pass

func _loadEndBattle():
	# Fire local event
	# fire global event
	pass