extends MarginContainer
@onready var DayNo=preload("res://scenes/dayno.tscn")
@onready var calender = preload("res://scenes/calender.tres")
@onready var calender_selected = preload("res://scenes/calender_selected.tres")

@onready var grid = $PanelContainer/VBoxContainer/GridContainer
@export var update:bool=false

signal on_select(date:Datetime)

var dns = []
var current:Datetime

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 42:
		var dn = DayNo.instantiate()
		dns.append(dn)
		grid.add_child(dn)
		dn.connect('on_click',Callable(self,'_on_dn_click'))
	init_calender(Datetime.now())

func _on_dn_click(date:Datetime):
	init_calender(date)
	on_select.emit(date)
	
func init_calender(date:Datetime):
	self.current=date
	var first_on_month = self.current.get_firstday_of_month()
	var firstline_end_index = first_on_month.weekday
	var tempDate = first_on_month.add_days(-1)
	if firstline_end_index!=Time.WEEKDAY_SUNDAY:
		for i in range(firstline_end_index-1,-1,-1):
			set_calender_item(i,tempDate,'other')
			tempDate = tempDate.add_days(-1)
			
	tempDate = first_on_month
	var index = firstline_end_index
	for i in range(0,tempDate.get_month_days()):
		index = firstline_end_index+i
		set_calender_item(index,tempDate,'current')
		tempDate = tempDate.add_days(1)
	
	index+=1
	
	for i in range(index,dns.size()):
		set_calender_item(i,tempDate,'other')
		tempDate = tempDate.add_days(1)
		
	check_current()
	change_title()
	
	
func change_title():
	$PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Year.text='%d年'%self.current.year
	$PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Month.text='%02d月'%self.current.month
	

func set_calender_item(i:int,date:Datetime,tag:String):
	dns[i].set_day(date)
	dns[i].set_font_style(tag)
	dns[i].set_panelstyle(calender)
	
	
func check_current():
	var i:int
	#本月第一天的索引+当日为本月第几天-1
	i=self.current.get_firstday_of_month().weekday+self.current.day-1
	var now_dn = dns[i]
	now_dn.set_panelstyle(calender_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_last_mon_pressed():
	self.current = self.current.get_firstday_of_month().add_days(-1).get_firstday_of_month()
	init_calender(self.current)


func _on_next_mon_pressed():
	self.current = self.current.get_lastday_of_month().add_days(1)
	init_calender(self.current)
