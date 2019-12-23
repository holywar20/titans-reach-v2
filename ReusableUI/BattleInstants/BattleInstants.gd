extends PanelContainer

onready var instantRowScene = load("res://ReusableUI/BattleInstants/InstantRow.tscn")
onready var instantBase = get_node("VBox/InstantBase")

func setupScene( eventBus : EventBus , crewman : Crew ):
	self.eventBus = eventBus

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func loadData( crewman = null ):
	self._clear()
	
	if( crewman ):
		self.crewman = crewman

	if( self.crewman ):
		var allInstants = self.crewman.getAllInstants()

		for instant in allInstants:
			var instantRow = instantRowScene.instance()
			#instantRow.setupScene( self.eventBus, instant )

func _clear():
	for child in self.instantBase.get_children():
		child.queue_free()
