--[[pod_format="raw",created="2024-09-29 19:59:14",modified="2024-10-02 23:42:27",revision=863]]
guita = {}

local GuiElement = getmetatable(create_gui())

function guita.new(el)
	el = GuiElement:new(el)
	el.width = el.width or 0
	el.height = el.height or 0
	
	return el
end

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

guita_cache_total = 0
function guita.cache(f)
	local t = {}
	
	return function(x)
--		profile("cache")
		local v = t[x]
		if v == nil then
			v = f(x)
			t[x] = v
			
--			guita_cache_total+=1
		end

--		profile("cache")
		return v
	end
end

local textlength = guita.cache(function(str)
	return print(str,0,-1000)
end)

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
	el.width = el.width or 0
	el.height = el.height or 0
	
	-- "row" | "column"
	el.type = el.type or "row"

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
			
			if el.type == "row" then
				return req_width
			elseif el.type == "column" then
				return req_height
			end
		else
			return 0
		end
	end
	
	local available = function()
		local gaps = el.gap * (#el.child - 1)
		
		local amt

		if el.type == "row" then
			amt = el.width - el.pl - el.pr - gaps
		elseif el.type == "column" then
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
			local dx = self.type == "row" and delta or 0
			local dy = self.type == "column" and delta or 0
	
			child.x = el.pl + dx
			child.y = el.pt + dy
			child.width = el.width - el.pl - el.pr
			child.height = el.height - el.pt - el.pb
			
			local size = child_size(child, av)
			if el.type == "row" then
				child.width = size
			elseif el.type == "column" then
				child.height = size
			end
			
			delta += size + el.gap
		end
	end
	
	el.attach = function(self, child)
		child = guita.new(child)
		child.parent = self
		child.head = self.head or self
		
		add(self.child, child)
		
		self:update()
		
		return child
	end
	
	el.layout = {}
	el.layout.request_size = function(av_width, av_height)
		av_width -= el.pl + el.pr
		av_height -= el.pt + el.pb	

		local base, cross = 0, 0
		
		for child in all(el.child) do
			local b, c = 0, 0
			if child.layout and child.layout.request_size then
				b, c = child.layout.request_size(av_width, av_height)
			end
			
			if el.type == "column" then
				c, b = b, c
			end
			
			base += b
			cross = max(cross, c)
		end
		
		base += el.gap * (#el.child - 1)
		
		if el.type == "column" then
			base, cross = cross, base
		end
		
		base += el.pl + el.pr
		cross += el.pt + el.pb
		
		return base, cross
	end

	return el
end

function guita.scrollbox(el)
	el.x = 0
	el.y = 0
	
	local scrollbar
	
	local scrollbox = guita.new {
		update = function(self)
			local rw, rh = self.width - scrollbar.width, self.height
			
			if el.layout and el.layout.request_size then
				rw, rh = el.layout.request_size(self.width - scrollbar.width, math.huge)
				rw = self.width - scrollbar.width
			end
			
			el.width = rw
			el.height = rh
		end
	}
	
	scrollbox:attach(el)
	scrollbar = scrollbox:attach_scrollbars()
	
	return scrollbox
end