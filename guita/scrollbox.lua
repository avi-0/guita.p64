--[[pod_format="raw",created="2024-10-05 19:08:51",modified="2024-10-05 19:09:04",revision=4]]
function guita.scrollbox(el, attribs)
	el.x = 0
	el.y = 0
	
	local scrollbar
	
	local scrollbox = guita.new {
		update = function(self)
			local rw, rh = self.width - scrollbar.width, self.height
			
			if scrollbar.hidden then
				rw, rh = self.width, self.height
				if el.manifest and el.manifest.request_size then
					rw, rh = el.manifest.request_size(self.width, math.huge)
					rw = self.width
				end
				
				if rh <= self.height then
					el.width = rw
					el.height = rh
					return
				end
			end
			
			rw, rh = self.width - scrollbar.width, self.height
			if el.manifest and el.manifest.request_size then
				rw, rh = el.manifest.request_size(self.width - scrollbar.width, math.huge)
				rw = self.width - scrollbar.width
			end
			
			el.width = rw
			el.height = rh
		end
	}
	
	scrollbox:attach(el)
	scrollbar = scrollbox:attach_scrollbars(attribs)
	
	return scrollbox
end
