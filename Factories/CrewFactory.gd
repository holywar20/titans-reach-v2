extends Node

# TODO - Write script that populates this data from a folder.
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

const AGE_RANGE = [ 24 , 55 ]
const MALE_MASS_RANGE = [ 55 , 100 ]
const FEMALE_MASS_RANGE = [ 45 , 80 ]
const MALE_HEIGHT_RANGE = [ 150 , 210 ] # In centimeters
const FEMALE_HEIGHT_RANGE = [ 140 , 200 ]

const HOMEWORLDS = [ "Earth" , "Nova" , "Calderas" , "Solaris"]
const MAJOR_RACE = [ "Human" ]
const HUMAN_SECTS = ["Meridian" , "Novan" , "Terran" ]

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
	var sex = self.SEX[ randi() % self.SEX.size() ]
	var texture = ""
	var fname = ""
	var height = 0
	var mass = 0

	if( sex == "M"):
		fname = self.FIRST_NAME_MALES[ randi() % self.FIRST_NAME_MALES.size() ]
		texture = self.MALE_PORTRAITS_FOLDER + self.MALE_PORTRAITS[ randi() % self.MALE_PORTRAITS.size() ]
		height = Common.randDiffValues( self.MALE_HEIGHT_RANGE[0] , self.MALE_HEIGHT_RANGE[1] )
		mass = Common.randDiffValues( self.MALE_MASS_RANGE[0] , self.MALE_MASS_RANGE[1] )
		
	if( sex == "F"):
		fname = self.FIRST_NAME_FEMALES[ randi() % self.FIRST_NAME_FEMALES.size() ]
		texture = self.FEMALE_PORTRAITS_FOLDER + self.FEMALE_PORTRAITS[ randi() % self.FEMALE_PORTRAITS.size() ]
		height = Common.randDiffValues( self.FEMALE_HEIGHT_RANGE[0] , self.FEMALE_HEIGHT_RANGE[1] )
		mass = Common.randDiffValues( self.FEMALE_MASS_RANGE[0] , self.FEMALE_MASS_RANGE[1] )
	
	myCrewman.texturePath = texture + ".jpg"
	myCrewman.smallTexturePath = texture + "-small.jpg"
	myCrewman.sex = sex
	myCrewman.height = height
	myCrewman.mass = mass
	
	var lname = self.LAST_NAMES[ randi() % self.LAST_NAMES.size() ]
	var mname = self.MIDDLE_NAMES[ randi() % self.MIDDLE_NAMES.size() ]
	myCrewman.fullname = [ fname, mname, lname ]

	myCrewman.age = Common.randDiffValues( self.AGE_RANGE[0] , self.AGE_RANGE[1] )
	myCrewman.bio = "Not Yet Implimented. Also, I'm a fucking badass murder-hobo hero."

	return myCrewman