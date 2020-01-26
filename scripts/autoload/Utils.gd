extends Node
# autoloaded script


func irand(from, to):
	return randi() % (to - from) + from




func transparentationalisize_image(img):
	assert(img != null)

	var img_w = img.get_width()
	var img_h = img.get_height()

	print(img_w, img_h)

	var black = Color(0,0,0,1)
	var transparent = Color(0,0,0,0)

	img.lock()
	var count = 0
	for j in range(img_h):
		for i in range(img_w):
			if img.get_pixel(i, j) != Color(1,1,1,1):
				count += 1
				img.set_pixel(i, j, Color(0,0,0,0))
	img.unlock()

	print(count)

	return img
