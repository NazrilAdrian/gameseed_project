extends Area2D

# Ubah baris ini:
@export_file("*.tscn") var next_scene_path: String

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang menyentuh portal adalah pemain (Player)
	# Anda bisa menggunakan Group atau mengecek nama node
	if body.is_in_group("Player"):
		if next_scene_path != "":
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Error: Jalur scene tujuan belum diisi di Inspector!")
