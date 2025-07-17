local helpTextThread = nil
local function ShowHelpText(toggle, text)
    print("^4ShowHelpText^7 invoked:", toggle, 'current threadId:', helpTextThread)
    if (helpTextThread ~= nil) then
        TerminateThread(helpTextThread)
        helpTextThread = nil
    end

    if (toggle == false) then
        return
    end

    CreateThread(function (threadId)
        helpTextThread = threadId

        while helpTextThread == threadId do
            AddTextEntry("textplacerHelp", text)
            DisplayHelpTextThisFrame("textplacerHelp", false)
            Wait(0)
        end
    end)
end

local function drawText(text, playerCoords, textCoords)
    local font = 0
    local r, g, b = 255, 255, 255
    local scale, minScale = 0.35, 0.1
    local distance = #(playerCoords - textCoords)

    local onScreen, screenX, screenY = World3dToScreen2d(textCoords.x, textCoords.y, textCoords.z)

    if not onScreen then return end

    local adjustedScale = scale - ((scale - minScale) * (distance / 20))
    adjustedScale = math.max(minScale, adjustedScale)

    SetTextFont(font)
    SetTextScale(1.0, adjustedScale)
    SetTextColour(r, g, b, 255)

    SetTextCentre(true)
    SetTextOutline()
    SetTextDropShadow()

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

RegisterCommand('place_text', function (_, args, _)
    local textToDisplay = table.concat(args, ' ')
    local text = "%s %s Hauteure du text\n%s Validate position\n%s Cancel placement"
    ShowHelpText(true, text:format('~INPUT_WEAPON_WHEEL_PREV~', '~INPUT_WEAPON_WHEEL_NEXT~', '~INPUT_FRONTEND_ENDSCREEN_ACCEPT~', '~INPUT_FRONTEND_PAUSE_ALTERNATE~'))

    local active = true
    local playerPed = PlayerPedId()
    local textCoords = GetEntityCoords(playerPed)
    local textOffset = 0

    CreateThread(function (threadId)
        while active do
            local hit, _, endcoords, _, _ = lib.raycast.fromCamera(511, 4, 20)

            if (hit == true and type(endcoords) == "vector3") then
                textCoords = endcoords
            end

            Wait(0)
        end
    end)

    CreateThread(function (threadId)

        local function terminateThread()
            TerminateThisThread()
            ShowHelpText(false)
            active = false
        end

        local GetEntityCoords, IsDisabledControlPressed, DisableControlAction = GetEntityCoords, IsDisabledControlPressed, DisableControlAction

        while active do
            DisableControlAction(0, 215, true) -- INPUT_FRONTEND_ENDSCREEN_ACCEPT
            DisableControlAction(0, 200, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE
            DisableControlAction(0, 14, true)  -- INPUT_WEAPON_WHEEL_NEXT
            DisableControlAction(0, 15, true)  -- INPUT_WEAPON_WHEEL_PREV

            local coords = GetEntityCoords(playerPed)
            drawText(textToDisplay, coords, textCoords + vector3(0, 0, textOffset))

            if (IsDisabledControlPressed(0, 215)) then
                -- Gather data & send to server
                textCoords = textCoords + vector3(0, 0, textOffset)
                print("saving")
                print("Saving text: '" .. textToDisplay .. "' at coordinates: " ..
                      string.format("X:%.2f, Y:%.2f, Z:%.2f", textCoords.x, textCoords.y, textCoords.z))
                terminateThread()

                TriggerServerEvent('text-placer:newText', textCoords, textToDisplay)
            elseif (IsDisabledControlPressed(0, 200)) then
                -- Scrap data and exit
                print("Exiting")
                terminateThread()
                return
            elseif (IsDisabledControlPressed(0, 15)) then
                textOffset += 0.1
            elseif (IsDisabledControlPressed(0, 14)) then
                textOffset -= 0.1
            end
            Wait(0)
        end
    end)
end)

TriggerEvent('chat:addSuggestions', {{
    name='/place_text',
    help='Placer un text 3D dans le monde',
    params={
        { name="text", help="Text a afficher" },
    }
}})