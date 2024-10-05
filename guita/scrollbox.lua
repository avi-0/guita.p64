--[[pod_format="raw",created="2024-10-05 19:08:51",modified="2024-10-05 21:04:11",revision=159]]
function guita.scrollbox(el, attribs)
	el.x = 0
	el.y = 0
	
	guita.init_manifest(el)
	
	local scrollbar
	
	local scrollbox = guita.new {
		update = function(self)
			local rw, rh = self.width - scrollbar.width, self.height
			
			if scrollbar.hidden then
				rw = self.width
				rh = el.manifest.height_from_width(self.width)
				
				if rh <= self.height then
					el.width = rw
					el.height = rh
					return
				end
			end
			
			rh = el.manifest.height_from_width(self.width - scrollbar.width)
			
			el.width = rw
			el.height = rh
			
			el.y = mid(0, el.y, -max(0, el.height - self.height))
		end
	}
	
	scrollbox:attach(el)
	scrollbar = scrollbox:attach_scrollbars(attribs)
	
	return scrollbox
end
