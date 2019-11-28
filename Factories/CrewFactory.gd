extends Node

# Write script that populates this data from a folder.
const MALE_PORTRAITS_FOLDER = "res://TextureBank/Faces/BorrowedMen/"
const MALE_PORTRAITS = [
	"man-1", "man-2", "man-3" , "man-4" , "man-5" , "man-6"
]

const FEMALE_PORTRAITS_FOLDER = "res://TextureBank/Faces/BorrowedWomen/"
const FEMALE_PORTRAITS = [
	"woman-1" , "woman-2" , "woman-3" ,  "woman-4" , "woman-5" 
]

const FIRST_NAME_MALES = ["John", "Mike", "Cletus", "Vor", "Zanatos" ,  "Kalin" , "Oric", "Vanus", "Valor", "Talagrius" ]
const FIRST_NAME_FEMALES = ["Sarah" , "Leanne" , "Gloria" , "Moria" , "Deanna", "Hella" , "Stephanie" , "Kryta" , "Oriso" , "Dania", "Daria"]
const MIDDLE_NAMES = ["D.Va" , "Lazarus" , "Corinth" , 
	"Claptrap", "Chaos", "Mobster" , "Destiny" , "Archangel", "Holywar" ,"Ironjaw" , "Rhino", "Hawkeye" , "Darkwave" , 
	"Teuton" , "Livewire" , "Lighting", "Oasis" ,"Walker" , "Slade" , "Bane" , "Monolith", "Icon", "Persues" ]
const LAST_NAMES = ["Jones", "Conner", "Sevarin" , "Corolis" , "Mcqueen" , "King" , "Banks", "Jenkins" , "Caldo" ]
const SEX = ["M", "F"]

func _ready():
	pass

func generateManyCrew( cp : int  , numOfCrew : int  ):
	var crewArray = []

	for x in range(0 , numOfCrew ):
		crewArray.append( generateNewCrew( 30 ) )

	return crewArray

func generateNewCrew( cp = 30 ):
	var crewman = Crew.new()

	crewman = self._rollTraits( crewman )
	crewman = self._rollCosmetics( crewman )
	
	crewman.calculateTraits()
	crewman.calculateDerivedStats( true )

	return crewman

func _rollTalents():
	pass
	# TODO - once talents are implimented

func _rollTraits( myCrewman : Crew ):
	var statTotal = 0

	while statTotal <= myCrewman.cp:
		var rand = randi() % myCrewman.traits.size()
		var keys = myCrewman.traits.keys()
		var stat = keys[rand]
		
		myCrewman.traits[stat].value = myCrewman.traits[stat].value + 1
		statTotal += myCrewman.traits[stat].value
	
	myCrewman.cpSpent = statTotal
	myCrewman.cp = statTotal

	return myCrewman


func _rollCosmetics( myCrewman : Crew  ):
	var sex : String = self.SEX[ randi() % self.SEX.size() ]
	var texture : String = ""
	var fname : String = ""

	if( sex == "M"):
		fname = self.FIRST_NAME_MALES[ randi() % self.FIRST_NAME_MALES.size() ]
		texture = self.MALE_PORTRAITS_FOLDER + self.MALE_PORTRAITS[ randi() % self.MALE_PORTRAITS.size() ]
		
	if( sex == "F"):
		fname = self.FIRST_NAME_FEMALES[ randi() % self.FIRST_NAME_FEMALES.size() ]
		texture = self.FEMALE_PORTRAITS_FOLDER + self.FEMALE_PORTRAITS[ randi() % self.FEMALE_PORTRAITS.size() ]
	
	var lPath : String = texture + ".jpg"
	var sPath : String = texture + "-small.jpg"
	myCrewman.setTextures( sPath, lPath )

	var lname : String = self.LAST_NAMES[ randi() % self.LAST_NAMES.size() ]
	var mname : String = self.MIDDLE_NAMES[ randi() % self.MIDDLE_NAMES.size() ]
	myCrewman.setCosmetic( sex, fname, mname, lname)

	return myCrewman