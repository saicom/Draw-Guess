extends ColorRect

@onready var h_slider: HSlider = $HSlider

var cur_width = 1.0


func _ready() -> void:
	h_slider.value_changed.connect(on_width_changed)


func on_width_changed(value: float):
	cur_width = value
	queue_redraw()


func _draw() -> void:
	var rect = get_rect().size

	draw_line(Vector2(0, rect.y/2.0), Vector2(rect.x, rect.y/2.0), Color.BLACK, cur_width)
