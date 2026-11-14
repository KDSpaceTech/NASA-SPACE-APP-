extends Node2D
## Spaceship bridge (main control room) - detailed.

const W := 2200.0
const H := 1600.0

func _ready() -> void:
	# Floor base
	var floor = ColorRect.new()
	floor.color = Color(0.05, 0.08, 0.14, 1.0)
	floor.size = Vector2(W, H)
	floor.position = Vector2(-W/2, -H/2)
	add_child(floor)

	# Floor tiles
	for x in range(-10, 11):
		for y in range(-7, 8):
			var tile = ColorRect.new()
			var shade = 0.12 + ((abs(x)+abs(y)) % 2) * 0.05
			tile.color = Color(shade, shade+0.06, shade+0.14, 1.0)
			tile.size = Vector2(98, 98)
			tile.position = Vector2(x*102 - 49, y*102 - 49)
			add_child(tile)

	# Seams
	for i in range(-10, 11):
		var v = Line2D.new()
		v.add_point(Vector2(i*102, -H/2))
		v.add_point(Vector2(i*102, H/2))
		v.width = 1.0
		v.default_color = Color(0.25, 0.5, 0.75, 0.6)
		add_child(v)
	for i in range(-7, 8):
		var h = Line2D.new()
		h.add_point(Vector2(-W/2, i*102))
		h.add_point(Vector2(W/2, i*102))
		h.width = 1.0
		h.default_color = Color(0.25, 0.5, 0.75, 0.6)
		add_child(h)

	# Floor markings (yellow hazard lines near consoles)
	for i in range(-3, 4):
		var m = ColorRect.new()
		m.color = Color(0.9, 0.75, 0.2, 0.85)
		m.size = Vector2(140, 4)
		m.position = Vector2(i*260 - 70, -H/2 + 135)
		add_child(m)

	# Walls
	_make_wall(Vector2(0, -H/2 - 18), Vector2(W + 36, 36), Color(0.18, 0.22, 0.32, 1.0))
	_make_wall(Vector2(0, H/2 + 18), Vector2(W + 36, 36), Color(0.18, 0.22, 0.32, 1.0))
	_make_wall(Vector2(-W/2 - 18, 0), Vector2(36, H + 36), Color(0.18, 0.22, 0.32, 1.0))
	_make_wall(Vector2(W/2 + 18, 0), Vector2(36, H + 36), Color(0.18, 0.22, 0.32, 1.0))

	# Windows (top wall) with starfield
	for i in range(6):
		var win = ColorRect.new()
		win.color = Color(0.02, 0.05, 0.12, 1.0)
		win.size = Vector2(200, 60)
		win.position = Vector2(-W/2 + 120 + i*340, -H/2 + 20)
		add_child(win)
		# stars
		for s in range(8):
			var star = ColorRect.new()
			star.color = Color(1.0, 1.0, 1.0, randf_range(0.4, 1.0))
			star.size = Vector2(2, 2)
			star.position = Vector2(win.position.x + randf_range(5, 190), win.position.y + randf_range(5, 50))
			add_child(star)

	# Ceiling lights
	for i in range(-4, 5):
		var cl = ColorRect.new()
		cl.color = Color(0.9, 0.95, 1.0, 0.9)
		cl.size = Vector2(160, 8)
		cl.position = Vector2(i*240 - 80, -H/2 + 8)
		add_child(cl)

	# Front control console (top) with screens + buttons
	var front = ColorRect.new()
	front.color = Color(0.1, 0.14, 0.2, 1.0)
	front.size = Vector2(W - 160, 120)
	front.position = Vector2(-W/2 + 80, -H/2 + 95)
	add_child(front)
	for i in range(8):
		var scr = ColorRect.new()
		scr.color = Color(0.1, 0.7, 0.95, 0.95)
		scr.size = Vector2(140, 55)
		scr.position = Vector2(-W/2 + 110 + i*250, -H/2 + 115)
		add_child(scr)
		for b in range(5):
			var btn = ColorRect.new()
			btn.color = Color(0.95, 0.55, 0.15, 1.0)
			btn.size = Vector2(24, 10)
			btn.position = Vector2(-W/2 + 120 + i*250 + b*28, -H/2 + 180)
			add_child(btn)

	# Side consoles
	for side in [-1, 1]:
		var sc = ColorRect.new()
		sc.color = Color(0.1, 0.14, 0.2, 1.0)
		sc.size = Vector2(110, 420)
		sc.position = Vector2(side*(W/2 - 130), -120)
		add_child(sc)
		for k in range(4):
			var scr2 = ColorRect.new()
			scr2.color = Color(1.0, 0.5, 0.1, 0.95)
			scr2.size = Vector2(80, 50)
			scr2.position = Vector2(side*(W/2 - 115), -100 + k*95)
			add_child(scr2)
		# vents
		for v in range(3):
			var vent = ColorRect.new()
			vent.color = Color(0.25, 0.3, 0.4, 1.0)
			vent.size = Vector2(70, 8)
			vent.position = Vector2(side*(W/2 - 115), 200 + v*18)
			add_child(vent)

	# Holographic table (center)
	var holo = ColorRect.new()
	holo.color = Color(0.2, 0.8, 1.0, 0.35)
	holo.size = Vector2(260, 140)
	holo.position = Vector2(-130, -40)
	add_child(holo)
	var holo2 = ColorRect.new()
	holo2.color = Color(0.4, 0.9, 1.0, 0.6)
	holo2.size = Vector2(200, 6)
	holo2.position = Vector2(-100, 28)
	add_child(holo2)
	var holo3 = ColorRect.new()
	holo3.color = Color(0.4, 0.9, 1.0, 0.6)
	holo3.size = Vector2(6, 80)
	holo3.position = Vector2(-3, -10)
	add_child(holo3)

	# Captain chair (center)
	var chair = ColorRect.new()
	chair.color = Color(0.35, 0.38, 0.5, 1.0)
	chair.size = Vector2(75, 75)
	chair.position = Vector2(-37, 90)
	add_child(chair)
	var back = ColorRect.new()
	back.color = Color(0.28, 0.32, 0.42, 1.0)
	back.size = Vector2(75, 28)
	back.position = Vector2(-37, 62)
	add_child(back)

	# Side chairs
	for side in [-1, 1]:
		for k in range(2):
			var ch = ColorRect.new()
			ch.color = Color(0.28, 0.32, 0.42, 1.0)
			ch.size = Vector2(55, 55)
			ch.position = Vector2(side*280, 80 + k*100)
			add_child(ch)

	# Doors (left/right mid)
	for side in [-1, 1]:
		var door = ColorRect.new()
		door.color = Color(0.5, 0.55, 0.65, 1.0)
		door.size = Vector2(14, 120)
		door.position = Vector2(side*(W/2 - 7), -60)
		add_child(door)
		var frame = ColorRect.new()
		frame.color = Color(0.3, 0.35, 0.45, 1.0)
		frame.size = Vector2(24, 130)
		frame.position = Vector2(side*(W/2 - 12), -65)
		add_child(frame)

	# Floor lights strips (bottom)
	for i in range(-4, 5):
		var light = ColorRect.new()
		light.color = Color(0.2, 0.85, 1.0, 0.85)
		light.size = Vector2(200, 6)
		light.position = Vector2(i*240 - 100, H/2 - 50)
		add_child(light)

	# Crates (obstacles)
	_make_crate(Vector2(-520, 320), Vector2(90, 65))
	_make_crate(Vector2(520, 320), Vector2(90, 65))
	_make_crate(Vector2(0, -320), Vector2(110, 55))
	_make_crate(Vector2(-300, -260), Vector2(70, 50))
	_make_crate(Vector2(300, -260), Vector2(70, 50))

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
	var hi = ColorRect.new()
	hi.color = Color(0.75, 0.55, 0.3, 1.0)
	hi.size = Vector2(size.x, 6)
	hi.position = Vector2(-size.x/2, -size.y/2)
	body.add_child(hi)
	add_child(body)