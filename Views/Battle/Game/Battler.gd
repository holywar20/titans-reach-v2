extends Sprite

onready var barNodes = {
	"HealthBar" : get_node("Health/Bar"),
	"MoraleBar" : get_node("Morale/Bar"),
	"HealthValue" : get_node( "Health/Bar/Value"),
	"MoraleValue" : get_node( "Morale/Bar/Value")
}

var eventBus = null
var crewman = null

func setupScene( eventBus : EventBus , crewman : Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

	self.loadEvents()

	if( self.is_inside_tree() ):
		self.loadData()

func _ready():
	pass

func loadEvents():
	pass

func loadData( crewman = null ):
	if( crewman ):
		self.crewman = crewman

	if( self.crewman ):
		var hp = self.crewman.getHPStatBlock()
		self.barNodes.HealthBar.set_max( hp.total )
		self.barNodes.HealthBar.set_value( hp.current )
		self.barNodes.HealthValue.set_text( self.crewman.getHitPointString() )
		
		var morale = self.crewman.getMoraleStatBlock()
		self.barNodes.MoraleBar.set_max( morale.total )
		self.barNodes.MoraleBar.set_value( morale.current )
		self.barNodes.MoraleValue.set_text( self.crewman.getMoraleString() )

		self.show()
	else:
		self.hide()