extends PanelContainer

onready var instantRowScene = load("res://ReusableUI/BattleInstants/InstantRow.tscn")
onready var instantBase = get_node("VBox/InstantBase")

var eventBus
var crewman

func setupScene( eBus : EventBus , newCrewman : Crew ):
	eventBus = eBus
	crewman = newCrewman

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func loadData( newCrewman = null ):
	_clear()
	
	if( newCrewman ):
		crewman = newCrewman

	if( crewman ):
		var allInstants = crewman.getAllInstants()

		for instant in allInstants:
			var instantRow = instantRowScene.instance()
			#instantRow.setupScene( eventBus, instant )

func _clear():
	for child in instantBase.get_children():
		child.queue_free()
