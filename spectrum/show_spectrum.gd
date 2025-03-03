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
const E = 82
const A = 110
const D = 147
const G = 196
const B = 247
const HIGH_E = 330 
const SD = 0.3

const FREQUENCIES = [E, A, D, G, B, HIGH_E]
const STRING_NAMES = ["E", "A", "D", "G", "B", "HIGH_E"]

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
	if (frame_count % 60 == 0):
		print(something)

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))

func _process(_delta):
	var prev_hz = 0
	var magnitudes = []
	var rm = []
	var strings = []

	# Gather data
	for freq in FREQUENCIES:
		var hz_min = freq - SD
		var hz_max = freq + SD
		var magnitude_raw = spectrum.get_magnitude_for_frequency_range(hz_min, hz_max).length()
		var magnitude = round_place(magnitude_raw * 100, 4)
		rm.append(magnitude_raw)
		magnitudes.append(magnitude)
	pr(["magnitudes", magnitudes])

	#compare to previous
	#for string in STRING_NAMES.size():
		#var diff = abs(magnitudes[string] - previous_magnitudes[string])
		#differences.append(diff)
	#pr(["Raw", rm])
	#pr(["Magnitudes", magnitudes])
	# find max
	var maxMag = magnitudes.max();
	
	if maxMag == 0:
		strings.resize(STRING_COUNT)
		strings.fill(0)
	else:
		for idx in STRING_NAMES.size():
			if magnitudes[idx] == maxMag:
				strings.append(1)
			else:
				strings.append(0)
	

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
