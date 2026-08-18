@tool
class_name CountInput
extends Panel


signal value_changed(new_value: int)

@onready var _line_edit: LineEdit = %LineEdit

@export var value: int = 4:
	set(v):
		if value <= 0:
			value = 1
		if value == v:
			return
		value = v
		_line_edit.text = str(v)
		value_changed.emit(v)

var regex = RegEx.new()
var old_text = ""

func _ready():
	regex.compile("^[0-9]*$")
	_line_edit.text_changed.connect(_on_text_changed)
	%Up.pressed.connect(_increment.bind(1))
	%Down.pressed.connect(_increment.bind(-1))


func _increment(by: int):
	value += by


func _on_text_changed(new_text: String):
	if regex.search(new_text):
		old_text = new_text
	else:
		# Keep track of the cursor position before changing the text
		var cursor_pos = _line_edit.caret_column
		_line_edit.text = old_text
		# Restore the cursor position (minus 1 to account for the deleted invalid character)
		_line_edit.caret_column = cursor_pos - 1
	
	value = int(new_text)