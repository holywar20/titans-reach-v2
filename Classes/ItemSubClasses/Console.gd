extends Item

class_name Console

const ASSIGNABLE = "Assignable"

const CATEGORY = {
	"COMMAND" 	: "Command" , 
	"SECURITY"	: "Security", 
	"ENGINEERING": "Engineering", 
	"SCIENCE"	: "Science", 
	"MEDICAL"	: "Medical", 
	"MEDBAY"		: "Medbay"
}

var consoleName = null
var consoleCategory = null
var consoleDescription = null
var consolePriTrait = null
var consoleSecTrait = null

var consoleAssignedCrewman = null

func _init( name , desc, category, priTrait, secTrait , consoleEffects ):
	consoleName = name 
	consoleCategory = category
	consoleDescription = desc
	consolePriTrait = priTrait
	consoleSecTrait = secTrait

func get_class(): 
	return "Console"

func is_class( name : String ): 
	return name == "Console"

func crewTransaction( newCrewman = null , sourceConsole = null ):
	var isValid = validateCrewmanAssignment( newCrewman )
	
	if( isValid ):
		var currentCrewman = consoleAssignedCrewman
		_assignCrewman( newCrewman )

		if( sourceConsole ):
			sourceConsole._assignCrewman( currentCrewman )

		if( currentCrewman ):
			currentCrewman.assign( sourceConsole )
		
		if( newCrewman ):
			newCrewman.assign( self )
	
	return isValid

# TODO - validate that assignment is acceptable
func validateCrewmanAssignment( crewman ):
	return true 

func _assignCrewman( crewman = null ):
	consoleAssignedCrewman = crewman
	return true 

func isAssignable( crewman : Crew ) -> String :
	# TODO add any testing we might need to do
	return ASSIGNABLE

func getAssignedCrewman():
	return consoleAssignedCrewman