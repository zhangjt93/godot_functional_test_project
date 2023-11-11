extends PanelContainer
var date:Datetime

var other_month=Color(0.2,0.2,0.2,0.5)
var current_month = Color(0,0,0,1)

signal on_click(date:Datetime)

func set_panelstyle(panelstyle):
	self.set('theme_override_styles/panel',panelstyle)
	
func set_font_style(tag:String):
	if tag=='other':
		$Label.set('theme_override_colors/font_color',other_month)
	else:
		$Label.set('theme_override_colors/font_color',current_month)
		
		
func set_day(date:Datetime):
	self.date=date
	$Label.text = str(date.day)
	


func _on_gui_input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			on_click.emit(self.date)
