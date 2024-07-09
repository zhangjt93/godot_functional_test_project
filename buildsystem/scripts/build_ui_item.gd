extends TextureButton
class_name BuildItem

var id:int
signal item_selected(id:int)

func _init(id:int,texture:Texture2D):
	self.id=id
	self.texture_pressed=texture
	self.texture_normal=texture
	self.pressed.connect(Callable(self,"_on_pressed"))
	self.size=Vector2(50,50)
	self.focus_mode = Control.FOCUS_NONE
	
func _on_pressed():
	item_selected.emit(self.id)
	#self.release_focus()
