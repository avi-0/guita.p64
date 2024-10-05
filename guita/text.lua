--[[pod_format="raw",created="2024-10-05 19:04:50",modified="2024-10-05 22:44:29",revision=361]]
include "guita/utils.lua"

local textlength = guita.cache(function(str)
	return print(str,0,-1000)
end, nil, 512)
guita.textlength = textlength

--textwrapcalls = 0 -- debug
local function textwrap(str, width)
	profile("textwrap",true)
--	textwrapcalls += 1
	
	local lines = {}
	local line_widths = {}
	
	local current_line = ""
	local current_width = 0
	
	local x = 0
	for wordspace in str:gmatch("([^%s]+%s*)") do
		local word, space = wordspace:match("^([^%s]+)(%s*)$")
		
		x += textlength(word)
		if x > width then
			add(lines, current_line)
			add(line_widths, current_width)
			current_line = ""
			current_width = 0
			
			x = textlength(wordspace)
			
			current_line ..= wordspace
			current_width = x
		else
			current_line ..= word
			current_width = x
			
			x += textlength(space)
			
			if x > width then
				add(lines, current_line)
				add(line_widths, current_width)
				current_line = ""
				current_width = 0
				
				x = 0
			else
				current_line ..= space
			end
		end
		
		-- check if a newline character was there
		if space:find("\n") then
			add(lines, current_line)
			add(line_widths, current_width)
			current_line = ""
			current_width = 0
			
			x = 0
		end
	end
	add(lines, current_line)
	add(line_widths, current_width)
	
	profile("textwrap",true)

	return lines, line_widths
end

function guita.text(el)
	el = guita.new(el)

	el.text = el.text or ""
	el.text_color = el.text_color or 0
	el.bg_color = el.bg_color or nil

	el.text_justify = el.text_justify or "left"
	
	local memo_textwrap = guita.memo(textwrap)
	
	el.manifest = el.manifest or {}
	el.manifest.height_from_width = function(width)
		local lines, line_widths = memo_textwrap(el.text, width + 1)
		
		local req_height = 8 * #lines
		
		return req_height
	end
	el.manifest.width_from_height = function(height)
		return math.huge
	end
	el.manifest.request_size = function(width, height)
		return width, el.manifest.height_from_width(width)
	end
	el.manifest.min_size = function()
		return 0, 0
	end

	el.draw = function(self)
		if el.bg_color then
			rectfill(0, 0, self.width, self.height, el.bg_color)
		end
		
		local lines, line_widths = memo_textwrap(el.text, self.width + 1)
		for i = 1, #lines do
			local x
			if el.text_justify == "left" then
				x = 0
			elseif el.text_justify == "center" then
				x = (self.width + 1)/2 - line_widths[i] / 2
			elseif el.text_justify == "right" then
				x = self.width + 1 - line_widths[i]
			end
			
			print(lines[i], x, (i-1)*8, el.text_color)
		end
	end
	
	return el
end