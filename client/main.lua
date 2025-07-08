while not NetworkIsSessionStarted() do
    Wait(500)
end

local PlayerPedId, GetEntityCoords = PlayerPedId, GetEntityCoords

local displayableObjects, maxDistance = {}, Convar:Get('draw-distance') --[[ @as number ]]
local playerPed = PlayerPedId()

CreateThread(function ()
    while true do
        playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        displayableObjects = Objects.filter(function (obj)
            return obj:shouldRender(coords, maxDistance)
        end)

        Wait(1000)
    end
end)

CreateThread(function ()
    while true do
        local coords
        if #displayableObjects == 0 then
            Wait(500)
        else
            coords = GetEntityCoords(playerPed)
            Wait(0)

            for i = 1, #displayableObjects do
                local obj = displayableObjects[i]
                obj:render(coords, maxDistance)
            end
        end
    end
end)