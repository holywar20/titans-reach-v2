extends Control

var noiseMap : OpenSimplexNoise
var systems : Dictionary

onready var noiseView : TextureRect = $NoiseView
onready var starMap : Panel = $ScrollContainer/StarMap

const NOISE_OCTIVES = 4
const NOISE_PEROID = 20
const NOISE_PERSISTANCE = 0.8
const NOISE_IGNORE_THRESHOLD = 0

const SAMPLE_SIZE = 64
const RESOLUTION_SIZE = 2
const TILE_SIZE = 64
const MARGIN_SIZE = 32

const DENSITY = .25

var CORE_SEED_SIZE = 4294967295 # Max seed size is identical to a 32 bits.


export var mySeed = 100000

var starScene = preload("res://ReusableGameObjects/Star/StarIcon.tscn")

# Display local data if scence is instantiated
func _ready():
	seed( 100000 )
	randomize()

	noiseMap = OpenSimplexNoise.new()
	noiseMap.octaves = NOISE_OCTIVES
	noiseMap.period = NOISE_PEROID
	noiseMap.persistence = NOISE_PERSISTANCE

	var image : Image = noiseMap.get_seamless_image( SAMPLE_SIZE )
	var imageTexture = ImageTexture.new()

	_spawnSystems()

func _spawnSystems():

	for x in range( 0 , SAMPLE_SIZE ):
		for y in range( 0, SAMPLE_SIZE ):
			var noisePixel : float = noiseMap.get_noise_2d( x * RESOLUTION_SIZE, y * RESOLUTION_SIZE )
			var densityCheck = rand_range( 0 , 1.0)

			print(noisePixel)

			if( noisePixel < NOISE_IGNORE_THRESHOLD &&  densityCheck < DENSITY ):
				var newSeed = randi() % CORE_SEED_SIZE
				var newSystem : StarSystem = StarSystemFactory.generateRandomSystem( newSeed , x , y )

				systems[newSeed] = newSystem

	for key in systems:
		var icon = starScene.instance()
		var pixelPos : Vector2 = systems[key].position * TILE_SIZE
		pixelPos = Vector2( pixelPos.x - rand_range(-MARGIN_SIZE , MARGIN_SIZE ) , pixelPos.y - rand_range(-MARGIN_SIZE , MARGIN_SIZE ) )

		icon.set_position( pixelPos )
		starMap.add_child( icon )





