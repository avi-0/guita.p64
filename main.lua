--[[pod_format="raw",created="2024-09-29 19:42:25",modified="2024-10-05 19:09:04",revision=938]]
include "guita.lua"
include "profiler.lua"

profile.enabled(true, true)

gui = create_gui()
window(320,240)

--local test_text = "btnp is short for \"Button Pressed\"; \nInstead of being true when a button is held down, btnp returns true when a button is down and it was not down the last frame. It also repeats after 30 frames, returning true every 8 frames after that. This can be used for things like menu navigation or grid-wise player movement."
local test_text = [[I'd just like to interject for a moment. What you're refering to as Picotron, is in fact, GNU/Picotron, or as I've recently taken to calling it, GNU plus Picotron. Picotron is not an operating system unto itself, but rather another free component of a fully functioning GNU system made useful by the GNU corelibs, shell utilities and vital system components comprising a full OS as defined by POSIX.

Many computer users run a modified version of the GNU system every day, without realizing it. Through a peculiar turn of events, the version of GNU which is widely used today is often called Picotron, and many of its users are not aware that it is basically the GNU system, developed by the GNU Project.

There really is a Picotron, and these people are using it, but it is just a part of the system they use. Picotron is the kernel: the program in the system that allocates the machine's resources to the other programs that you run. The kernel is an essential part of an operating system, but useless by itself; it can only function in the context of a complete operating system. Picotron is normally used in combination with the GNU operating system: the whole system is basically GNU with Picotron added, or GNU/Picotron. All the so-called Picotron distributions are really distributions of GNU/Picotron!"]]

local box = guita.new(guita.box {p = 4, gap = 4, type = "row", box_justify = "stretch"})
box:attach(guita.text {
	text = test_text,
	layout = {weight = 1},
})
--box:attach(guita.text {
--	text = test_text,
--	text_justify = "center",
--	layout = {weight = 1},
--})
--box:attach(guita.text {
--	text = test_text,
--	text_justify = "right",
----	layout = {weight = 1},
--})
box:attach(guita.button {label = "hello!"})
box:attach(guita.button {label = "hi there!"})

local main = gui:attach(guita.scrollbox(box, {autohide = false}))
--local main = gui:attach(box)

function _draw()
	cls(15)
	gui:draw_all()
	
	--print("\#0" .. stat(1), 1, 1, 8)
	profile.draw()
	--print("\#0" .. guita_cache_total, 1, 1, 8)
end

function _update()
	local width, height = get_display():attribs()
	main.x = 0
	main.y = 0
	main.width = width
	main.height = height

	textwrapcalls = 0

	gui:update_all()
end