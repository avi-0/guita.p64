--[[pod_format="raw",created="2024-10-05 19:03:51",modified="2024-10-05 19:09:04",revision=27]]
guita = guita or {}

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