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

func setupScene( eBus : EventBus, newCrewman : Crew ):
	eventBus = eBus
	crewman = newCrewman

func _ready():
	if( crewman ):
		loadData( crewman )
	if( eventBus ):
		loadEvents( eventBus )

func loadEvents( eBus : EventBus ):
	eventBus = eBus

func loadData( crewman : Crew ):
	crewman = crewman

	var hpBlock = crewman.getHPStatBlock()
	nodes.hpBar.max_value =  hpBlock.total
	nodes.hpBar.value =  hpBlock.current
	nodes.hpVal.set_text( crewman.getHitPointString() )

	var moBlock = crewman.getMoraleStatBlock()
	nodes.morBar.max_value = moBlock.total
	nodes.morBar.value = moBlock.current
	nodes.morVal.set_text( crewman.getMoraleString() )
	
	var weightBlock = crewman.getWeightStatBlock()
	
	nodes.weightBar.max_value = weightBlock.total
	nodes.weightBar.value = weightBlock.current
	nodes.weightVal.set_text( crewman.getWeightString() )

func setWeightVisible( isVisible : bool ):
	nodes.weightRow.set_visible( isVisible )
