--[[pod_format="raw",created="2024-10-05 19:07:12",modified="2024-10-05 19:09:04",revision=16]]
include "guita/text.lua"

function guita.button(el)
	el.manifest = {
		request_size = function(w, h)
			return guita.textlength(el.label) + 10, 14
		end,
		weight = 0,
	}

	return guita.new():attach_button(el)
end