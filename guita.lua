--[[pod_format="raw",created="2024-09-29 19:59:14",modified="2024-10-02 17:21:43",revision=237]]
guita = {}

function textwrap(str, width)
     -- printing offscreen to get line width
    local OFFSCREEN = 480
    
    local lines = {}
    local current_line = ""
    
    local x, y = OFFSCREEN, 0
    for word in str:gmatch("([^%s]+%s*)") do
        x = print(word, x, y)
        if x > OFFSCREEN + width then
            add(lines, current_line)
            current_line = ""
    
            x = OFFSCREEN
            x = print(word, x, y)
        end
        
        current_line ..= word
    end
    
    add(lines, current_line)    

    return lines
end

function guita.text(el)
	el.draw = function(self)
		rectfill(0, 0, self.width, self.height, 7)
		
		local lines = textwrap(el.text, self.width - 4)
		for i = 1, #lines do
			print(lines[i],2,2+(i-1)*8,0)
		end
	end
	
	return el
end

function guita.box(el)
	el.width = el.width or 100
	el.height = el.height or 100
	
	-- "row" | "column"
	el.layout = el.layout or "row"

	el.p = el.p or 0
	
	el.px = el.px or el.p
	el.py = el.py or el.p
	
	el.pt = el.pt or el.py
	el.pb = el.pb or el.py
	
	el.pl = el.pl or el.px
	el.pr = el.pr or el.px
	
	el.gap = el.gap or 0
	
	local available = function()
		local gaps = el.gap * (#el.child - 1)	

		if el.layout == "row" then
			return el.width - el.pl - el.pr - gaps
		elseif el.layout == "column" then
			return el.height - el.pt - el.pb - gaps
		end
	end
	
	local per_child = function()
		return available() / #el.child
	end
	
	el.update = function(self)
		for i, child in pairs(self.child) do
			local delta = (per_child() + self.gap) * (i - 1)
			local dx = self.layout == "row" and delta or 0
			local dy = self.layout == "column" and delta or 0
	
			child.x = el.pl + dx
			child.y = el.pt + dy
			child.width = el.width - el.pl - el.pr
			child.height = el.height - el.pt - el.pb
			
			if self.layout == "row" then
				child.width = per_child()
			elseif self.layout == "column" then
				child.height = per_child()
			end
		end
	end
	
	el.attach = function(self, child)
		child = self.head:new(child)
		child.parent = self
		child.head = self.head or self
		
		add(self.child, child)
		
		self:update()
		
		return child
	end

	return el
end