extends Control

class_name Battler

onready var barNodesStandard = {
	"Handle"		: get_node("Standard"),
	"HealthBar" : get_node("Standard/Health/Bar"),
	"MoraleBar" : get_node("Standard/Morale/Bar"),
	"HealthValue" : get_node( "Standard/Health/Bar/Value"),
	"MoraleValue" : get_node( "Standard/Morale/Bar/Value")
}

onready var barNodesReversed = {
	"Handle"		: get_node("Reversed"),
	"HealthBar" : get_node("Reversed/Health/Bar"),
	"MoraleBar" : get_node("Reversed/Morale/Bar"),
	"HealthValue" : get_node( "Reversed/Health/Bar/Value"),
	"MoraleValue" : get_node( "Reversed/Morale/Bar/Value")
}

onready var otherNodes = {
	"Texture"	: get_node("Texture"),
	"DamageText": get_node("DamageText"),
	"MissText"	: get_node("MissText"),
	"DeadText" 	: get_node("DeadText")
}

onready var stateAnimations = get_node("StateAnimations")
onready var alwaysAnimations = get_node("AlwaysAnimations")

var barNodes = null

const ANIMATIONS = {
	"STATE" : {
		"HIGHLIGHT"		: "Highlight",
		"TARGETING"		: "Targeting",
		"CLEAR"			: "Clear",
		"DAMAGE"			: "Damage",
		"MISS"			: "Miss",
		"HEALING"		: "Healing",
		"DEAD"			: "Dead"
	} , 
	"ALWAYS" : {
		"IDLE"			: "Idle",
		"ACTING"			: "Acting"
	}
}


const STATE = { 
	"TARGETING" : "stateTargeting" , 
	"HIGHLIGHT" : "stateHighlight" , 
	"DAMAGE"		: "stateDamage", 
	"HEALING"	: "stateHealing", 
	"MISS"		: "stateMiss" ,
	"DEAD"		: "stateDead" ,
	"ACTING"		: "stateActing", 
	"ENDINGTURN": "stateEndTurn",
	"CLEAR"		: "stateClear" , 
	"LOCK"		: "stateLock" 
}

var myState = null
var prevState = null

var eventBus = null
var crewman = null

export(bool) var isOnPlayerSide = true
export(int) var myX = 0
export(int) var myY = 0

func stateActing():
	myState = STATE.ACTING
	alwaysAnimations.play( ANIMATIONS.ALWAYS.ACTING )
	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_IGNORE )

func stateDead():
	myState = STATE.DEAD

	stateAnimations.queue( ANIMATIONS.STATE.DEAD )
	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_IGNORE )
	yield( get_tree().create_timer( 1.0 ), "timeout" )

	hide() # TODO - have an unset state

func stateEndTurn():
	myState = STATE.CLEAR

	alwaysAnimations.play( ANIMATIONS.ALWAYS.IDLE )

	setState( STATE.CLEAR )

func stateHealing():
	pass

func stateMiss( toHit ):
	myState = STATE.MISS

	stateAnimations.play( ANIMATIONS.STATE.MISS )
	

	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_IGNORE )
	otherNodes.MissText.set_text( "Miss! ( " + str(toHit)  + "% )" )

func stateDamage( damage : int ):
	myState = STATE.DAMAGE
	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_IGNORE )
	otherNodes.DamageText.set_text( str(damage) )

	stateAnimations.play( ANIMATIONS.STATE.DAMAGE )
	yield( stateAnimations , "animation_finished" )

	var isDead = crewman.applyDamage( damage, 'DMG_TYPE_NOT_IMPLIMENTED' )
	if( isDead ):
		setState( STATE.DEAD )
	else:
		setState( STATE.CLEAR )

	loadData()

func stateTargeting():
	myState = STATE.TARGETING
	stateAnimations.play( ANIMATIONS.STATE.TARGETING )
	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_PASS )

func stateHighlight():
	prevState = myState 
	myState = STATE.HIGHLIGHT
	stateAnimations.play( ANIMATIONS.STATE.HIGHLIGHT )

func stateLock():
	#if( myState == STATE.CLEAR ):
	myState = STATE.LOCK
	otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_IGNORE )

func stateClear():
	if( prevState && prevState != STATE.CLEAR ):
		setState( prevState )
		prevState = null
	else: 
		prevState = null 
		myState = STATE.CLEAR
		stateAnimations.play( ANIMATIONS.STATE.CLEAR )
		otherNodes.Texture.set_mouse_filter( otherNodes.Texture.MOUSE_FILTER_PASS )

func setupScene( eBus : EventBus ):
	eventBus = eBus

	loadEvents()
	setState( STATE.CLEAR )

	if( is_inside_tree() ):
		loadData()
	
	if( isOnPlayerSide ):
		barNodesStandard.Handle.show()
		barNodes = barNodesStandard
	else:
		barNodesReversed.Handle.show()
		barNodes = barNodesReversed

		otherNodes.DamageText.set_scale( Vector2( -1 , 1 ) )
		otherNodes.MissText.set_scale( Vector2( -1, 1 ) )
		otherNodes.DeadText.set_scale( Vector2( -1, 1) )

func _ready():
	alwaysAnimations.play( ANIMATIONS.ALWAYS.IDLE )
	setState( STATE.CLEAR )

func loadEvents():
	# Targeting Events
	if( isOnPlayerSide ):
		eventBus.register("CrewmanTurnStart" , self , "_onCrewmanTurnStart" )
		eventBus.register("CrewmanTurnEnd" , self , "_onCrewmanTurnEnd")
	else:
		eventBus.register("EnemyTurnStart" , self, "_onEnemyTurnStart" )
		eventBus.register("EnemyTurnEnd" , self , "_onEnemyTurnEnd")
	
	eventBus.register("TargetingTile" , self , "_onTargetingTile")
	eventBus.register("TargetingBattler" , self, "_onTargetingBattler")

	# Bailing Events
	eventBus.register("GeneralCancel" , self, "_onGeneralCancel" )
	eventBus.register("TurnEnd" , self , "_onTurnEnd")

func _onCrewmanTurnEnd( turnCrewman : Crew ):
	if( crewman ):
		if( turnCrewman.getFullName() == crewman.getFullName() ):
			setState( STATE.ENDINGTURN )

func _onEnemyTurnEnd( turnCrewman : Crew ):
	if( crewman ):
		if( turnCrewman.getFullName() == crewman.getFullName() ):
			setState( STATE.ENDINGTURN )

func _onCrewmanTurnStart( turnCrewman : Crew ):
	if( crewman ):
		if( turnCrewman.getFightableStatus() && turnCrewman.getFullName() == crewman.getFullName() ): # TODO : Stupid way to check, but fine for now
			setState( STATE.ACTING )

func _onEnemyTurnStart( turnCrewman : Crew ):
	if( crewman ):
		if( turnCrewman.getFightableStatus() && turnCrewman.getFullName() == crewman.getFullName()  ):
			setState( STATE.ACTING )

func hasCrewman():
	if( crewman ):
		return true
	else:
		return false

func getCrewman():
	if( crewman ):
		return crewman
	return false

func setState( stateName : String , params = [] ):
	callv( stateName , params )

func loadData( newCrewman = null ):
	if( newCrewman ):
		crewman = newCrewman

	if( crewman ):
		var hp = crewman.getHPStatBlock()
		barNodes.HealthBar.set_max( hp.total )
		barNodes.HealthBar.set_value( hp.current )
		barNodes.HealthValue.set_text( crewman.getHitPointString() )
		
		var morale = crewman.getMoraleStatBlock()
		barNodes.MoraleBar.set_max( morale.total )
		barNodes.MoraleBar.set_value( morale.current )
		barNodes.MoraleValue.set_text( crewman.getMoraleString() )

		show()
	else:
		hide()

func _onTargetingTile( validTargetMatrix , targetsPlayer ):
	setState( STATE.LOCK )

func _onTargetingBattler( validTargetMatrix , targetsPlayer ):
	if( isOnPlayerSide == targetsPlayer && validTargetMatrix[myX][myY] ):
		setState( STATE.TARGETING )
	else:
		setState( STATE.LOCK )

func _onGeneralCancel():
	setState( STATE.CLEAR )

func _onTurnEnd( crewman : Crew ):
	# TODO - maybe do a match so it knows to roll some kind of targeting animation?
	setState( STATE.CLEAR )

func _gui_input( input ):
	if( myState == STATE.HIGHLIGHT && prevState == STATE.TARGETING && input.is_action_pressed( "GUI_SELECT" ) ):
		print("Battler at " , myX , ":" , myY , " is a valid target and clicked")
		eventBus.emit( "TargetingSelected" , [ myX , myY , crewman.isPlayer ] )

func _onMouseEntered():
	setState( STATE.HIGHLIGHT )
	eventBus.emit("HoverCrewman" , [ crewman ] )

func _onMouseExited():
	setState( STATE.CLEAR )
	eventBus.emit("UnhoverCrewman" , [ crewman ])