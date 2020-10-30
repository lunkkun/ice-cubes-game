extends Control


signal back_to_menu_button_pressed


func _on_BackToMenuButton_pressed():
	emit_signal("back_to_menu_button_pressed")
