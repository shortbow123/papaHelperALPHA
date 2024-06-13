extends Button

var originalCoords = Vector2(0, 0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	originalCoords = self.rect_position

# Called when the node enters the scene tree for the first time.
func _process(delta):#():
	if (not self.get_class() == "Panel") and (not self.get_class() == "WindowDialog"):
		pass
		#resize()

func resize():
	#while true:
	self.rect_scale = get_viewport().size / Vector2(720, 1280)
	self.rect_position = originalCoords + (originalCoords / get_viewport().size)
	#self.rect_position = originalCoords + (originalCoords / get_viewport().size)
		#self.size = get_viewport().size * .8

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
