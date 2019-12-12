extends Item

class_name Console

const ASSIGNABLE = "Assignable"
# TODO - Change to enum + array index instead
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
	self.consoleName = name 
	self.consoleCategory = category
	self.consoleDescription = desc
	self.consolePriTrait = priTrait
	self.consoleSecTrait = secTrait

func get_class(): 
	return "Console"

func is_class( name : String ): 
	return name == "Console"

func assignCrewman( crewman = null ):
	var oldCrewman = self.consoleAssignedCrewman
	self.consoleAssignedCrewman = crewman
	
	if( oldCrewman ):
		oldCrewman.assign()

	if( crewman ):
		crewman.assign( self )

func isAssignable( crewman : Crew ) -> String :
	# TODO add any testing we might need to do
	return self.ASSIGNABLE