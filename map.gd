extends Node2D
## Spaceship bridge (main control room) map.

const W := 1200.0
const H := 900.0

func _ready() -> void:
	# Floor base
	var floor = ColorRect.new()
	floor.color = Color(0.06, 0.10, 0.16, 1.0)
	floor.size = Vector2(W, H)
	floor.position = Vector2(-W/2, -H/2)
	add_child(floor)

	# Floor panels (lighter tiles)
	for x in range(-5, 6):
		for y in range(-4, 5):
			var tile = ColorRect.new()
			tile.color = Color(0.10, 0.16, 0.24, 1.0)
			tile.size = Vector2(100, 100)
			tile.position = Vector2(x*110 - 50, y*110 - 50)
			add_child(tile)

	# Panel seams (grid)
	for i in range(-5, 6):
		var v = Line2D.new()
		v.add_point(Vector2(i*110, -H/2))
		v.add_point(Vector2(i*110, H/2))
		v.width = 1.0
		v.default_color = Color(0.2, 0.4, 0.6, 0.5)
		add_child(v)
	for i in range(-4, 5):
		var h = Line2D.new()
		h.add_point(Vector2(-W/2, i*110))
		h.add_point(Vector2(W/2, i*110))
		h.width = 1.0
		h.default_color = Color(0.2, 0.4, 0.6, 0.5)
		add_child(h)

	# Walls (border)
	_make_wall(Vector2(0, -H/2 - 12), Vector2(W + 24, 24), Color(0.25, 0.3, 0.4, 1.0))
	_make_wall(Vector2(0, H/2 + 12), Vector2(W + 24, 24), Color(0.25, 0.3, 0.4, 1.0))
	_make_wall(Vector2(-W/2 - 12, 0), Vector2(24, H + 24), Color(0.25, 0.3, 0.4, 1.0))
	_make_wall(Vector2(W/2 + 12, 0), Vector2(24, H + 24), Color(0.25, 0.3, 0.4, 1.0))

	# Front control console (top)
	var front = ColorRect.new()
	front.color = Color(0.15, 0.2, 0.3, 1.0)
	front.size = Vector2(W - 80, 90)
	front.position = Vector2(-W/2 + 40, -H/2 + 20)
	add_child(front)
	# Screens on console
	for i in range(5):
		var scr = ColorRect.new()
		scr.color = Color(0.2, 0.8, 1.0, 0.9)
		scr.size = Vector2(120, 50)
		scr.position = Vector2(-W/2 + 80 + i*220, -H/2 + 35)
		add_child(scr)

	# Side consoles
	for side in [-1, 1]:
		var sc = ColorRect.new()
		sc.color = Color(0.15, 0.2, 0.3, 1.0)
		sc.size = Vector2(80, 260)
		sc.position = Vector2(side*(W/2 - 100), -60)
		add_child(sc)
		var scr2 = ColorRect.new()
		scr2.color = Color(1.0, 0.6, 0.2, 0.9)
		scr2.size = Vector2(60, 40)
		scr2.position = Vector2(side*(W/2 - 90), -40)
		add_child(scr2)

	# Captain chair (center)
	var chair = ColorRect.new()
	chair.color = Color(0.4, 0.4, 0.5, 1.0)
	chair.size = Vector2(60, 60)
	chair.position = Vector2(-30, 40)
	add_child(chair)

func _make_wall(pos: Vector2, size: Vector2, color: Color) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	var vis = ColorRect.new()
	vis.color = color
	vis.size = size
	vis.position = -size / 2
	body.add_child(vis)
	add_child(body)