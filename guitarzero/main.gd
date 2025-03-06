extends Node

@export var peg_scene: PackedScene
@export var speed: int = 300
@export var spawn: bool = true

var score = 0
var notes = []

const Notes = ["E", "A", "D", "G", "B", "HIGH_E"]
const Colors = [
	Color(0, 1, 0), 
	Color(1, 0, 0), 
	Color(1, 1, 0, 1), 
	Color(0,0,1), 
	Color(0.9635, 0.5676, 0.0251, 1),
	Color(0.5573, 0.0149, 0.9531, 1)
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Note_Spawn_Timer.start()
	$ScoreValue.text = str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_string_pluck(stringName: String) -> void:
	var foundNote = null
	var notesOfString = notes.filter(func(note): return note != null and note.string == stringName)
	
	#print("Checking note ", stringName, " and found notes: ", notesOfString.size())
	
	if notesOfString.size() == 0:
		return
	
	for note in notesOfString:
		if note == null or foundNote != null:
			continue
		
		if note.isHittable:
			score = score + 1
			foundNote = note
			$ScoreValue.text = str(score)
			
	if foundNote != null:
		notes.erase(foundNote)
		foundNote.isHit = true

func _on_note_spawn_timer_timeout() -> void:
	var random_index = randi_range(0, 5);
	var noteName = Notes[random_index]
	var noteCol = Colors[random_index]
	var noteSpawn = get_node(noteName + "_Spawn")
	
	if !spawn:
		return
		 
	var note = peg_scene.instantiate()
	
	note.string = noteName
	note.get_child(0).modulate = noteCol
	
	note.position = noteSpawn.position
	var velocity = Vector2(0, 200)
	note.linear_velocity = velocity
	
	notes.append(note)
	add_child(note)
