--[[pod_format="raw",created="2024-10-05 19:07:12",modified="2024-10-05 21:47:57",revision=268]]
include "guita/text.lua"

function guita.button(el)
	el.manifest = {
		min_size = function(w, h)
			return guita.textlength(el.label) + 10, 14
		end,
		weight = 0,
	}

	return guita.new():attach_button(el)
end