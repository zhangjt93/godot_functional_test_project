extends RefCounted

class_name Datetime

const ONEDAYSECOND=86400
const DAYFORMAT = '%d-%02d-%02dT00:00:00'

var year:int
var month:int
var day:int
var weekday:int
var timestamp:int

func _init(year,month,day,weekday,timestamp):
	self.year = year
	self.month = month
	self.day = day
	self.weekday = weekday
	self.timestamp = timestamp

static func now()->Datetime:
	var nowtime=Time.get_date_dict_from_unix_time(int(Time.get_unix_time_from_system()))
	var timestamp = Time.get_unix_time_from_datetime_dict(nowtime)
	return Datetime.new(nowtime.year,nowtime.month,nowtime.day,nowtime.weekday,timestamp)
	
static func new_from_str(dt:String)->Datetime:
	var nowtime = Time.get_datetime_dict_from_datetime_string(dt,true)
	var timestamp = Time.get_unix_time_from_datetime_dict(nowtime)
	if timestamp==0:
		return null
	return Datetime.new(nowtime.year,nowtime.month,nowtime.day,nowtime.weekday,timestamp)
	
static func new_from_timestamp(timestamp:int)->Datetime:
	var nowtime = Time.get_date_dict_from_unix_time(timestamp)
	return Datetime.new(nowtime.year,nowtime.month,nowtime.day,nowtime.weekday,timestamp)

	
func delta_days(contrastDate:Datetime)->int:
	return (contrastDate.timestamp-self.timestamp)/ONEDAYSECOND

func is_before(contrastDate:Datetime)->bool:
	return self.timestamp-contrastDate.timestamp<0

func add_days(delta:int)->Datetime:
	var unix_time = self.timestamp +(delta * ONEDAYSECOND) 
	var return_date = Time.get_date_dict_from_unix_time(unix_time)
	return Datetime.new(return_date.year,return_date.month,return_date.day,return_date.weekday,unix_time)
	
	
func get_year()->int:
	return self.year
	
func get_month()->int:
	return self.month

func get_day()->int:
	return self.day

func get_weekday()->int:
	return self.weekday
	
func format()->String:
	return Time.get_date_string_from_unix_time(self.timestamp)

func get_month_days()->int:
	var firstday_of_month = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year,self.month,1],false)
	var next_firstday
	if self.month==12:
		next_firstday = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year+1,1,1],false)
	else:
		next_firstday = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year,self.month+1,1],false)
	
	return (Time.get_unix_time_from_datetime_dict(next_firstday)-Time.get_unix_time_from_datetime_dict(firstday_of_month))/ONEDAYSECOND
	
func get_year_days()->int:
	var firstday_of_year = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year,1,1],false)
	var next_firstday = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year+1,1,1],false)
	return (Time.get_unix_time_from_datetime_dict(next_firstday)-Time.get_unix_time_from_datetime_dict(firstday_of_year))/ONEDAYSECOND
	
func get_firstday_of_month()->Datetime:
	var firstday_of_month = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year,self.month,1],true)
	return Datetime.new(firstday_of_month.year,firstday_of_month.month,firstday_of_month.day,firstday_of_month.weekday,Time.get_unix_time_from_datetime_string(DAYFORMAT%[self.year,self.month,1]))
	
	
func get_lastday_of_month()->Datetime:
	var str_dt
	if self.month==12:
		str_dt = DAYFORMAT%[self.year+1,1,1]
	else:
		str_dt = DAYFORMAT%[self.year,self.month+1,1]
	var next_firstday = Time.get_datetime_dict_from_datetime_string(str_dt,true)
	return Datetime.new(next_firstday.year,next_firstday.month,next_firstday.day,next_firstday.weekday,Time.get_unix_time_from_datetime_string(str_dt)).add_days(-1)
	
func get_firstday_of_year()->Datetime:
	var firstday_of_year = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year,1,1],true)
	return Datetime.new(firstday_of_year.year,firstday_of_year.month,firstday_of_year.day,firstday_of_year.weekday,Time.get_unix_time_from_datetime_string(DAYFORMAT%[self.year,1,1]))
	
	
func get_lastday_of_year()->Datetime:
	var next_firstday = Time.get_datetime_dict_from_datetime_string(DAYFORMAT%[self.year+1,1,1],true)
	return Datetime.new(next_firstday.year,next_firstday.month,next_firstday.day,next_firstday.weekday,Time.get_unix_time_from_datetime_string(DAYFORMAT%[self.year+1,1,1])).add_days(-1)
	
