extends PanelContainer
class_name ShopItemSlot

signal slot_selected(weapon: WeaponData)

@onready var icon_texture: TextureRect  = $HBox/Icon
@onready var name_label: Label          = $HBox/VBox/NameLabel
@onready var damage_label: Label        = $HBox/VBox/DamageLabel
@onready var price_label: Label         = $HBox/PriceLabel

var weapon: WeaponData = null

func setup(data: WeaponData) -> void:
	weapon = data
	name_label.text  = data.weapon_name
	damage_label.text = "ATK: %d" % data.damage
	price_label.text  = "%d G" % data.price
	if data.weapon_icon:
		icon_texture.texture = data.weapon_icon

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_selected.emit(weapon)
