--[[pod_format="raw",created="2024-09-29 19:42:25",modified="2024-10-02 19:47:31",revision=507]]
include "guita.lua"
include "profiler.lua"

profile.enabled(true, true)

gui = create_gui()
window(320,240)

local test_text = "btnp is short for \"Button Pressed\"; \nInstead of being true when a button is held down, btnp returns true when a button is down and it was not down the last frame. It also repeats after 30 frames, returning true every 8 frames after that. This can be used for things like menu navigation or grid-wise player movement."

local box = gui:attach(guita.box {p = 4, gap = 4, layout = "column"})
box:attach(guita.text {
	text = test_text,
--	layout = {weight = 1},
})
box:attach(guita.text {
	text = test_text,
	text_justify = "center",
--	layout = {weight = 1},
})
box:attach(guita.text {
	text = test_text,
	text_justify = "right",
--	layout = {weight = 1},
})

function _draw()
	cls(15)
	gui:draw_all()
	
	--print("\#0" .. stat(1), 1, 1, 8)
	profile.draw()
	--print("\#0" .. textwrapcalls, 1, 1, 8)
	
end

function _update()
	local width, height = get_display():attribs()
	box.x = 0
	box.y = 0
	box.width = width
	box.height = height

	textwrapcalls = 0

	gui:update_all()
end