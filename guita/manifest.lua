--[[pod_format="raw",created="2024-10-05 19:26:31",modified="2024-10-05 21:04:11",revision=131]]
function guita.init_manifest(el)
	if el.manifest == nil then
		local const_width, const_height = el.width, el.height
		
		el.manifest = {
			min_size = function()
				return const_width, const_height
			end,
		}
	end
	
	if not el.manifest.request_size
	and el.manifest.min_size then
		el.manifest.request_size = el.manifest.min_size
	end
	
	if not el.manifest.height_from_width then
		el.manifest.height_from_width = function(w)
			local _, h = el.manifest.min_size()
			return h
		end
	end
	
	if not el.manifest.width_from_height then
		el.manifest.width_from_height = function(h)
			local w, _ = el.manifest.min_size()
			return w
		end
	end
end