--[[pod_format="raw",created="2024-10-05 19:08:23",modified="2024-10-05 19:09:04",revision=5]]
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
	
	el.box_justify = el.box_justify or "left"
	
	local child_requested = function(child)
		if child.manifest and child.manifest.request_size then
			local av_w = el.width - el.pl - el.pr
			local av_h = el.height - el.pt - el.pb
			local req_width, req_height = child.manifest.request_size(av_w, av_h)
			
			if el.type == "row" then
				return req_width, req_height
			elseif el.type == "column" then
				return req_height, req_width
			end
		else
			return 0, 0
		end
	end
	
	local self_axis = function(swap)
		if (el.type == "row") != swap then
			return el.width - el.pl - el.pr
		elseif (el.type == "column") != swap then
			return el.height - el.pt - el.pb
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
		if child.manifest then
			local wt = child.manifest.weight or 0
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
		local req_b, req_c = child_requested(child)
		return req_b + child_weight(child, av) * per_child(av), req_c
	end	

	el.update = function(self)
		local av = available()

		local delta = 0
		for i, child in pairs(self.child) do
--			local dx = self.type == "row" and delta or 0
--			local dy = self.type == "column" and delta or 0
	
--			child.x = el.pl + dx
--			child.y = el.pt + dy
--			child.width = el.width - el.pl - el.pr
--			child.height = el.height - el.pt - el.pb
			
			local base, cross = child_size(child, av)
			cross = min(cross, self_axis(true))
			
			local o_base = delta
			local o_cross = 0
			if el.box_justify == "stretch" then
				cross = self_axis(true)
			elseif el.box_justify == "center" then
				o_cross = self_axis(true) / 2 - cross / 2
			elseif el.box_justify == "right" then
				o_cross = self_axis(true) - cross
			end
		
			if el.type == "row" then
				child.x = el.pl + o_base
				child.y = el.pt + o_cross
				child.width = base
				child.height = cross
			elseif el.type == "column" then
				child.x = el.pl + o_cross
				child.y = el.pt + o_base
				child.width = cross
				child.height = base
			end
			
			delta += base + el.gap
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
	
	el.manifest = {}
	el.manifest.request_size = function(av_width, av_height)
		av_width -= el.pl + el.pr
		av_height -= el.pt + el.pb	

		local base, cross = 0, 0
		
		for child in all(el.child) do
			local b, c = 0, 0
			if child.manifest and child.manifest.request_size then
				b, c = child.manifest.request_size(av_width, av_height)
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