extends Node2D
## Spaceship bridge (main control room) - detailed map.

const W := 2000.0
const H := 1500.0

func _ready() -> void:
	# Floor base
	var floor = ColorRect.new()
	floor.color = Color(0.05, 0.08, 0.14, 1.0)
	floor.size = Vector2(W, H)
	floor.position = Vector2(-W/2, -H/2)
	add_child(floor)

	# Floor tiles (checker-ish)
	for x in range(-9, 10):
		for y in range(-7, 8):
			var tile = ColorRect.new()
			var shade = 0.12 + (abs(x)+abs(y)) % 2 * 0.04
			tile.color = Color(shade, shade+0.05, shade+0.12, 1.0)
			tile.size = Vector2(95, 95)
			tile.position = Vector2(x*105 - 47, y*105 - 47)
			add_child(tile)

	# Seams
	for i in range(-9, 10):
		var v = Line2D.new()
		v.add_point(Vector2(i*105, -H/2))
		v.add_point(Vector2(i*105, H/2))
		v.width = 1.0
		v.default_color = Color(0.2, 0.45, 0.7, 0.6)
		add_child(v)
	for i in range(-7, 8):
		var h = Line2D.new()
		h.add_point(Vector2(-W/2, i*105))
		h.add_point(Vector2(W/2, i*105))
		h.width = 1.0
		h.default_color = Color(0.2, 0.45, 0.7, 0.6)
		add_child(h)

	# Walls
	_make_wall(Vector2(0, -H/2 - 16), Vector2(W + 32, 32), Color(0.2, 0.25, 0.35, 1.0))
	_make_wall(Vector2(0, H/2 + 16), Vector2(W + 32, 32), Color(0.2, 0.25, 0.35, 1.0))
	_make_wall(Vector2(-W/2 - 16, 0), Vector2(32, H + 32), Color(0.2, 0.25, 0.35, 1.0))
	_make_wall(Vector2(W/2 + 16, 0), Vector2(32, H + 32), Color(0.2, 0.25, 0.35, 1.0))

	# Front console (top) with multiple screens
	var front = ColorRect.new()
	front.color = Color(0.12, 0.16, 0.24, 1.0)
	front.size = Vector2(W - 120, 110)
	front.position = Vector2(-W/2 + 60, -H/2 + 30)
	add_child(front)
	for i in range(7):
		var scr = ColorRect.new()
		scr.color = Color(0.15, 0.75, 1.0, 0.95)
		scr.size = Vector2(150, 60)
		scr.position = Vector2(-W/2 + 100 + i*260, -H/2 + 50)
		add_child(scr)
		# button row
		for b in range(4):
			var btn = ColorRect.new()
			btn.color = Color(0.9, 0.5, 0.15, 1.0)
			btn.size = Vector2(28, 12)
			btn.position = Vector2(-W/2 + 110 + i*260 + b*32, -H/2 + 120)
			add_child(btn)

	# Side consoles (left/right)
	for side in [-1, 1]:
		var sc = ColorRect.new()
		sc.color = Color(0.12, 0.16, 0.24, 1.0)
		sc.size = Vector2(100, 360)
		sc.position = Vector2(side*(W/2 - 120), -80)
		add_child(sc)
		for k in range(3):
			var scr2 = ColorRect.new()
			scr2.color = Color(1.0, 0.55, 0.15, 0.95)
			scr2.size = Vector2(70, 45)
			scr2.position = Vector2(side*(W/2 - 105), -60 + k*95)
			add_child(scr2)

	# Captain chair (center)
	var chair = ColorRect.new()
	chair.color = Color(0.35, 0.38, 0.48, 1.0)
	chair.size = Vector2(70, 70)
	chair.position = Vector2(-35, 60)
	add_child(chair)
	# Chair back
	var back = ColorRect.new()
	back.color = Color(0.3, 0.33, 0.42, 1.0)
	back.size = Vector2(70, 25)
	back.position = Vector2(-35, 35)
	add_child(back)

	# Side chairs
	for side in [-1, 1]:
		for k in range(2):
			var ch = ColorRect.new()
			ch.color = Color(0.3, 0.33, 0.42, 1.0)
			ch.size = Vector2(50, 50)
			ch.position = Vector2(side*260, 40 + k*90)
			add_child(ch)

	# Decor: floor lights (strips)
	for i in range(-3, 4):
		var light = ColorRect.new()
		light.color = Color(0.2, 0.9, 1.0, 0.8)
		light.size = Vector2(180, 6)
		light.position = Vector2(i*220 - 90, H/2 - 60)
		add_child(light)

	# Crates (obstacles with collision)
	_make_crate(Vector2(-420, 260), Vector2(80, 60))
	_make_crate(Vector2(420, 260), Vector2(80, 60))
	_make_crate(Vector2(0, -260), Vector2(100, 50))

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

func _make_crate(pos: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	var vis = ColorRect.new()
	vis.color = Color(0.45, 0.35, 0.25, 1.0)
	vis.size = size
	vis.position = -size / 2
	body.add_child(vis)
	# highlight
	var hi = ColorRect.new()
	hi.color = Color(0.7, 0.55, 0.35, 1.0)
	hi.size = Vector2(size.x, 6)
	hi.position = Vector2(-size.x/2, -size.y/2)
	body.add_child(hi)
	add_child(body)