extends Button

var active = false
var default_txt = self.text


func _pressed():
	if not active:
		timer_started()
		
		var secs = $"../TimerSecs".value
		await get_tree().create_timer(secs).timeout
		
		timer_ended()


func timer_started():
	active = true
	self.text = "wait..."
	self.disabled = true


func timer_ended():
	active = false
	self.text = default_txt
	self.disabled = false
