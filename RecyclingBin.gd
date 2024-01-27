extends Node2D

signal IDEClicked
signal FileClicked
signal SynthiaClicked
signal FileSystemClicked
signal openFile
signal trashed
var process = false
var current = null
var currentPos
var child = load("res://file.tscn")
onready var currentNodes = [$RecyclingBin,$FileSystem,$Virtualhell,$File]
var validPositions = [Vector2(0,0),Vector2(0,30),Vector2(0,60),Vector2(00,90),
					Vector2(30,0),Vector2(30,30),Vector2(30,60),Vector2(30,90),
					Vector2(60,0),Vector2(60,30),Vector2(60,60),Vector2(60,90),
					Vector2(90,0),Vector2(90,30),Vector2(90,60),Vector2(90,90),
					Vector2(120,0),Vector2(120,30),Vector2(120,60),Vector2(120,90),
					Vector2(150,0),Vector2(150,30),Vector2(150,60),Vector2(150,90),
					Vector2(180,0),Vector2(180,30),Vector2(180,60),Vector2(180,90),
					Vector2(210,0),Vector2(210,30),Vector2(210,60),Vector2(210,90),
					Vector2(240,0),Vector2(240,30),Vector2(240,60),Vector2(240,90),
					Vector2(270,0),Vector2(270,30),Vector2(270,60),Vector2(270,90)]

func _process(_delta):
	if process == true:
		if currentPos != null:
			if get_global_mouse_position().distance_to(currentPos) < 15:
				return
		currentPos = null
		current.position = Vector2(get_global_mouse_position().x-13,get_global_mouse_position().y-15)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_button_down(node):
	currentPos = get_global_mouse_position()
	get_tree().get_root().get_node_or_null("/root/world/Icons/"+node).z_index = 4
	current = get_tree().get_root().get_node_or_null("/root/world/Icons/"+node)
	process = true 
	
func _on_button_up(node):
	if currentPos == null:
		position_settling(get_tree().get_root().get_node_or_null("/root/world/Icons/"+node))
	else:
		if node == "IDE":
			emit_signal("IDEClicked")
		elif node == "Virtualhell":
			emit_signal("SynthiaClicked")
		elif node == "File":
			emit_signal("FileClicked")
		elif node == "FileSystem":
			emit_signal("FileSystemClicked")
		elif node == "RecyclingBin":
			pass
		else:
			emit_signal("openFile", node)
	get_tree().get_root().get_node_or_null("/root/world/Icons/"+node).z_index = 0
	process = false 
	current = null
	

func _on_RecyclingButton_button_down():
	currentPos = get_global_mouse_position()
	$RecyclingBin.z_index = 4
	current = $RecyclingBin
	process = true 


func _on_RecyclingButton_button_up():
	position_settling($RecyclingBin)
	$RecyclingBin.z_index = 0
	process = false 
	current = null


func new_file(nodeName):
	var newFile = child.instance()
	get_tree().get_root().get_node_or_null("/root/world/Icons/").add_child(newFile)
	newFile.name = nodeName
	newFile.position = get_global_mouse_position()
	currentNodes.append(newFile)
	position_settling(newFile)
	if nodeName.ends_with("jpg") or nodeName.ends_with("gif"):
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+nodeName+"/ImageFile").visible = true
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+nodeName+"/ImageFile").play(nodeName)
	elif nodeName.ends_with("txt") or nodeName.ends_with("rtf"):
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+nodeName+"/TextFile").visible = true
		get_tree().get_root().get_node_or_null("/root/world/Icons/"+nodeName+"/TextFile").text = UniversalFunctions.dialogueJson[nodeName+"Mini"]
	newFile.connect("button_down", self,"_on_button_down")
	newFile.connect("button_up", self,"_on_button_up")
	
	
	
func position_settling(node):
	node.position = Vector2(stepify(node.position.x,30),stepify(node.position.y,30))
	if node.position.y < 0:
		node.position.y = 0
	if node.position.x < 0:
		node.position.x = 0
	if node.position.y > 90:
		node.position.y = 90
	if node.position.x > 270:
		node.position.x = 270
	var counter = 0
	while counter < 3:
		counter = 0
		for i in currentNodes:
			if i.position == node.position:
				counter+=1
				if i == $RecyclingBin and node != $RecyclingBin:
					emit_signal("trashed", node.name)
		if counter == 2:
			if node.position != Vector2(270,90):
				node.position = validPositions[validPositions.find(node.position)+1]
			else:
				if $RecyclingBin.position != validPositions[0]:
					node.position = validPositions[0]
				else:
					node.position = validPositions[1]
		else:
			counter = 3



