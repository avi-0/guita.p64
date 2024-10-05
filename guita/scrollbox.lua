--[[pod_format="raw",created="2024-10-05 19:08:51",modified="2024-10-05 23:26:09",revision=465]]
function guita.scrollbox(el, attribs)
	el.x = 0
	el.y = 0
	
	guita.init_manifest(el)
	
	attribs = attribs or {}
	attribs.autohide = (attribs.autohide == nil) and true
	
	local scrollbar
	
	local scrollbox = guita.new {
		width = 0,
		height = 0,
		update = function(self)
			local rw, rh = self.width - scrollbar.width, self.height
			
			if scrollbar.hidden then
				rw = self.width
				rh = el.manifest.height_from_width(self.width)
				
				if rh <= self.height then
					el.width = rw
					el.height = self.height
					return
				end
			end
			
			rh = el.manifest.height_from_width(self.width - scrollbar.width)
			
			el.width = rw
			el.height = rh
			
			el.y = mid(0, el.y, -max(0, el.height - self.height))
		end,
		
		-- for some god forsaken reason
		-- not having this one breaks clipping to parent
		draw = function() end,
	}
	
	el = scrollbox:attach(el)
	scrollbar = scrollbox:attach_scrollbars(attribs)
	
	scrollbox.manifest = {
		min_size = function()
			local w, h = el.manifest.min_size()
			if not scrollbar.autohide then
				w += scrollbar.width
			end
			
			return w, 0
		end,
		width_from_height = function(h)
			local w =	el.manifest.width_from_height(h)
			if not scrollbar.autohide then
				w += scrollbar.width
			end
			
			return w
		end,
		height_from_width = function(w)
			return 0
		end,
		weight = 1,
	}
	
	return scrollbox
end
