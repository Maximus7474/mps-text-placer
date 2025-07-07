local TextObject = {}
TextObject.__index = TextObject

Objects = {}

setmetatable(Objects, {
	__call = function(self, id)
		return Objects[id]
	end
})

function Objects.new(id, data) ---@diagnostic disable-line duplicate-set-field
    local self = {
        id = id,
        text = data.text,
        coords = data.coords,
        bucket = data?.bucket or 0,
        expiry = data?.expiry or false,
        zone = data.zone,
    }

    local instance = setmetatable(self, TextObject)

    Objects[id] = instance
    return instance
end

function Objects.remove(id) ---@diagnostic disable-line duplicate-set-field
    Objects[id] = nil
end

---Check if the text is close enough to render
---@param coords vector3 the players coordinates
---@return boolean isInRange
function TextObject:shouldRender(coords)
    local distance = Convar:Get('draw-distance')
    return #(coords - self.coords) <= distance
end