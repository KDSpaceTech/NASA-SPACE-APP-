extends Sprite2D
## Extracted spaceship interior map + hull collision.
##
## The hull outline below was traced from the source artwork (pixel space).
## Collision segments are generated from it at runtime so the player can walk
## around the whole station but never drift out into space.

const TEX_SIZE := Vector2(2752.0, 1536.0)
const MAP_SCALE := 0.5

# Outer silhouette of the station, in texture pixels.
var HULL := PackedVector2Array([
	Vector2(2672, 384), Vector2(2320, 148), Vector2(1988, 144), Vector2(1744, 36),
	Vector2(1724, 0), Vector2(1360, 0), Vector2(1340, 36), Vector2(1088, 148),
	Vector2(500, 144), Vector2(364, 244), Vector2(372, 272), Vector2(436, 224),
	Vector2(476, 220), Vector2(504, 248), Vector2(480, 336), Vector2(436, 340),
	Vector2(368, 392), Vector2(348, 452), Vector2(304, 456), Vector2(276, 432),
	Vector2(272, 400), Vector2(292, 376), Vector2(280, 356), Vector2(200, 412),
	Vector2(144, 416), Vector2(48, 492), Vector2(44, 520), Vector2(80, 524),
	Vector2(108, 552), Vector2(104, 584), Vector2(48, 632), Vector2(48, 688),
	Vector2(120, 684), Vector2(172, 740), Vector2(192, 824), Vector2(252, 824),
	Vector2(320, 780), Vector2(388, 804), Vector2(468, 756), Vector2(648, 824),
	Vector2(668, 888), Vector2(624, 920), Vector2(556, 888), Vector2(392, 888),
	Vector2(380, 948), Vector2(324, 996), Vector2(328, 1052), Vector2(284, 1080),
	Vector2(284, 1120), Vector2(260, 1148), Vector2(196, 1152), Vector2(152, 1176),
	Vector2(92, 1136), Vector2(12, 1204), Vector2(44, 1232), Vector2(60, 1320),
	Vector2(104, 1368), Vector2(252, 1456), Vector2(320, 1476), Vector2(568, 1476),
	Vector2(720, 1376), Vector2(760, 1400), Vector2(764, 1464), Vector2(780, 1464),
	Vector2(836, 1416), Vector2(812, 1296), Vector2(868, 1232), Vector2(952, 1184),
	Vector2(1032, 1264), Vector2(1156, 1304), Vector2(1164, 1388), Vector2(1192, 1416),
	Vector2(1168, 1532), Vector2(1388, 1532), Vector2(1404, 1428), Vector2(1448, 1328),
	Vector2(1488, 1324), Vector2(1644, 1400), Vector2(1852, 1256), Vector2(1788, 1220),
	Vector2(1736, 1264), Vector2(1688, 1232), Vector2(1692, 1200), Vector2(1752, 1140),
	Vector2(1756, 1084), Vector2(1796, 1060), Vector2(1952, 1120), Vector2(1968, 1180),
	Vector2(1932, 1220), Vector2(1940, 1280), Vector2(2292, 1384), Vector2(2316, 1412),
	Vector2(2316, 1532), Vector2(2384, 1532), Vector2(2416, 1452), Vector2(2468, 1424),
	Vector2(2544, 1336), Vector2(2620, 1348), Vector2(2636, 1276), Vector2(2664, 1240),
	Vector2(2660, 1004), Vector2(2484, 944), Vector2(2464, 896), Vector2(2576, 788),
	Vector2(2616, 784), Vector2(2652, 812), Vector2(2688, 780), Vector2(2692, 448),
])

func _ready() -> void:
	scale = Vector2(MAP_SCALE, MAP_SCALE)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_build_collision()

func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "Hull"
	body.collision_layer = 1
	body.collision_mask = 0

	var poly := CollisionPolygon2D.new()
	poly.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	var pts := PackedVector2Array()
	for p in HULL:
		pts.append(p - TEX_SIZE * 0.5)
	poly.polygon = pts
	body.add_child(poly)
	add_child(body)
