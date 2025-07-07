---@class CL_TextObject
---@field id string
---@field text string
---@field distance number
---@field coords vector3
---@field bucket integer
---@field zone string 
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

---Cycle through all items and return a list of ids of the text objects
---@param func fun(obj: CL_TextObject): boolean
---@return table
function Objects.cycle(func)
    local objs = {}
    for k, v in pairs(Objects) do 
        if func(v) then
            objs[#objs+1] = v
        end
    end
    return objs
end

---Check if the text is close enough to render
---@param coords vector3 the players coordinates
---@return boolean isInRange
function TextObject:shouldRender(coords)
    local distance = Convar:Get('draw-distance')
    self.distance = #(coords - self.coords)
    return self.distance <= distance
end

---Draws the text object in the game world
function TextObject:render()
    local font = 0
    local r, g, b, a = 255, 255, 255,255 
    local scale, minScale = 0.35, 0.1
    local maxDistance = Convar:Get('draw-distance')
    local distance = self.distance

    local onScreen, screenX, screenY = World3dToScreen2d(self.coords.x, self.coords.y, self.coords.z)

    if not onScreen then return end

    local adjustedScale = scale - ((scale - minScale) * (distance / maxDistance))
    adjustedScale = math.max(minScale, adjustedScale)

    local adjustedAlpha = a * (1 - (distance / maxDistance))
    adjustedAlpha = math.max(0, math.min(255, adjustedAlpha))

    SetTextFont(font)
    SetTextScale(1.0, adjustedScale)
    SetTextColour(r, g, b, adjustedAlpha)

    SetTextOutline()
    SetTextDropShadow()

    SetTextEntry("STRING")
    AddTextComponentString(self.text)
    DrawText(screenX, screenY)
end