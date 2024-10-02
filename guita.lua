--[[pod_format="raw",created="2024-09-29 19:59:14",modified="2024-10-02 19:47:31",revision=577]]
guita = {}

function guita.memo(f)
	local last_params = {}
	local last_values = {}
	
	return function(...)
		for i,v in pairs({...}) do
			if last_params[i] != v then
				last_params = pack(...)
				last_values = pack(f(...))
				break
			end
		end
		return unpack(last_values)
	end
end

local textlength = function(str)
	profile("textlength")
	
	local p = print(str,480,0)
	

	profile("textlength")
	return p-480
end

textwrapcalls = 0 -- debug
local function textwrap(str, width)
	profile("textwrap")
	textwrapcalls += 1
	
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
			
			x = 0
			x += textlength(wordspace)
			
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
				--current_width = x - OFFSCREEN
				--if it's last space in a line - shouldnt count
				--if there's another word in the line
				-- - current_width will get updated anyway
			end
		end
		
		-- check if a newline character was there
		if space:match("\n") then
			add(lines, current_line)
			add(line_widths, current_width)
			current_line = ""
			current_width = 0
			
			x = 0
		end
	end
	add(lines, current_line)
	add(line_widths, current_width)
	
	profile("textwrap")

	return lines, line_widths
end

function guita.text(el)
	el.text = el.text or ""

	el.text_justify = el.text_justify or "left"
	
	local memo_textwrap = guita.memo(textwrap)
	
	el.layout = el.layout or {}
	el.layout.request_size = function(width, height)
		local lines, line_widths = memo_textwrap(el.text, width + 1)
		
		local req_width = width
		local req_height = 8 * #lines
		
		return req_width, req_height
	end

	el.draw = function(self)
		rectfill(0, 0, self.width, self.height, 7)
		
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
			
			print(lines[i],x,(i-1)*8,0)
		end
	end
	
	return el
end

function guita.box(el)
	el.width = el.width or 100
	el.height = el.height or 100
	
	-- "row" | "column"
	el.layout = el.layout or "row"

	el.p = el.p or 0
	
	el.px = el.px or el.p
	el.py = el.py or el.p
	
	el.pt = el.pt or el.py
	el.pb = el.pb or el.py
	
	el.pl = el.pl or el.px
	el.pr = el.pr or el.px
	
	el.gap = el.gap or 0
	
	local child_requested = function(child)
		if child.layout and child.layout.request_size then
			local av_w = el.width - el.pl - el.pr
			local av_h = el.height - el.pt - el.pb
			local req_width, req_height = child.layout.request_size(av_w, av_h)
			
			if el.layout == "row" then
				return req_width
			elseif el.layout == "column" then
				return req_height
			end
		else
			return 0
		end
	end
	
	local available = function()
		local gaps = el.gap * (#el.child - 1)
		
		local amt	

		if el.layout == "row" then
			amt = el.width - el.pl - el.pr - gaps
		elseif el.layout == "column" then
			amt = el.height - el.pt - el.pb - gaps
		end
		
		for child in all(el.child) do
			amt -= child_requested(child)
		end
		
		--amt = math.max(0, amt)
		
		return amt
	end
	
	local child_weight = function(child, av)
		if child.layout then
			local wt = child.layout.weight or 0
			if av < 0 then
				wt = math.max(1, wt)
			end
			
			return wt
		else
			return 1
		end
	end
	
	local total_weight = function(av)
		local total = 0
		
		for child in all(el.child) do
			total += child_weight(child, av)
		end
		
		return total
	end
	
	local per_child = function(av)
		return av / total_weight(av)
	end
	
	local child_size = function(child, av)
		return child_requested(child) + child_weight(child, av) * per_child(av)
	end	

	el.update = function(self)
		local av = available()

		local delta = 0
		for i, child in pairs(self.child) do
			local dx = self.layout == "row" and delta or 0
			local dy = self.layout == "column" and delta or 0
	
			child.x = el.pl + dx
			child.y = el.pt + dy
			child.width = el.width - el.pl - el.pr
			child.height = el.height - el.pt - el.pb
			
			local size = child_size(child, av)
			if el.layout == "row" then
				child.width = size
			elseif el.layout == "column" then
				child.height = size
			end
			
			delta += size + el.gap
		end
	end
	
	el.attach = function(self, child)
		child = self.head:new(child)
		child.parent = self
		child.head = self.head or self
		
		add(self.child, child)
		
		self:update()
		
		return child
	end

	return el
end