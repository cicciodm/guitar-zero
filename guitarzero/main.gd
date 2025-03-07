extends Node

@export var peg_scene: PackedScene
@export var speed: int = 300
@export var spawn: bool = true
@export var BPM: int = 100
@export var NOTE_UNIT_RATIO: int = 8 #8th note 
@export var time_signature_top: int = 4
@export var time_signature_bottom: int = 4
@export var click: bool = false

const Notes = ["E", "A", "D", "G", "B", "HIGH_E"]
const Colors = {
	"E": Color(0, 1, 0), 
	"A": Color(1, 0, 0), 
	"D": Color(1, 1, 0, 1), 
	"G": Color(0,0,1), 
	"B": Color(0.9635, 0.5676, 0.0251, 1),
	"HIGH_E": Color(0.5573, 0.0149, 0.9531, 1)
}

var score = 0
var notes = []
var note_counter = 0
var current_note_index = 0;
var level_data;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScoreValue.text = str(score)
	var secondsPerNote = (float(60) / BPM) / (NOTE_UNIT_RATIO / time_signature_bottom)
	$Note_Spawn_Timer.start(secondsPerNote)
	var file = FileAccess.open("res://levels/level1.json", FileAccess.READ)
	level_data = JSON.parse_string(file.get_as_text()) as Array;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_player_string_pluck(stringName: String, fret: String) -> void:
	var foundNote = null
	var notesOfString = notes.filter(func(note): return note != null and note.string == stringName)
	$FretValue.text = fret
	
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
	$NoteValue.text = str(note_counter);
	
	var note_unit_per_beat = NOTE_UNIT_RATIO / time_signature_bottom;
	var note_unit_per_bar = note_unit_per_beat * time_signature_top;
	
	if click and note_counter % note_unit_per_beat == 0:
		$Click.play(0.02)
		if (!$LevelTrackPlayer.playing):
			$LevelTrackPlayer.play()
	
	if note_counter % note_unit_per_bar == 0:
		$BarValue.text = str((note_counter / note_unit_per_bar) + 1) 
	
	if (current_note_index == level_data.size()):
		note_counter = note_counter + 1
		return;
	
	var current_note_data = level_data[current_note_index];
	var note_start = current_note_data["start"];
	
	if (note_start == note_counter):
		var noteName = current_note_data["string"]
		var noteCol = Colors[noteName]
		var noteSpawn = get_node(noteName + "_Spawn")
		
		if !spawn:
			return
			 
		var note = peg_scene.instantiate()
		
		note.string = noteName
		note.get_child(0).modulate = noteCol
		
		note.position = noteSpawn.position
		var velocity = Vector2(0, 225)
		note.linear_velocity = velocity
		
		notes.append(note)
		add_child(note)
		current_note_index = current_note_index + 1			
	
	note_counter = note_counter + 1
	
	
