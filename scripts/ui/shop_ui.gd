extends CanvasLayer

## Path folder yang berisi file .tres WeaponData
@export var weapons_folder: String = "res://assets/data/weapons/"

## Referensi ke scene ShopItemSlot yang di-instance per weapon
@export var item_slot_scene: PackedScene

@onready var item_list:       VBoxContainer = $Panel/VBox/HSplit/Left/Scroll/ItemList
@onready var detail_name:     Label         = $Panel/VBox/HSplit/Right/Detail/NameLabel
@onready var detail_damage:   Label         = $Panel/VBox/HSplit/Right/Detail/DamageLabel
@onready var detail_price:    Label         = $Panel/VBox/HSplit/Right/Detail/PriceLabel
@onready var detail_icon:     TextureRect   = $Panel/VBox/HSplit/Right/Detail/Icon
@onready var detail_hint:     Label         = $Panel/VBox/HSplit/Right/Detail/HintLabel
@onready var close_button:    Button        = $Panel/VBox/Header/CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	_load_weapons()

func _load_weapons() -> void:
	# Bersihkan dulu slot lama (kalau ada)
	for child in item_list.get_children():
		child.queue_free()

	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(weapons_folder)):
		detail_hint.text = "Folder senjata tidak ditemukan:\n%s" % weapons_folder
		return

	var dir := DirAccess.open(weapons_folder)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path := weapons_folder.path_join(file_name)
			var data := load(path) as WeaponData
			if data != null:
				_add_slot(data)
		file_name = dir.get_next()
	dir.list_dir_end()

	if item_list.get_child_count() == 0:
		detail_hint.text = "Belum ada data senjata.\nTambahkan file .tres WeaponData ke:\n%s" % weapons_folder

func _add_slot(data: WeaponData) -> void:
	if item_slot_scene == null:
		push_error("ShopUI: item_slot_scene belum diset di Inspector!")
		return
	var slot: ShopItemSlot = item_slot_scene.instantiate()
	item_list.add_child(slot)
	slot.setup(data)
	slot.slot_selected.connect(_on_slot_selected)

func _on_slot_selected(weapon: WeaponData) -> void:
	detail_name.text   = weapon.weapon_name
	detail_damage.text = "ATK : %d" % weapon.damage
	detail_price.text  = "Harga : %d G" % weapon.price
	detail_hint.text   = "Klik untuk membeli (belum diimplementasi)"
	if weapon.weapon_icon:
		detail_icon.texture = weapon.weapon_icon
	else:
		detail_icon.texture = null

func _on_close_pressed() -> void:
	# Delegasikan ke toko.gd lewat SceneTree pause
	get_tree().paused = false
	visible = false
