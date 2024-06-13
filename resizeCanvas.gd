extends CanvasLayer



func _ready():
	pass
	#originalCoords = self.rect_position

# Called when the node enters the scene tree for the first time.
func _process(delta):#():
	resize()
	#if (not self.get_class() == "Panel") and (not self.get_class() == "WindowDialog"):
	#	pass
		#resize()

func resize():
	#while true:
	self.scale = get_viewport().size / Vector2(720, 1280)
	#self.rect_position = originalCoords + (originalCoords / get_viewport().size)
	#self.rect_position = originalCoords + (originalCoords / get_viewport().size)
		#self.size = get_viewport().size * .8

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
