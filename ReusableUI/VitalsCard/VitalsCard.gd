extends VBoxContainer

var crewman = null
var eventBus = null

onready var  nodes = {
	'hpBar' : get_node('HealthRow/Bar'),
	'hpVal' : get_node('HealthRow/Bar/Value'),
	'morBar' : get_node('MoraleRow/Bar'),
	'morVal' : get_node('MoraleRow/Bar/Value'),
	'weightBar' : get_node('WeightRow/Bar'),
	'weightVal' : get_node('WeightRow/Bar/Value'),

	'weightRow' : get_node('WeightRow')
}

func setupScene( eventBus : EventBus, crewman : Crew ):
	self.eventBus = eventBus
	self.crewman = crewman

func _ready():
	if( self.crewman ):
		self.loadData( crewman )
	if( self.eventBus ):
		self.setEvents

func loadEvents( eventBus : EventBus ):
	self.eventBus = eventBus

func loadData( crewman : Crew ):
	self.crewman = crewman

	var hpBlock = crewman.getHPStatBlock()
	self.nodes.hpBar.max_value =  hpBlock.total
	self.nodes.hpBar.value =  hpBlock.current
	self.nodes.hpVal.set_text( crewman.getHitPointString() )

	var moBlock = crewman.getMoraleStatBlock()
	self.nodes.morBar.max_value = moBlock.total
	self.nodes.morBar.value = moBlock.current
	self.nodes.morVal.set_text( crewman.getMoraleString() )
	
	var weightBlock = crewman.getWeightStatBlock()
	
	self.nodes.weightBar.max_value = weightBlock.total
	self.nodes.weightBar.value = weightBlock.current
	self.nodes.weightVal.set_text( crewman.getWeightString() )

func setWeightVisible( isVisible : bool ):
	self.nodes.weightRow.set_visible( isVisible )
