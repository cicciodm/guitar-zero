extends Node2D


const VU_COUNT = 16
const FREQ_MAX = 11050.0

const WIDTH = 800
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60
const ANIMATION_SPEED = 0.1

var spectrum
var frame_count = 0;

const STRING_COUNT = 6
const SD = 1

const E = 170
const A = 130
const D = 153
const G = 205
const B = 245
const HIGH_E = 333

const FREQ_CENTERS = [E, A, D, G, B, HIGH_E]
const STRING_NAMES = ["E", "A", "D", "G", "B", "HIGH_E"]

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
	var freqs = data.slice(0, 10);
	#pr(["analysing", freqs])
	
	for note in FREQ_CENTERS:
		var deltas = []
		for freq in freqs:
			var diff = abs(freq[0] - note)
			deltas.append(diff)
		var mean = avg(deltas)
		if mean < lowest_mean:
			lowest_mean = mean
			lowest_idx = idx
		idx = idx + 1
	
	if (lowest_idx == 5):
		var low = freqs.filter(func(v): return abs(v[0] - 80) <= 5)
		lowest_idx = 0 if low.any(func(f): return f[1] > 0.5) else lowest_idx
		
			
		# if this is an E, gotta check for low freqs
	
	return STRING_NAMES[lowest_idx]

#func _draw():
	#var w = WIDTH / VU_COUNT
	#for i in range(VU_COUNT):
		#var min_height = min_values[i]
		#var max_height = max_values[i]
		#var height = lerp(min_height, max_height, ANIMATION_SPEED)
		#if frame_count % 60 == 0 :
			#print(min_values, max_values)
		#
		#frame_count = frame_count + 1;

		#draw_rect(
				#Rect2(w * i, HEIGHT - height, w - 2, height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6)
		#)
		#draw_line(
				#Vector2(w * i, HEIGHT - height),
				#Vector2(w * i + w - 2, HEIGHT - height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0),
				#2.0,
				#true
		#)
#
		## Draw a reflection of the bars with lower opacity.
		#draw_rect(
				#Rect2(w * i, HEIGHT, w - 2, height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6) * Color(1, 1, 1, 0.125)
		#)
		#draw_line(
				#Vector2(w * i, HEIGHT + height),
				#Vector2(w * i + w - 2, HEIGHT + height),
				#Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 1.0) * Color(1, 1, 1, 0.125),
				#2.0,
				#true
		#)

func pr(something: Array):
	if (frame_count % 120 == 0):
		print(something)

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))

func log2(value):
	return log(value) / log(2)

func comp_freqs(f1: Vector2, f2: Vector2):
	return f1[1] > f2[1]

func _process(_delta):
	var prev_hz = 0
	var magnitudes = []
	var rm = []
	var strings = []

	# Gather data
	for freq_int in range(1, 1000):
		var freq = freq_int / float(2);
		var hz_min = freq - SD
		var hz_max = freq + SD
		var magnitude_raw = spectrum.get_magnitude_for_frequency_range(hz_min, hz_max).length()
		var magnitude = round_place(magnitude_raw * 10, 3)
		rm.append(magnitude_raw)
		magnitudes.append(Vector2(freq, magnitude))

	magnitudes.sort_custom(comp_freqs)
	
	var closest_note = "Nothing plucked";
	
	if (magnitudes[0][1] > 0.1):
		closest_note = find_closest_note(magnitudes);
	
	pr(["detected closest note", closest_note])
	
		#print("Strings:", strings)
	frame_count = frame_count + 1;
	
	#for i in range(1, VU_COUNT + 1):
		#var hz = i * FREQ_MAX / VU_COUNT
		#var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		#var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		#var height = energy * HEIGHT * HEIGHT_SCALE
		#data.append(height)
		#prev_hz = hz
#
	#for i in range(VU_COUNT):
		#if data[i] > max_values[i]:
			#max_values[i] = data[i]
		#else:
			#max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)
#
		#if data[i] <= 0.0:
			#min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)

	# Sound plays back continuously, so the graph needs to be updated every frame.
	queue_redraw()


func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
