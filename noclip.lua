local isNoclip = false
local ped = nil
local speedModes = {2.0, 6.0, 12.0, 20.0}
local speedLabels = {"Încet", "Normal", "Rapid", "Foarte rapid"}
local currentSpeedIndex = 2


local upKey = RSGCore.Shared.Keybinds[Config.NoclipUpKey] -- 'E' 
local downKey = RSGCore.Shared.Keybinds[Config.NoclipDownKey] -- 'R'
local shiftKey = RSGCore.Shared.Keybinds["SHIFT"]   --> you can change your keybind
local forwardKey = RSGCore.Shared.Keybinds["W"]  --> you can change your keybind
local backKey = RSGCore.Shared.Keybinds["S"]    --> you can change your keybind
local leftKey = RSGCore.Shared.Keybinds["A"]    --> you can change your keybind
local rightKey = RSGCore.Shared.Keybinds["D"]   --> you can change your keybind
local toggleKey = RSGCore.Shared.Keybinds["L"]   --> you can change your keybind


local function DrawInstructionalText()
    local instructions = {
        "[Noclip Activated]",
        "W / S - Forward / Back",
        "A / D - Left / Right",
        "E / R - Up / Down",
        "SHIFT - Change Speed (" .. speedLabels[currentSpeedIndex] .. ")"
    }
    for i, text in ipairs(instructions) do
        SetTextFontForCurrentCommand(6) 
        SetTextScale(0.8, 0.3)
        SetTextColor(255, 255, 255, 215)
        SetTextCentre(false)
        SetTextDropshadow(1, 0, 0, 0, 255)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), 0.75, 0.75 + (i * 0.03))
    end
end


CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, toggleKey) then
            TriggerServerEvent("noclip:request")
        end
    end
end)

RegisterNetEvent("noclip:toggle", function()
    isNoclip = not isNoclip
    ped = PlayerPedId()

    if isNoclip then
        
        SetEntityVisible(ped, false, false)
        SetEntityInvincible(ped, true)
        SetEntityCollision(ped, false, false)
        SetEntityAlpha(ped, 0, false)
        SetPedCanRagdoll(ped, false)
        ClearPedTasksImmediately(ped)

       
        FreezeEntityPosition(ped, true)
    else
        
        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true, false)
        SetEntityInvincible(ped, false)
        SetEntityCollision(ped, true, true)
        SetEntityAlpha(ped, 255, false)
        SetPedCanRagdoll(ped, true)
    end
end)


CreateThread(function()
    local lastShiftPress = 0
    while true do
        Wait(0)
        if isNoclip then
            local speed = speedModes[currentSpeedIndex]

            
            if IsControlJustPressed(0, shiftKey) then
                local now = GetGameTimer()
                if now - lastShiftPress > 300 then
                    currentSpeedIndex = currentSpeedIndex + 1
                    if currentSpeedIndex > #speedModes then currentSpeedIndex = 1 end
                    lastShiftPress = now
                end
            end

            DrawInstructionalText()

            
            local camRot = GetGameplayCamRot(2)
            local camHeading = math.rad(camRot.z)
            local camPitch = math.rad(camRot.x)

            local direction = vector3(
                -math.sin(camHeading) * math.cos(camPitch),
                math.cos(camHeading) * math.cos(camPitch),
                math.sin(camPitch)
            )

            local moveVec = vector3(0.0, 0.0, 0.0)

            
            if IsControlPressed(0, forwardKey) then
                moveVec = moveVec + direction
            end
            if IsControlPressed(0, backKey) then
                moveVec = moveVec - direction
            end

            local strafeRight = vector3(direction.y, -direction.x, 0.0)

            if IsControlPressed(0, leftKey) then
                moveVec = moveVec - strafeRight
            end
            if IsControlPressed(0, rightKey) then
                moveVec = moveVec + strafeRight
            end
            if IsControlPressed(0, upKey) then
                moveVec = moveVec + vector3(0.0, 0.0, 1.0)
            end
            if IsControlPressed(0, downKey) then
                moveVec = moveVec - vector3(0.0, 0.0, 1.0)
            end

            
            local coords = GetEntityCoords(ped)

if moveVec ~= vector3(0.0, 0.0, 0.0) then
    FreezeEntityPosition(ped, false)
    local newCoords = coords + (moveVec * speed * 0.1)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, true, true, true)
else
    FreezeEntityPosition(ped, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
end

        end
    end
end)
