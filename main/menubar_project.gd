extends MenuBar


func _on_project_index_pressed(index):
	match index:
		0: #new
			pass
		1: #open
			$"../..".openProject()
		2: #close
			$"../..".closeProject()
		3: #properties
			pass
		4: #exit
			$"../..".tryExit()
