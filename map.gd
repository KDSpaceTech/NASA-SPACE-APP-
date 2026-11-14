extends Node2D
## ISS (International Space Station) interior module.

const W := 2400.0
const H := 900.0

func _ready() -> void:
	# Floor base (gray panels)
	var floor = ColorRect.new()
	floor.color = Color(0.18, 0.20, 0.22, 1.0)
	floor.size = Vector2(W, H)
	floor.position = Vector2(-W/2, -H/2)
	add_child(floor)

	# Floor panels
	for x in range(-11, 12):
		for y in range(-4, 5):
			var tile = ColorRect.new()
			var shade = 0.20 + ((abs(x)+abs(y)) % 2) * 0.04
			tile.color = Color(shade, shade+0.01, shade+0.02, 1.0)
			tile.size = Vector2(95, 95)
			tile.position = Vector2(x*100 - 47, y*100 - 47)
			add_child(tile)

	# Seams
	for i in range(-11, 12):
		var v = Line2D.new()
		v.add_point(Vector2(i*100, -H/2))
		v.add_point(Vector2(i*100, H/2))
		v.width = 1.0
		v.default_color = Color(0.35, 0.38, 0.42, 0.6)
		add_child(v)
	for i in range(-4, 5):
		var h = Line2D.new()
		h.add_point(Vector2(-W/2, i*100))
		h.add_point(Vector2(W/2, i*100))
		h.width = 1.0
		h.default_color = Color(0.35, 0.38, 0.42, 0.6)
		add_child(h)

	# Walls (white panels)
	_make_wall(Vector2(0, -H/2 - 14), Vector2(W + 28, 28), Color(0.75, 0.78, 0.82, 1.0))
	_make_wall(Vector2(0, H/2 + 14), Vector2(W + 28, 28), Color(0.75, 0.78, 0.82, 1.0))
	_make_wall(Vector2(-W/2 - 14, 0), Vector2(28, H + 28), Color(0.75, 0.78, 0.82, 1.0))
	_make_wall(Vector2(W/2 + 14, 0), Vector2(28, H + 28), Color(0.75, 0.78, 0.82, 1.0))

	# Wall panels (white rectangles)
	for i in range(-10, 11):
		var wp = ColorRect.new()
		wp.color = Color(0.82, 0.85, 0.88, 1.0)
		wp.size = Vector2(80, 60)
		wp.position = Vector2(i*110 - 40, -H/2 + 10)
		add_child(wp)

	# Equipment racks (blue/gray) along top and bottom
	for side in [-1, 1]:
		for i in range(-5, 6):
			var rack = ColorRect.new()
			rack.color = Color(0.25, 0.35, 0.55, 1.0)
			rack.size = Vector2(90, 70)
			rack.position = Vector2(i*180 - 45, side*(H/2 - 95))
			add_child(rack)
			# screen on rack
			var scr = ColorRect.new()
			scr.color = Color(0.4, 0.8, 1.0, 0.9)
			scr.size = Vector2(60, 35)
			scr.position = Vector2(i*180 - 30, side*(H/2 - 80))
			add_child(scr)

	# Side equipment racks (left/right)
	for side in [-1, 1]:
		for k in range(4):
			var rack = ColorRect.new()
			rack.color = Color(0.3, 0.35, 0.45, 1.0)
			rack.size = Vector2(70, 80)
			rack.position = Vector2(side*(W/2 - 90), -120 + k*95)
			add_child(rack)
			var scr = ColorRect.new()
			scr.color = Color(0.9, 0.6, 0.2, 0.9)
			scr.size = Vector2(45, 30)
			scr.position = Vector2(side*(W/2 - 78), -105 + k*95)
			add_child(scr)

	# Cupola window (circular-ish) at top center
	var win = ColorRect.new()
	win.color = Color(0.05, 0.15, 0.35, 1.0)
	win.size = Vector2(180, 120)
	win.position = Vector2(-90, -H/2 + 15)
	add_child(win)
	# Earth view (blue circle)
	var earth = ColorRect.new()
	earth.color = Color(0.1, 0.4, 0.8, 0.9)
	earth.size = Vector2(120, 80)
	earth.position = Vector2(-60, -H/2 + 35)
	add_child(earth)
	# stars
	for s in range(20):
		var star = ColorRect.new()
		star.color = Color(1.0, 1.0, 1.0, randf_range(0.3, 1.0))
		star.size = Vector2(2, 2)
		star.position = Vector2(win.position.x + randf_range(5, 170), win.position.y + randf_range(5, 110))
		add_child(star)

	# Handrails along walls (thin lines)
	for side in [-1, 1]:
		var rail = Line2D.new()
		rail.add_point(Vector2(-W/2 + 20, side*(H/2 - 25)))
		rail.add_point(Vector2(W/2 - 20, side*(H/2 - 25)))
		rail.width = 3.0
		rail.default_color = Color(0.6, 0.65, 0.7, 1.0)
		add_child(rail)
	# side handrails
	for side in [-1, 1]:
		var rail = Line2D.new()
		rail.add_point(Vector2(side*(W/2 - 25), -H/2 + 20))
		rail.add_point(Vector2(side*(W/2 - 25), H/2 - 20))
		rail.width = 3.0
		rail.default_color = Color(0.6, 0.65, 0.7, 1.0)
		add_child(rail)

	# Cables on floor (thin lines)
	for i in range(5):
		var cable = Line2D.new()
		cable.add_point(Vector2(-W/2 + 100 + i*400, -H/2 + 200))
		cable.add_point(Vector2(-W/2 + 300 + i*400, H/2 - 200))
		cable.width = 2.0
		cable.default_color = Color(0.8, 0.2, 0.2, 0.8)
		add_child(cable)

	# Storage bags (small colored rects)
	for i in range(12):
		var bag = ColorRect.new()
		bag.color = Color(randf_range(0.3,0.7), randf_range(0.3,0.7), randf_range(0.3,0.7), 1.0)
		bag.size = Vector2(35, 25)
		bag.position = Vector2(-W/2 + 60 + (i%6)*120, H/2 - 60 - int(i/6)*40)
		add_child(bag)

	# Lighting panels (ceiling)
	for i in range(-4, 5):
		var light = ColorRect.new()
		light.color = Color(0.95, 0.95, 1.0, 0.9)
		light.size = Vector2(180, 10)
		light.position = Vector2(i*260 - 90, -H/2 + 6)
		add_child(light)

	# Obstacles (equipment boxes) with collision
	_make_crate(Vector2(-400, 200), Vector2(100, 70), Color(0.35, 0.4, 0.5, 1.0))
	_make_crate(Vector2(400, 200), Vector2(100, 70), Color(0.35, 0.4, 0.5, 1.0))
	_make_crate(Vector2(0, -220), Vector2(120, 60), Color(0.4, 0.45, 0.55, 1.0))

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

func _make_crate(pos: Vector2, size: Vector2, color: Color) -> void:
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
	var hi = ColorRect.new()
	hi.color = Color(0.7, 0.75, 0.85, 1.0)
	hi.size = Vector2(size.x, 5)
	hi.position = Vector2(-size.x/2, -size.y/2)
	body.add_child(hi)
	add_child(body)