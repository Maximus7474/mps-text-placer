while not NetworkIsSessionStarted() do
    Wait(500)
end

local displayableObjects, maxDistance = {}, Convar:Get('draw-distance') --[[ @as number ]]

CreateThread(function ()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)    

        displayableObjects = Objects.cycle(function (obj)
            return obj:shouldRender(coords, maxDistance)
        end)
        Wait(1000)
    end
end)

CreateThread(function ()
    while true do
        if #displayableObjects == 0 then
            Wait(500)
        else
            Wait(1)
        end

        for i = 1, #displayableObjects do
            local obj = displayableObjects[i]
            obj:render()
        end
    end
end)