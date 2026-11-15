# Kế hoạch logic gameplay — Module nhà kính vũ trụ

> **Trạng thái: đã triển khai (bản chơi được).** Tài liệu này là bản thiết kế ban đầu;
> phần đã làm thực tế nằm ở mục 8 bên dưới. Những chỗ khác với thiết kế (dùng
> dictionary thay cho `.tres`, gộp autoload vào `Global.gd`) là cố ý để code gọn và
> chắc chắn hơn.

Tài liệu này mô tả kiến trúc và logic cho bộ asset trong
`NasaspaceApp-Nguyen_Khang_Sinh` (cây trồng, thiết bị, túi đồ, background)
và cách ghép vào project Godot hiện tại (`NasaSpaceApp\4`).

Mục tiêu: biến bộ ảnh tĩnh thành một vòng chơi hoàn chỉnh
**trồng → tưới → chờ → thu hoạch → ăn/bán → nâng cấp**.

---

## 1. Kho asset hiện có và vai trò

### 1.1 Cây trồng (9 loài, ảnh 1024×1024)

| File | Loài | Nhóm (theo docx) | Ghi chú |
|---|---|---|---|
| `Potato.png` | Khoai tây | Stable crop | Ảnh củ (dùng làm icon thu hoạch) |
| `Dwarfwheat.png` | Lúa mì lùn | Stable crop | |
| `Soybean.png` | Đậu nành | Stable crop | |
| `CherryTomato.png` | Cà chua bi | Fresh produce | Chùm quả trên cành |
| `ChilePepers.png` | Ớt | Fresh produce | Quả ớt xanh |
| `Strawberry.png` | Dâu tây | Fresh produce | **Là giỏ dâu** → chỉ dùng làm icon thu hoạch |
| `MizunaMustard.png` | Cải mizuna | Leafy greens | |
| `Red Romaine lettuce.png` | Xà lách romaine | Leafy greens | |
| `Basil.png` | Húng quế | Herb | |
| `Dill.png` | Thì là | Herb | |
| `Gemini_Generated_Image_...png` | — | — | **Cây non** → dùng làm sprite giai đoạn 1 |
| `Chile pepers.png` | — | — | Trùng lặp: là card "CHERRY TOMATOES" có chữ → **không dùng** |

### 1.2 Thiết bị / vật phẩm (320×160, đã có alpha)

| File | Vai trò trong game |
|---|---|
| `Oxygenconcentrator.png` | Máy tạo oxy (O₂) |
| `Fuelcontainer.png` | Bồn/bình nhiên liệu |
| `Sinh_sComputer.png` | Máy tính điều khiển (shop + bảng thông số) |
| `bag.png` (64×64) | Icon túi đồ / inventory |

### 1.3 Background

| File | Dùng cho |
|---|---|
| `bgorgi.png` (1046×512) | Nền phòng nhà kính (chất lượng cao nhất) |
| `backgroundfix.png`, `Backgroundwno.png` (320×160) | Nền dự phòng / preview |

### 1.4 Việc phải làm trước khi code (asset prep)

1. **Cắt nền trắng** của 10 ảnh cây: nền là trắng đục (alpha = 255),
   cần chuyển thành trong suốt (threshold trắng + giữ viền tối).
2. **Trim** về bounding box của cây, rồi resize về 128–256 px.
3. Tách `Strawberry.png` (giỏ) và `Potato.png` (củ) thành **icon item**,
   không dùng làm cây đang trồng.
4. Chuẩn hoá pivot: gốc cây ở **đáy giữa** (để đặt lên luống).
5. Đổi tên file theo id code: `plant_potato.png`, `plant_cherry_tomato.png`…

> Có thể viết 1 script Python (Pillow) chạy 1 lần để làm bước 1–2 cho cả 10 ảnh.

---

## 2. Kiến trúc code

### 2.1 Cấu trúc thư mục

```
res://
├─ assets/
│  ├─ plants/        # sprite cây đã cắt nền (id_like_file.png)
│  ├─ items/         # icon item (củ khoai, giỏ dâu, hạt giống…)
│  ├─ objects/       # oxygen, fuel, computer, bag
│  └─ bg/            # bgorgi.png
├─ data/
│  ├─ plants/        # 9 file .tres (PlantData)
│  └─ items/         # .tres (ItemData) cho hạt giống / nông sản
├─ scenes/
│  ├─ greenhouse/Greenhouse.tscn
│  ├─ objects/Plant.tscn, GrowBed.tscn, OxygenConcentrator.tscn,
│  │           FuelTank.tscn, Computer.tscn, ItemPickup.tscn
│  └─ ui/HUD.tscn, InventoryPanel.tscn, BedPanel.tscn, ShopPanel.tscn
└─ scripts/
   ├─ autoload/GameClock.gd, GameState.gd, ItemDB.gd, SaveSystem.gd
   ├─ data/PlantData.gd, ItemData.gd
   ├─ systems/GrowthSystem.gd, InteractionSystem.gd
   └─ entities/Plant.gd, GrowBed.gd, Machine.gd, Player.gd
```

### 2.2 Autoload (thay `Global.gd` hiện tại bằng bộ mới, giữ API cũ)

| Autoload | Trách nhiệm |
|---|---|
| `GameClock` | Thời gian game: `delta` cộng dồn, `day`, tạm dừng khi mở menu |
| `GameState` | Tài nguyên: `water`, `power`, `oxygen`, `fuel`, `credits`; HP/food của player |
| `ItemDB` | Load toàn bộ `.tres` trong `data/`, tra cứu theo id |
| `SaveSystem` | Ghi/đọc `user://save.cfg`, có `version` để migrate |

`Global.gd` hiện tại chỉ lưu hp/food/position → chuyển logic sang `GameState`
và để `Global` làm wrapper mỏng (tránh sửa toàn bộ code cũ).

### 2.3 Cây scene

```
Greenhouse (Node2D)
├─ Background (Sprite2D)
├─ GrowBeds (Node2D)        # 6–8 GrowBed
├─ Machines (Node2D)        # Oxygen, Fuel, Computer
├─ Player (CharacterBody2D) # tái sử dụng player.gd
├─ Camera2D
└─ HUD (CanvasLayer)        # HP, Food, O₂, Water, Power
```

---

## 3. Data model

### 3.1 `PlantData` (Resource)

```gdscript
class_name PlantData extends Resource

@export var id: StringName
@export var display_name: String
@export var category: StringName      # stable / fresh / leafy / herb
@export var icon: Texture2D           # item thu hoạch
@export var sprite_mature: Texture2D
@export var sprite_sprout: Texture2D  # dùng ảnh Gemini
@export var grow_time: float = 120.0  # giây
@export var stage_thresholds := [0.0, 0.25, 0.6, 1.0]
@export var water_need: float = 30.0  # tổng nước cho 1 vụ
@export var light_need: float = 0.8   # 0..1, dưới ngưỡng thì chậm
@export var yield_min: int = 3
@export var yield_max: int = 5
@export var food_value: float = 15.0  # hồi Food khi ăn
@export var hp_value: float = 3.0
@export var oxygen_rate: float = 0.5  # O₂/giây khi trưởng thành
@export var seed_cost: int = 10
```

9 file `.tres` trong `data/plants/`, designer chỉnh được trong Inspector.

### 3.2 Bảng cân bằng đề xuất

| Cây | Nhóm | Lớn (s) | Nước | Sản lượng | Food | HP | O₂/s | Giá hạt |
|---|---|---|---|---|---|---|---|---|
| Potato | stable | 180 | 40 | 4 | 28 | 4 | 0.5 | 20 |
| Dwarf wheat | stable | 200 | 35 | 5 | 22 | 3 | 0.6 | 18 |
| Soybean | stable | 170 | 35 | 4 | 24 | 5 | 0.8 | 18 |
| Cherry tomato | fresh | 130 | 30 | 6 | 14 | 4 | 0.4 | 12 |
| Chile pepper | fresh | 140 | 28 | 5 | 12 | 6 | 0.3 | 14 |
| Strawberry | fresh | 120 | 30 | 5 | 16 | 5 | 0.4 | 14 |
| Mizuna mustard | leafy | 90 | 25 | 4 | 12 | 3 | 0.7 | 8 |
| Red romaine | leafy | 95 | 25 | 4 | 13 | 3 | 0.7 | 8 |
| Basil | herb | 80 | 20 | 3 | 8 | 4 | 0.5 | 6 |
| Dill | herb | 85 | 20 | 3 | 9 | 4 | 0.5 | 6 |

Chu kỳ 80–200 s khớp với thanh Food hiện tại (đầy → cạn ~120 s),
nên mỗi lần đói là vừa kịp thu hoạch 1 vụ.

---

## 4. Logic từng đối tượng

### 4.1 `Plant` (state machine)

```
IDLE → PLANTED → GROWING → MATURE → (HARVESTED → IDLE)
                     ↘ WITHERED (hết nước quá lâu)
```

- `stage`: 0 Seed, 1 Sprout, 2 Growing, 3 Mature.
- Mỗi tick (0.25 s): `progress += delta * speed_factor`.
  - `speed_factor = clamp(light, 0, 1) * water_factor`.
  - `water_factor = 1.0` nếu nước > 0, `0.0` nếu hết (cây ngừng lớn).
- Đổi stage → đổi sprite + scale nhỏ→lớn (tween 0.3 s).
- Khi `MATURE`: bật hiệu ứng nhấp nháy nhẹ + icon "!" để người chơi biết thu hoạch.
- Hết nước liên tục > 60 s ở stage ≥ 2 → `WITHERED` (phải nhổ bỏ).

### 4.2 `GrowBed`

- Có 1 slot `Plant` và 1 thanh `water_level` (0–100).
- `plant(seed_id)`, `water(amount)`, `harvest()`, `clear()`.
- `water_level` giảm `0.35/s` (một lần tưới đủ ~4–5 phút).
- Tương tác bằng `Area2D` + nút **E** khi player đứng gần.
- 3 trạng thái hiển thị: trống (đất), có cây, cây chín.

### 4.3 `GrowthSystem`

- Giữ danh sách `GrowBed` (group `grow_beds`).
- Tick tập trung 4 lần/giây thay vì mỗi cây tự `_process` (dễ save/load, dễ pause).
- Phát signal: `plant_stage_changed`, `plant_matured`, `plant_withered`.

### 4.4 Tài nguyên (`GameState`)

| Tài nguyên | Nguồn | Tiêu hao |
|---|---|---|
| `water` | Mua ở Computer, thu từ máy lọc (stretch goal) | Tưới cây |
| `power` | Pin mặt trời (tự hồi 1.5/s) | Đèn lớn, máy tạo O₂ |
| `oxygen` | Cây trưởng thành + Oxygen Concentrator | Player thở (tùy chọn) |
| `fuel` | Chế biến biomass ở Computer | Điểm số / mở khóa |
| `credits` | Bán nông sản | Mua hạt, nước, nâng cấp |

### 4.5 Máy móc (`Machine` base class)

```
Machine (Node2D)
├─ oxygen_concentrator: power 2/s + biomass → oxygen +1.5/s
├─ fuel_tank:          chứa fuel, hiển thị mức đầy
└─ computer:           mở ShopPanel / StatsPanel / ResearchPanel
```

- Máy chạy tự động khi tài nguyên đủ; có đèn xanh/đỏ + text trạng thái.
- Tương tác E → mở panel tương ứng.

### 4.6 Túi đồ (`bag.png` + `InventoryPanel`)

- Grid 6×4, mỗi ô 1 `ItemStack { id, count }`.
- Loại item: `seed`, `produce`, `water`, `fuel`.
- Kéo–thả để dùng (hạt → luống, nông sản → ăn/bán).
- Tooltip: tên + thông số (Food/HP/O₂).

### 4.7 Tương tác (`InteractionSystem`)

- Player có `Area2D` dò `Interactable` gần nhất; hiện prompt "[E] Trồng / Tưới / Thu hoạch".
- **Xung đột hiện tại:** phím `E` đang là "ăn". Đề xuất:
  - `E` = tương tác (ưu tiên),
  - `Q` = ăn nông sản đang chọn,
  - `H` = tự gây damage (giữ để test).

### 4.8 HUD

- Giữ `HPBar`, `FoodBar` hiện tại.
- Thêm `OxygenBar`, `WaterBar`, `PowerBar` (cùng style `StyleBoxFlat`, màu khác).
- Góc phải: `credits`, đồng hồ ngày.
- Thông báo ngắn (toast) khi thu hoạch / hết nước.

### 4.9 Save/Load (mở rộng `SaveSystem`)

```ini
[save]
version=1
credits=120
water=80.0
power=100.0

[beds]
count=6
bed_0={"plant_id":"potato","progress":42.5,"water":63.0,"stage":2,"planted_at":1731...}
```

- Lưu `planted_at` (unix time) để tính **lớn offline** khi mở lại game
  (tùy chọn bật/tắt trong settings).
- Không lưu cây đã chết.

---

## 5. Vòng chơi hoàn chỉnh

1. Vào nhà kính → thấy 6 luống trống, HUD hiện Water/Power.
2. Đến Computer → mua hạt (credits ban đầu 100).
3. Đến luống → E → chọn hạt → trồng.
4. E lần nữa để tưới (tiêu water).
5. Chờ 80–200 s, cây lớn qua 4 giai đoạn (có animation scale).
6. Cây chín → E để thu hoạch → item vào túi.
7. Ăn (Q) để hồi Food/HP, hoặc bán ở Computer lấy credits.
8. Mua thêm hạt/nước/nâng cấp → vòng lặp tiếp.

Chỉ số phụ (O₂, fuel) tạo mục tiêu dài hạn: đạt O₂ ≥ X và fuel ≥ Y để "hoàn thành nhiệm vụ".

---

## 6. Lộ trình triển khai

| Mốc | Nội dung | Tiêu chí xong |
|---|---|---|
| **M0** | Asset prep: cắt nền trắng 10 cây, trim, đổi tên, import vào Godot | Tất cả sprite hiển thị đúng, không còn viền trắng |
| **M1** | `PlantData`, `ItemDB`, `Plant`, `GrowBed`, 1 loài (Potato) | Trồng → lớn 4 stage → thu hoạch được, có log |
| **M2** | `GrowthSystem`, đủ 9 loài, save/load luống | Tắt/mở game vẫn giữ tiến độ |
| **M3** | `GameState` (water/power/oxygen/fuel/credits) + HUD mở rộng | Thanh tài nguyên chạy đúng, tưới tiêu hao nước |
| **M4** | Máy: Oxygen, Fuel, Computer (shop) | Mua hạt, bán nông sản, O₂ tăng theo cây |
| **M5** | Inventory + túi đồ + ăn (Q) | Nhặt/thả item, ăn hồi Food/HP |
| **M6** | Cân bằng số liệu, toast, hiệu ứng, build thử | Chơi 10 phút không lỗi, repo sạch |

Ước lượng: M0 0.5 ngày · M1 1 ngày · M2 0.5 · M3 0.5 · M4 1 · M5 1 · M6 0.5.

---

## 7. Rủi ro & câu hỏi mở

**Rủi ro**
- Ảnh cây chỉ có 1 frame → phải giả lập stage bằng scale/độ đậm; nếu cần đẹp hơn phải vẽ thêm sprite.
- Tên file lệch nội dung (`Chile pepers.png` là cà chua, `Strawberry.png` là giỏ) → dễ map sai.
- `E` đang là phím ăn → phải đổi keybind, tránh người chơi bấm nhầm.

**Cần chốt**
1. Nhà kính là **scene mới** trong cùng game (từ Menu) hay thay thế `game.tscn`?
2. O₂ có phải **cơ chế sống còn** (thanh thứ 3, hết là chết) hay chỉ là tài nguyên/điểm?
3. Có **shop/kinh tế** (credits, mua hạt) hay chỉ cần hạt vô hạn cho đơn giản?
4. Cây có **lớn khi tắt game** (offline growth) không?
5. Có cần nhiều luống + nâng cấp (mở khóa cây) hay chỉ 1 luống demo?

→ Đã chốt cả 5: scene mới mở từ Menu · O₂ là cơ chế sống còn · có shop/credits ·
có lớn offline · 6 luống, 9 loài cây.

---

## 8. Trạng thái triển khai (bản đang chạy)

### 8.1 File thực tế

| File | Vai trò |
|---|---|
| `greenhouse.tscn` + `greenhouse.gd` | Scene nhà kính, dựng toàn bộ thế giới bằng code |
| `Global.gd` (autoload) | HP/Food/O₂/nước/power/fuel/credits, túi đồ, 6 luống, save v2, lớn offline |
| `GameData.gd` | Bảng 9 loài cây + item (thay cho `.tres`) |
| `GrowBed.gd` | Một luống: sprite cây 4 giai đoạn, thanh nước, nhãn trạng thái |
| `Machine.gd` | Máy tính (shop), máy tạo O₂, bồn nhiên liệu |
| `HUD.gd` | 3 thanh HP/Food/O₂, credits, nước/power/fuel, prompt, toast |
| `UI.gd` | Panel shop, túi đồ, chọn hạt |
| `player.gd` | Di chuyển, đói, chết (hiệu ứng tan biến "Y O U   D I E"), hồi sinh |
| `assets/` | Sprite đã cắt nền trắng, trim, chuẩn hoá kích thước |

### 8.2 Điều khiển

- `WASD` / phím mũi tên: di chuyển
- `E`: tương tác (trồng / tưới / thu hoạch / dùng máy)
- `TAB`: túi đồ
- `Q`: ăn nông sản tốt nhất trong túi
- `ESC`: đóng panel

### 8.3 Số liệu cân bằng đang dùng

- Thở: −1.0 O₂/s · Máy tạo O₂: +0.55 O₂/s, tốn 0.7 power/s · Pin mặt trời: +1.2 power/s
- Hết O₂: −5 HP/s. Cây trưởng thành nhả 0.35–0.8 O₂/s mỗi cây.
- Nước trong luống cạn dần trong ~1.35× thời gian lớn; khô 45 s → cây chết, phải nhổ.
- Lớn offline: mô phỏng lại theo `saved_at`, tối đa 1 giờ.

