extends Node2D
## Interactable machine: computer (shop), oxygen concentrator, fuel tank.

var kind: String = "computer"
var sprite: Sprite2D
var label: Label
var _bar_ratio := 0.0
var _bar_color := Color(0.3, 0.8, 1.0)

func setup(machine_kind: String, tex_path: String, target_h: float) -> void:
	kind = machine_kind
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var tex := load(tex_path) as Texture2D
	sprite.texture = tex
	if tex and tex.get_height() > 0:
		var s := target_h / float(tex.get_height())
		sprite.scale = Vector2(s, s)
	sprite.position = Vector2(0, -target_h * 0.5)
	add_child(sprite)

	label = Label.new()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.8, 0.95, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.position = Vector2(-70, -target_h - 22)
	label.size = Vector2(140, 20)
	add_child(label)

	refresh()

func prompt() -> String:
	match kind:
		"computer":
			return "[E] Use computer"
		"oxygen":
			return "[E] Oxygen concentrator (%s)" % ("ON" if Global.oxygen_machine_on else "OFF")
		"fuel":
			return "[E] Fuel tank"
	return ""

func refresh() -> void:
	_bar_ratio = 0.0
	_bar_color = Color(0.3, 0.8, 1.0)
	match kind:
		"computer":
			label.text = "COMPUTER"
		"oxygen":
			var on := Global.oxygen_machine_on
			label.text = "O2 MAKER: %s" % ("ON" if on else "OFF")
			_bar_ratio = Global.oxygen / Global.MAX_OXYGEN
			_bar_color = Color(0.3, 0.8, 1.0) if on else Color(0.4, 0.4, 0.4)
		"fuel":
			label.text = "FUEL %d / %d" % [roundi(Global.fuel), int(Global.MAX_FUEL)]
			_bar_ratio = Global.fuel / Global.MAX_FUEL
			_bar_color = Color(1.0, 0.6, 0.2)
	queue_redraw()

func _draw() -> void:
	# Small progress bar under the machine.
	var w := 70.0
	var y := 6.0
	draw_rect(Rect2(-w * 0.5, y, w, 6), Color(0.05, 0.07, 0.1, 0.9), true)
	draw_rect(Rect2(-w * 0.5, y, w * clampf(_bar_ratio, 0.0, 1.0), 6), _bar_color, true)
