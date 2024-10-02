--[[pod_format="raw",created="2024-09-29 19:42:25",modified="2024-10-02 17:21:43",revision=230]]
include "guita.lua"

gui = create_gui()
window(320,240)

local box = gui:attach(guita.box {p = 4, gap = 4, layout = "column"})
box:attach(guita.text {
	text = "btnp is short for \"Button Pressed\"; Instead of being true when a button is held down, btnp returns true when a button is down and it was not down the last frame. It also repeats after 30 frames, returning true every 8 frames after that. This can be used for things like menu navigation or grid-wise player movement.",
})
box:attach(guita.text {
	text = "btnp is short for \"Button Pressed\"; Instead of being true when a button is held down, btnp returns true when a button is down and it was not down the last frame. It also repeats after 30 frames, returning true every 8 frames after that. This can be used for things like menu navigation or grid-wise player movement.",
})
box:attach(guita.text {
	text = "btnp is short for \"Button Pressed\"; Instead of being true when a button is held down, btnp returns true when a button is down and it was not down the last frame. It also repeats after 30 frames, returning true every 8 frames after that. This can be used for things like menu navigation or grid-wise player movement.",
})

function _draw()
	gui:draw_all()
end

function _update()
	local width, height = get_display():attribs()
	box.x = 0
	box.y = 0
	box.width = width
	box.height = height

	gui:update_all()
end