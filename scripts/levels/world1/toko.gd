extends Area2D

# Kita buat signal agar sistem lain (misal UI) tahu kalau toko dibuka
signal shop_opened

@export var prompt_label_path: NodePath = ^"../LabelPrompt"
@export var shop_overlay_path: NodePath = ^"../../ShopOverlay"
@onready var tekan_f: Label = $"../TekanF"
@onready var shop_overlay: CanvasLayer = get_node_or_null(shop_overlay_path)

var can_interact: bool = false
var is_shop_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# "Tekan F" tersembunyi saat belum masuk area
	if tekan_f:
		tekan_f.hide()
	else:
		push_warning("Prompt label tidak ditemukan di path: %s" % [prompt_label_path])

	# Overlay toko default hidden
	if shop_overlay:
		shop_overlay.visible = false
	else:
		push_warning("Shop overlay tidak ditemukan di path: %s" % [shop_overlay_path])

func _process(_delta: float) -> void:
	if is_shop_open:
		# Sinkronisasi: kalau overlay ditutup lewat tombol ✕ di UI
		if shop_overlay and not shop_overlay.visible:
			is_shop_open = false
			get_tree().paused = false
			return

		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_cancel"):
			close_shop_logic()
		return

	# Buka toko hanya saat player ada di area trigger
	if can_interact and Input.is_action_just_pressed("interact"):
		open_shop_logic()


func open_shop_logic() -> void:
	if is_shop_open:
		return

	is_shop_open = true
	print("Logic: Membuka database senjata...")
	print("Logic: Menghentikan pergerakan player (Pause menu)...")
	shop_opened.emit() # Mengirim sinyal ke sistem UI Anda nanti
	get_tree().paused = true

	if shop_overlay:
		shop_overlay.visible = true

func close_shop_logic() -> void:
	if not is_shop_open:
		return

	is_shop_open = false
	get_tree().paused = false

	if shop_overlay:
		shop_overlay.visible = false

# --- BAGIAN TRIGGER ---
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = true
		if tekan_f and not is_shop_open:
			tekan_f.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = false
		if tekan_f:
			tekan_f.hide()
