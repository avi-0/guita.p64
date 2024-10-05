--[[pod_format="raw",created="2024-10-05 19:08:23",modified="2024-10-05 23:26:09",revision=531]]
function guita.box(el)
	el = guita.new(el)

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
	
	el.box_justify = el.box_justify or "stretch"
	
	local pad_bc = function()
		local px = el.pl + el.pr
		local py = el.pt + el.pb
		if el.type == "column" then
			px, py = py, px
		end
		return px, py
	end
	
	local self_axis = function(swap)
		if (el.type == "row") != swap then
			return el.width - el.pl - el.pr
		elseif (el.type == "column") != swap then
			return el.height - el.pt - el.pb
		end
	end
	
	local base_from_cross = function(child, x)
		if el.type == "column" then
			return child.manifest.height_from_width(x)
		else
			return child.manifest.width_from_height(x)
		end
	end
	
	local cross_from_base = function(child, x)
		if el.type == "row" then
			return child.manifest.height_from_width(x)
		else
			return child.manifest.width_from_height(x)
		end
	end
	
	local child_min = function(child)
		if child.manifest and child.manifest.min_size then
			local min_width, min_height = child.manifest.min_size()
			
			if el.type == "column" then
				min_width, min_height = min_height, min_width
			end
			return min_width, min_height
		else
			return 0
		end
	end
	
	local available = function(av_base)
		-- av_base is with no gaps
		av_base -= el.gap * (#el.child - 1)
		
		for child in all(el.child) do
			av_base -= child_min(child)
		end
		
		return av_base
	end
	
	local child_weight = function(child, av)
		if child.manifest then
			return child.manifest.weight or 1
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
	
	local child_size = function(child, av_base)
		local min_base = child_min(child)
		
		local base = min_base + child_weight(child, av_base) * per_child(av_base)
		local cross = cross_from_base(child, base)
	
		return base, cross
	end	

	el.update = function(self)
		local av = available(self_axis(false))

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
			elseif el.box_justify == "end" then
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
	
	el.draw = function(self)
		if self.bg_col then
			rectfill(0, 0, self.width -1, self.height - 1, self.bg_col)
		end
	end
	
	el.attach = function(self, child)
		child = guita.new(child)
		child.parent = self
		child.head = self.head or self
		
		guita.init_manifest(child)
		
		add(self.child, child)
		
		self:update()
		
		return child
	end
	
	el.manifest = el.manifest or {}
	
	local m_base_from_cross = function(av_cross)
		local pb, pc = pad_bc()
		
		av_cross -= pc
		
		local base = 0
		for child in all(el.child) do
			base += base_from_cross(child, av_cross)
		end
		
		base += pb
		base += el.gap * (#el.child - 1)
		
		return base
	end
	
	local m_cross_from_base = function(av_base)
		local pb, pc = pad_bc()
		local av = available(av_base - pb)
		
		local cross = 0
		for child in all(el.child) do
			local base = child_size(child, av)
			cross = max(cross, cross_from_base(child, base))
		end
		
		cross += pc
		
		return cross
	end
	
	el.manifest.width_from_height = function(h)
		if el.type == "row" then
			return m_base_from_cross(h)
		else
			return m_cross_from_base(h)
		end
	end
	
	el.manifest.height_from_width = function(w)
		if el.type == "column" then
			return m_base_from_cross(w)
		else
			return m_cross_from_base(w)
		end
	end
	
	el.manifest.min_size = function()
		local base, cross = pad_bc()
		
		for child in all(el.child) do
			child_b, child_c = child_min(child)
			base += child_b
			cross = max(cross, child_c)
		end
		
		base += el.gap * (#el.child - 1)
		
		if el.type == "column" then
			base, cross = cross, base
		end
		return base, cross
	end

	return el
end