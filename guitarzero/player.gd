extends Node2D
signal string_pluck

const FREQ_MAX = 350

var spectrum
var frame_count = 0;

const SD = 1

const E = 100
const A = 119
const A_DOUBLE = 222
const D = 165
const D_DOUBLE = 315
const G = 209
const B = 245
const HIGH_E = 333

const FREQ_CENTERS = [E, A, A_DOUBLE, D,D_DOUBLE, G, B, HIGH_E]
const STRING_NAMES = ["E", "A", "A", "D", "D", "G", "B", "HIGH_E"]
const SINGLE_STRING_NAMES = ["E", "A", "D", "G", "B", "HIGH_E"]

const Colors = [
	Color(0, 1, 0), 
	Color(1, 0, 0), 
	Color(1, 1, 0, 1), 
	Color(0,0,1), 
	Color(0.9635, 0.5676, 0.0251, 1),
	Color(0.5573, 0.0149, 0.9531, 1)
]

func avg(arr: Array):
	var sum = 0;
	for i in arr:
		sum = sum + i
	return float(sum) / len(arr)

# magnitudes is a sorted array of (Freq, magnitude)
func find_closest_note(data):
	var lowest_mean = 1000000000000000;
	var lowest_idx = 0;
	var idx = 0
	var freqs = data.slice(0, 20);
	#print(["analysing", freqs.slice(0,10)])
	
	for note in FREQ_CENTERS:
		var deltas = []
		for freq in freqs:
			var diff = abs(freq[0] - note)
			deltas.append(diff)
		var mean = avg(deltas)
		#print(["Comparing to ", note, " got ", deltas, "with avg", mean])
		if mean < lowest_mean:
			lowest_mean = mean
			lowest_idx = idx
		#pr(["Comparing to", note, "found", deltas, "with avg", mean])
		idx = idx + 1
	
		# if this is a high E, gotta check for low freqs
	if (lowest_idx == STRING_NAMES.size() - 1):
		var low = freqs.filter(func(v): return abs(v[0] - 80) <= 5)
		lowest_idx = 0 if low.any(func(f): return f[1] > 0.5) else lowest_idx
	
	#print(["Found lowest idx", lowest_idx, " therefore returning", STRING_NAMES[lowest_idx]])
	
	return STRING_NAMES[lowest_idx]

func pr(something: Array):
	if (frame_count % 120 == 0):
		print(something)

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))

func comp_freqs(f1: Vector2, f2: Vector2):
	return f1[1] > f2[1]

var latest_note = null;
var cumulative_delta = 0;

func _process(delta):
	cumulative_delta = cumulative_delta + delta;
	if (cumulative_delta < 0.3):
		return;
	
	cumulative_delta = 0
	
	var magnitudes = []

	# Gather data
	for freq_int in range(1, FREQ_MAX*2):
		var freq = freq_int / float(2);
		var hz_min = freq - SD
		var hz_max = freq + SD
		var magnitude_raw = spectrum.get_magnitude_for_frequency_range(hz_min, hz_max).length()
		var magnitude = round_place(magnitude_raw * 10, 3)
		magnitudes.append(Vector2(freq, magnitude))

	magnitudes.sort_custom(comp_freqs)
	
	var closest_note = "Nothing plucked";
	
	if (magnitudes[0][1] > 0.1):
		closest_note = find_closest_note(magnitudes);
		
	if closest_note != "Nothing plucked":
		var spriteName = closest_note + "_String";
		get_node(spriteName).play()
		string_pluck.emit(closest_note)
		if latest_note != closest_note:
			if latest_note != null:
				var latestName = latest_note + "_String";
				get_node(latestName).stop()
			latest_note = closest_note
	else:
		for string in STRING_NAMES:
			var spriteName = string + "_String";
			get_node(spriteName).stop()
	
	#pr(["detected closest note", closest_note])
	
	frame_count = frame_count + 1;

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	for string_idx in range(0, SINGLE_STRING_NAMES.size()):
		var spriteName = SINGLE_STRING_NAMES[string_idx] + "_String";
		get_node(spriteName).modulate = Colors[string_idx]

func _on_strike_area_body_entered(body: Node2D) -> void:
	body.isHittable = true

func _on_strike_area_body_exited(body: Node2D) -> void:
	body.isHittable = false
