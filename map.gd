extends Node2D
## Simple surrounding map: ground + boundary walls.

const ARENA_HALF := 900.0

func _ready() -> void:
	# Ground
	var ground = ColorRect.new()
	ground.color = Color(0.12, 0.10, 0.18, 1.0)
	ground.size = Vector2(ARENA_HALF * 2, ARENA_HALF * 2)
	ground.position = Vector2(-ARENA_HALF, -ARENA_HALF)
	add_child(ground)

	# Grid lines for reference
	for i in range(-8, 9):
		var v = Line2D.new()
		v.add_point(Vector2(i * 200.0, -ARENA_HALF))
		v.add_point(Vector2(i * 200.0, ARENA_HALF))
		v.width = 1.0
		v.default_color = Color(0.25, 0.22, 0.35, 0.6)
		add_child(v)
		var h = Line2D.new()
		h.add_point(Vector2(-ARENA_HALF, i * 200.0))
		h.add_point(Vector2(ARENA_HALF, i * 200.0))
		h.width = 1.0
		h.default_color = Color(0.25, 0.22, 0.35, 0.6)
		add_child(h)

	# Boundary walls
	_make_wall(Vector2(0, -ARENA_HALF - 10), Vector2(ARENA_HALF * 2 + 20, 20))
	_make_wall(Vector2(0, ARENA_HALF + 10), Vector2(ARENA_HALF * 2 + 20, 20))
	_make_wall(Vector2(-ARENA_HALF - 10, 0), Vector2(20, ARENA_HALF * 2 + 20))
	_make_wall(Vector2(ARENA_HALF + 10, 0), Vector2(20, ARENA_HALF * 2 + 20))

func _make_wall(pos: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.position = pos
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	# Visual wall
	var vis = ColorRect.new()
	vis.color = Color(0.35, 0.3, 0.45, 1.0)
	vis.size = size
	vis.position = -size / 2
	body.add_child(vis)
	add_child(body)