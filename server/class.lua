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

Objects = {
    nextId = 0,
    items = {},
}

setmetatable(Objects, {
	__call = function(self, id)
		return Objects.items[id]
	end
})

function Objects.new(id, data) ---@diagnostic disable-line duplicate-set-field

    if not id then
        id = ("3d-text-%d"):format(Objects.nextId)
    end

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

    Objects.items[id] = instance

    Objects.nextId += 1

    return instance
end

function Objects.remove(id) ---@diagnostic disable-line duplicate-set-field
    Objects.items[id] = nil

    TriggerClientEvent('text-placer:remove-text', -1, id)
end

---Cycle through all items and return a list of ids of the text objects
---@param callFunc fun(obj: SV_TextObject): boolean
function Objects.cycle(callFunc)
    for _, v in pairs(Objects.items) do
        callFunc(v)
    end
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

RegisterCommand('test-text', function (source, args, raw)
    local text = table.concat(args, " ")
    local coords = GetEntityCoords(GetPlayerPed(source))

    lib.print.info(string.format('"%s"', text), coords)

    Objects.new('test-1', {
        text = text,
        coords = coords,
        bucket = 0,
        expiry = false,
        zone = "unknown",
    })
end)