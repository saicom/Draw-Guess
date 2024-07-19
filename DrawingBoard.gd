extends ColorRect

@onready var color_picker_button: ColorPickerButton = $"../PenContainer/ColorPickerButton"
@onready var h_slider: HSlider = $"../PenContainer/ColorRect/HSlider"

func _ready() -> void:
	color_picker_button.color_changed.connect(on_color_changed)
	h_slider.value_changed.connect(on_width_changed)
	Global.round_start.connect(on_round_started)


class Line:
	var points: Array[Vector2] = []
	var color: Color = Color.BLACK
	var width: float = 1.0


	func _init(_color: Color, _width: float):
		color = _color
		width = _width

	func add_point(point: Vector2):
		points.append(point)

	
	func points_count():
		return points.size()


	func get_point(i: int):
		if i >= points.size():
			return null
		return points[i]
	


var cur_line: Line
var lines: Array[Line] = []


var cur_color: Color
var cur_width: float = 1.0

var drawing: bool = false

var undo_redo := UndoRedo.new()

@rpc("any_peer", "call_local")
func rpc_add_line(line):
	cur_line = Line.new(line.color, line.width)
	lines.append(cur_line)
	queue_redraw()

@rpc("any_peer", "call_local")
func rpc_remove_line():
	lines.pop_back()
	queue_redraw()


@rpc("any_peer", "call_local")
func rpc_add_point(point):
	cur_line.add_point(point)
	queue_redraw()



func add_line(line):
	rpc_add_line.rpc(line)


func remove_line():
	rpc_remove_line.rpc()


func _gui_input(event: InputEvent) -> void:
	if Global.is_my_round() == false:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
		if drawing:
			#cur_line = Line.new(cur_color, cur_width)
			var line = {"color": cur_color, "width": cur_width}
			undo_redo.create_action("Draw")
			undo_redo.add_do_method(add_line.bind(line))
			undo_redo.add_undo_method(remove_line)
			undo_redo.commit_action()
	elif event is InputEventMouseMotion:
		var rect = get_rect().size
		if event.position.x < 0 or event.position.y < 0 or event.position.x > rect.x or event.position.y > rect.y:
			drawing = false
		if drawing:
			# cur_line.add_point(event.position)
			# queue_redraw()
			rpc_add_point.rpc(event.position)


func _draw() -> void:
	for line in lines:
		var count = line.points_count()
		if count > 1:
			for i in  range(count - 1):
				draw_line(line.get_point(i), line.get_point(i+1), line.color, line.width, true)


func on_color_changed(_color: Color):
	cur_color = _color


func on_width_changed(_width: float):
	cur_width = _width


func _on_undo_pressed() -> void:
	undo_redo.undo()


func _on_redo_pressed() -> void:
	undo_redo.redo()


func on_round_started(_uid, _answer, _tip):
	undo_redo.clear_history()
	cur_line = null
	lines = []
	queue_redraw()
