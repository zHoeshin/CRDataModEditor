extends ColorPickerButton

func onChange(newcolor: Color):
	color.r8 = round(newcolor.r8 / 17.) * 17.
	color.g8 = round(newcolor.g8 / 17.) * 17.
	color.b8 = round(newcolor.b8 / 17.) * 17.
