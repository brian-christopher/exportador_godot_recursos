extends Node


const grh_data = []
var bodies_data = {}
var heads_data = {}
var helmets_data = {}
var weapons_data = {}
var shields_data = {}
var fxs_data = {}

const nombre_animacion = ["idle_left", "idle_up", "idle_down", "idle_right", "walk_left", "walk_up", "walk_down", "walk_right"]

func _ready() -> void:
	_load_grh_data()
	
	fxs_data = load_json_from_file("res://json/fxs_data.json") 
	bodies_data  = load_json_from_file("res://json/bodies_data.json")
	helmets_data = load_json_from_file("res://json/helmets_data.json")
	heads_data   = load_json_from_file("res://json/heads_data.json")
	weapons_data = load_json_from_file("res://json/weapons_data.json")
	shields_data = load_json_from_file("res://json/shields_data.json") 
	fxs_data 	 = load_json_from_file("res://json/fxs_data.json")
	
	
	var resource = preload("res://resources/shields/shield_4.tres")
	var animation = resource.animation
	
	$AnimatedSprite.frames = animation
	$AnimatedSprite.play("walk_down")
	
	
class GrhData:
	var region = Rect2()
	var file_num  = 0
	var num_frames = 0
	var frames = []
	var speed = 0.0
	
func load_json_from_file(filename:String):
	var file = File.new()
	file.open(filename, file.READ)
	
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	
	file.close()
	return json_result

func _load_grh_data():
	var file = File.new()
	file.open("res://json/graficos.ind", File.READ)
	
	var content = file.get_buffer(file.get_len())
	var buffer = StreamPeerBuffer.new()
	
	buffer.data_array = content
	
	var size = buffer.get_32()
	
	var _grh_count = buffer.get_32()
	grh_data.resize(_grh_count + 1)
	grh_data.fill(GrhData.new())
	
	while(buffer.get_position() < buffer.get_size()):
		var grh_id = buffer.get_32()
		var grh = GrhData.new()
		
		
		grh.num_frames = buffer.get_16()
		grh.frames = []
		for _i in range(grh.num_frames + 1):
			grh.frames.append(0)
		
		if grh.num_frames > 1:
			for i in range(1, grh.num_frames + 1):
				grh.frames[i] = buffer.get_32()
			
			grh.speed  = buffer.get_float()
			grh.region = grh_data[grh.frames[1]].region
		else:
			grh.file_num = buffer.get_32()
			grh.frames[1] = grh_id
			
			grh.region = Rect2(0, 0, 0, 0)
			grh.region.position.x = buffer.get_16()
			grh.region.position.y = buffer.get_16()
			
			grh.region.size.x = buffer.get_16()
			grh.region.size.y = buffer.get_16()
	
		grh_data[grh_id] = grh    


func _on_Fxs_pressed() -> void:
	for i in range(1, fxs_data.size()):
		var fx_data = FxData.new()
		var spriteFrame = SpriteFrames.new()
		spriteFrame.set_animation_speed("default", 18)
		spriteFrame.set_animation_loop("default", false)
		
		var frames = grh_data[fxs_data[i].id].frames
		for frame in range(1, frames.size()):
			var region =  grh_data[frames[frame]].region
			var texture = load("res://assets/graphics/%d.png" % grh_data[frames[frame]].file_num)
			
			if region != Rect2(0, 0, 128, 128):
				var atlas_texture = AtlasTexture.new()
				atlas_texture.atlas = texture
				atlas_texture.region = region
				spriteFrame.add_frame("default", atlas_texture)
			else:
				spriteFrame.add_frame("default", texture)
		
		fx_data.sprite_frames = spriteFrame
		fx_data.offset_x = fxs_data[i].offsetX
		fx_data.offset_y = fxs_data[i].offsetY
		ResourceSaver.save("res://out/fxs/effect_%d.tres" % i, fx_data)

 
func _on_Cuerpos_pressed() -> void:
	for i in range(1, bodies_data.size()):
		var data = bodies_data[i]
		
		var left_frames = grh_data[data.left].frames 
		var right_frames = grh_data[data.right].frames 
		var up_frames = grh_data[data.up].frames
		var down_frames = grh_data[data.down].frames
		
		if left_frames.size() == 0 or down_frames.size() == 0 or up_frames.size() == 0 or  right_frames.size() == 0:
			continue
		
		var spriteFrame = SpriteFrames.new()
		spriteFrame.remove_animation("default")
		
		for nombre in nombre_animacion:
			spriteFrame.add_animation(nombre)
			spriteFrame.set_animation_speed(nombre, 12)
			spriteFrame.set_animation_loop(nombre, true)
		
		var left_texture = AtlasTexture.new()
		left_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[1]].file_num)
		left_texture.region = grh_data[left_frames[1]].region
		spriteFrame.add_frame("idle_left", left_texture) 
		
		var right_texture = AtlasTexture.new()
		right_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[1]].file_num)
		right_texture.region = grh_data[right_frames[1]].region
		spriteFrame.add_frame("idle_right", right_texture) 
		
		var up_texture = AtlasTexture.new()
		up_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[1]].file_num)
		up_texture.region = grh_data[up_frames[1]].region
		spriteFrame.add_frame("idle_up", up_texture) 
		
		var down_texture = AtlasTexture.new()
		down_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[1]].file_num)
		down_texture.region = grh_data[down_frames[1]].region
		spriteFrame.add_frame("idle_down", down_texture) 
		
		for f in range(1, left_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[f]].file_num)
			texture.region = grh_data[left_frames[f]].region
			spriteFrame.add_frame("walk_left", texture) 
		
		for f in range(1, right_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[f]].file_num)
			texture.region = grh_data[right_frames[f]].region
			spriteFrame.add_frame("walk_right", texture) 
		
		for f in range(1, up_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[f]].file_num)
			texture.region = grh_data[up_frames[f]].region
			spriteFrame.add_frame("walk_up", texture) 
			
		for f in range(1, down_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[f]].file_num)
			texture.region = grh_data[down_frames[f]].region
			spriteFrame.add_frame("walk_down", texture) 
		
		
		var data_resource = AnimationData.new()
		data_resource.head_offset_x = data.offsetX
		data_resource.head_offset_y = data.offsetY
		data_resource.animation = spriteFrame
		ResourceSaver.save("res://resources/bodies/bodie_%d.tres" % i, data_resource)


func _on_cabezas_pressed() -> void:
	for i in range(1, heads_data.size()):
		var data = heads_data[i]
		
		var left_frames = grh_data[data.left].frames 
		var right_frames = grh_data[data.right].frames 
		var up_frames = grh_data[data.up].frames
		var down_frames = grh_data[data.down].frames
		
		if left_frames.size() == 0 or down_frames.size() == 0 or up_frames.size() == 0 or  right_frames.size() == 0:
			continue
			
		var spriteFrame = SpriteFrames.new()
		spriteFrame.remove_animation("default")
		
		for nombre in nombre_animacion:
			nombre = nombre as String
			if nombre.find("walk") != -1:
				continue
			
			spriteFrame.add_animation(nombre)
			spriteFrame.set_animation_speed(nombre, 12)
			spriteFrame.set_animation_loop(nombre, true)

		var left_texture = AtlasTexture.new()
		left_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[1]].file_num)
		left_texture.region = grh_data[left_frames[1]].region
		spriteFrame.add_frame("idle_left", left_texture) 
		
		var right_texture = AtlasTexture.new()
		right_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[1]].file_num)
		right_texture.region = grh_data[right_frames[1]].region
		spriteFrame.add_frame("idle_right", right_texture) 
		
		var up_texture = AtlasTexture.new()
		up_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[1]].file_num)
		up_texture.region = grh_data[up_frames[1]].region
		spriteFrame.add_frame("idle_up", up_texture) 
		
		var down_texture = AtlasTexture.new()
		down_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[1]].file_num)
		down_texture.region = grh_data[down_frames[1]].region
		spriteFrame.add_frame("idle_down", down_texture) 

		var data_resource = AnimationData.new() 
		data_resource.animation = spriteFrame
		ResourceSaver.save("res://resources/heads/head_%d.tres" % i, data_resource)


func _on_cascos_pressed() -> void:
	for i in range(1, helmets_data.size()):
		var data = helmets_data[i]
		
		var left_frames = grh_data[data.left].frames 
		var right_frames = grh_data[data.right].frames 
		var up_frames = grh_data[data.up].frames
		var down_frames = grh_data[data.down].frames
		
		if left_frames.size() == 0 or down_frames.size() == 0 or up_frames.size() == 0 or  right_frames.size() == 0:
			continue
			
		var spriteFrame = SpriteFrames.new()
		spriteFrame.remove_animation("default")
		
		for nombre in nombre_animacion:
			nombre = nombre as String
			if nombre.find("walk") != -1:
				continue
			
			spriteFrame.add_animation(nombre)
			spriteFrame.set_animation_speed(nombre, 12)
			spriteFrame.set_animation_loop(nombre, true)

		var left_texture = AtlasTexture.new()
		left_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[1]].file_num)
		left_texture.region = grh_data[left_frames[1]].region
		spriteFrame.add_frame("idle_left", left_texture) 
		
		var right_texture = AtlasTexture.new()
		right_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[1]].file_num)
		right_texture.region = grh_data[right_frames[1]].region
		spriteFrame.add_frame("idle_right", right_texture) 
		
		var up_texture = AtlasTexture.new()
		up_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[1]].file_num)
		up_texture.region = grh_data[up_frames[1]].region
		spriteFrame.add_frame("idle_up", up_texture) 
		
		var down_texture = AtlasTexture.new()
		down_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[1]].file_num)
		down_texture.region = grh_data[down_frames[1]].region
		spriteFrame.add_frame("idle_down", down_texture) 

		var data_resource = AnimationData.new() 
		data_resource.animation = spriteFrame
		ResourceSaver.save("res://resources/helmets/helmet_%d.tres" % i, data_resource)




func _on_armas_pressed() -> void:
	for i in range(1, weapons_data.size()):
		var data = weapons_data[i]
		
		var left_frames = grh_data[data.left].frames 
		var right_frames = grh_data[data.right].frames 
		var up_frames = grh_data[data.up].frames
		var down_frames = grh_data[data.down].frames
		
		if left_frames.size() == 0 or down_frames.size() == 0 or up_frames.size() == 0 or  right_frames.size() == 0:
			continue
		
		var spriteFrame = SpriteFrames.new()
		spriteFrame.remove_animation("default")
		
		for nombre in nombre_animacion:
			spriteFrame.add_animation(nombre)
			spriteFrame.set_animation_speed(nombre, 12)
			spriteFrame.set_animation_loop(nombre, true)
		
		var left_texture = AtlasTexture.new()
		left_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[1]].file_num)
		left_texture.region = grh_data[left_frames[1]].region
		spriteFrame.add_frame("idle_left", left_texture) 
		
		var right_texture = AtlasTexture.new()
		right_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[1]].file_num)
		right_texture.region = grh_data[right_frames[1]].region
		spriteFrame.add_frame("idle_right", right_texture) 
		
		var up_texture = AtlasTexture.new()
		up_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[1]].file_num)
		up_texture.region = grh_data[up_frames[1]].region
		spriteFrame.add_frame("idle_up", up_texture) 
		
		var down_texture = AtlasTexture.new()
		down_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[1]].file_num)
		down_texture.region = grh_data[down_frames[1]].region
		spriteFrame.add_frame("idle_down", down_texture) 
		
		for f in range(1, left_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[f]].file_num)
			texture.region = grh_data[left_frames[f]].region
			spriteFrame.add_frame("walk_left", texture) 
		
		for f in range(1, right_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[f]].file_num)
			texture.region = grh_data[right_frames[f]].region
			spriteFrame.add_frame("walk_right", texture) 
		
		for f in range(1, up_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[f]].file_num)
			texture.region = grh_data[up_frames[f]].region
			spriteFrame.add_frame("walk_up", texture) 
			
		for f in range(1, down_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[f]].file_num)
			texture.region = grh_data[down_frames[f]].region
			spriteFrame.add_frame("walk_down", texture) 
		
		
		var data_resource = AnimationData.new() 
		data_resource.animation = spriteFrame
		ResourceSaver.save("res://resources/weapons/weapon_%d.tres" % i, data_resource)


func _on_escudos_pressed() -> void:
	for i in range(1, shields_data.size()):
		var data = shields_data[i]
		
		var left_frames = grh_data[data.left].frames 
		var right_frames = grh_data[data.right].frames 
		var up_frames = grh_data[data.up].frames
		var down_frames = grh_data[data.down].frames
		
		if left_frames.size() == 0 or down_frames.size() == 0 or up_frames.size() == 0 or  right_frames.size() == 0:
			continue
		
		var spriteFrame = SpriteFrames.new()
		spriteFrame.remove_animation("default")
		
		for nombre in nombre_animacion:
			spriteFrame.add_animation(nombre)
			spriteFrame.set_animation_speed(nombre, 12)
			spriteFrame.set_animation_loop(nombre, true)
		
		var left_texture = AtlasTexture.new()
		left_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[1]].file_num)
		left_texture.region = grh_data[left_frames[1]].region
		spriteFrame.add_frame("idle_left", left_texture) 
		
		var right_texture = AtlasTexture.new()
		right_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[1]].file_num)
		right_texture.region = grh_data[right_frames[1]].region
		spriteFrame.add_frame("idle_right", right_texture) 
		
		var up_texture = AtlasTexture.new()
		up_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[1]].file_num)
		up_texture.region = grh_data[up_frames[1]].region
		spriteFrame.add_frame("idle_up", up_texture) 
		
		var down_texture = AtlasTexture.new()
		down_texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[1]].file_num)
		down_texture.region = grh_data[down_frames[1]].region
		spriteFrame.add_frame("idle_down", down_texture) 
		
		for f in range(1, left_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[left_frames[f]].file_num)
			texture.region = grh_data[left_frames[f]].region
			spriteFrame.add_frame("walk_left", texture) 
		
		for f in range(1, right_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[right_frames[f]].file_num)
			texture.region = grh_data[right_frames[f]].region
			spriteFrame.add_frame("walk_right", texture) 
		
		for f in range(1, up_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[up_frames[f]].file_num)
			texture.region = grh_data[up_frames[f]].region
			spriteFrame.add_frame("walk_up", texture) 
			
		for f in range(1, down_frames.size()):
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/graphics/%d.png" % grh_data[down_frames[f]].file_num)
			texture.region = grh_data[down_frames[f]].region
			spriteFrame.add_frame("walk_down", texture) 
		
		
		var data_resource = AnimationData.new() 
		data_resource.animation = spriteFrame
		ResourceSaver.save("res://resources/shields/shield_%d.tres" % i, data_resource)

