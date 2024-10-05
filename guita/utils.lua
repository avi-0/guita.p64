--[[pod_format="raw",created="2024-10-05 19:03:51",modified="2024-10-05 21:04:11",revision=167]]
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

function guita.cache(f, key, cap)
	local t = {}
	
	if key == nil and cap == nil then
		return function(x)
			local v = t[x]
			if v == nil then
				v = f(x)
				t[x] = v
			end
			
			return v
		end
	elseif key != nil and cap == nil then
		return function(...)
			local k = key(...)
			local v = t[k]
			if v == nil then
				v = f(...)
				t[k] = v
			end
			
			return v
		end
	elseif key == nil and cap != nil then
		local keys = {}
		local key_i = -1
		
		return function(x)
			local v = t[x]
			if v == nil then
				key_i = (key_i + 1) % cap
				
				t[keys[key_i] or 0] = nil
				keys[key_i] = x
			
				v = f(x)
				t[x] = f(x)
			end
			
			return v
		end
	elseif key != nil and cap != nil then
		local keys = {}
		local key_i = -1
		
		return function(...)
			local k = key(...)
			local v = t[k]
			
			if v == nil then
				key_i = (key_i + 1) % cap
			
				t[keys[key_i] or 0] = nil
				keys[key_i] = k
			
				v = f(...)
				t[k] = v
			end
			
			return v
		end
	end
end