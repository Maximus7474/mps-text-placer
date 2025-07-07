---@class SV_TextObject
---@field id string
---@field text string
---@field expiry number
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

    TriggerClientEvent('text-placer:new-text', -1, id, self)

    Objects[id] = instance
    return instance
end

function Objects.remove(id) ---@diagnostic disable-line duplicate-set-field
    Objects[id] = nil

    TriggerClientEvent('text-placer:remove-text', -1, id)
end

---Cycle through all items and return a list of ids of the text objects
---@param func fun(obj: CL_TextObject): boolean
---@return table
function Objects.cycle(func) ---@diagnostic disable-line duplicate-set-field
    local objs = {}
    for _, v in pairs(Objects) do
        if func(v) then
            objs[#objs+1] = v
        end
    end
    return objs
end

function TextObject:save(transactionId)
    if self.expiry > os.time() or not transactionId then return end

    local data = {
        id = self.id,
        text = self.text,
        coords = self.coords,
        bucket = self.bucket,
        expiry = false,
        zone = self.zone,
    }

    KVP:addToTransaction(transactionId, self.id, data)
end