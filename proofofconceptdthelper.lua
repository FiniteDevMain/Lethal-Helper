local debugesp = true
local myfont = draw.CreateFont("Verdana", 16, 800)
local indicatorFont = draw.CreateFont("Verdana", 22, 800)
local dotSize = 4
-- all of this is PROOF OF CONCEPT whatever that means other than its broken but its a start and probably useless
-- there is a LOT of useless code + unused code but that isn't my code anyways so just "enjoy" this bug mess fest.
-- i do not recommend using this at all honestly its just me showing that is lethal check for dt isn't that hard "abysstf2..."
local indicatorY = 300 


local dormant_duration = 0.2
local dormant_fade_speed = 255 / dormant_duration
local dormant_start_times = {}
-- probably fine lol? replace it if u need lmfao
local lethalSettings = {
    scout = {
        lethalThreshold = 400,
        closeThreshold = 200,
        lethalHealthLimit = 125,
        newHealthLimit = 220,
        forceHealthLimit = 280,
        enableDT = true,
        lethalText = {
            close = "VERY LETHAL",
            lethal = "LETHAL",
            force = "FORCE DT"
        }
    },
    heavy = {
        lethalThreshold = 0,
        closeThreshold = 150,
        lethalHealthLimit = 300,
        newHealthLimit = 400,
        forceHealthLimit = 299,
        enableDT = true,
        lethalText = {
            close = "VERY OPTIMAL",
            lethal = "OPTIMAL",
            force = "FORCE DT"
        }
    },
    directhit = {
        lethalThreshold = 370,
        closeThreshold = 0,
        lethalHealthLimit = 125,
        newHealthLimit = 250,
        forceHealthLimit = 35000,
        enableDT = false,
        lethalText = {
            close = "VERY LETHAL",
            lethal = "LETHAL",
            force = "FORCE DT"
        }
    }
}
-- idk why this exists but yes 
local lastConfigPrinted = ""

local function getMyLethalConfig(localPlayer)
    local class = localPlayer:GetPropInt("m_iClass")
    local weapon = localPlayer:GetPropEntity("m_hActiveWeapon")
    local weaponClass = weapon and weapon:GetClass() or ""

    local configName = "scout"

    if class == 1 then 
        configName = "scout"
    elseif class == 6 then 
        configName = "heavy"
    elseif weaponClass == "CTFRocketLauncher_DirectHit" then
        configName = "directhit"
    end

    if configName ~= lastConfigPrinted then
        print("[LETHAL CONFIG] Active config:", configName, "Class:", class, "Weapon:", weaponClass)
        lastConfigPrinted = configName
    end

    return lethalSettings[configName], configName
end

local function singlePointESP()
local localPlayer = entities.GetLocalPlayer()
if not localPlayer then return end


	
	

    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then return end

    local localPos = localPlayer:GetAbsOrigin()
    local localTeam = localPlayer:GetTeamNumber()
    local lethalConfig, configName = getMyLethalConfig(localPlayer)

    local setDoubleTap = false
    local shouldCharge = false
    local lethalDetected = false

    for _, p in ipairs(entities.FindByClass("CTFPlayer")) do
        if p:GetIndex() == localPlayer:GetIndex() or not p:IsAlive() then
            goto continue
        end

        if p:GetTeamNumber() == localTeam then
            goto continue
        end

        if p:IsDormant() then
            goto continue
        end

        local box = p:HitboxSurroundingBox()
        if not box then goto continue end

        local mins, maxs = box[1], box[2]
        local midPos = Vector3(
            (mins.x + maxs.x) / 2,
            (mins.y + maxs.y) / 2,
            (mins.z + maxs.z) / 2
        )

        local vel = p:EstimateAbsVelocity()
        local colR, colG, colB = 0, 0, 255

        if vel then
            local predict = Vector3(midPos.x + vel.x * 0.25, midPos.y + vel.y * 0.25, midPos.z + vel.z * 0.25)
            local scrPredict = client.WorldToScreen(predict)
            local scrMid = client.WorldToScreen(midPos)
            if scrPredict and scrMid then
                draw.Color(colR, colG, colB, 255)
                draw.FilledRect(
                    scrPredict[1] - dotSize / 2,
                    scrPredict[2] - dotSize / 2,
                    scrPredict[1] + dotSize / 2,
                    scrPredict[2] + dotSize / 2
                )
                draw.Line(scrMid[1], scrMid[2], scrPredict[1], scrPredict[2])

                local health = p:GetHealth() or 0
                local dist = (midPos - localPos):Length()
                local lethalText = nil

                if configName == "heavy" then
                    if dist <= 400 and health > 250 then
                        lethalText = lethalConfig.lethalText.force
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    elseif dist <= lethalConfig.closeThreshold and health <= lethalConfig.newHealthLimit then
                        lethalText = lethalConfig.lethalText.close
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    elseif dist <= lethalConfig.lethalThreshold and health <= lethalConfig.lethalHealthLimit then
                        lethalText = lethalConfig.lethalText.lethal
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    end
                else
                    if dist <= lethalConfig.closeThreshold and health <= lethalConfig.newHealthLimit then
                        lethalText = lethalConfig.lethalText.close
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    elseif dist <= lethalConfig.lethalThreshold and health <= lethalConfig.lethalHealthLimit then
                        lethalText = lethalConfig.lethalText.lethal
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    elseif dist <= lethalConfig.lethalThreshold and health >= lethalConfig.forceHealthLimit then
                        lethalText = lethalConfig.lethalText.force
                        lethalDetected = true
                        if lethalConfig.enableDT then setDoubleTap = true end
                        shouldCharge = true
                    end
                end

                if lethalText then
                    draw.Text(scrPredict[1], scrPredict[2] + 5, lethalText)
                end
            end
        end

        if debugesp then
            local screen = client.WorldToScreen(maxs)
            if screen then
                local health = p:GetHealth() or 0
                local name = p:GetName() or "N/A"
                local wpn = p:GetPropEntity("m_hActiveWeapon")
                local wpnName = (wpn and wpn:GetClass()) or "No Weapon"
				local dist = (midPos - localPos):Length()

                draw.SetFont(myfont)
                draw.Color(colR, colG, colB, 255)
				draw.Text(screen[1], screen[2] - 15,
    string.format("%s | HP: %d | Dist: %.1f | W: %s", name, health, dist, wpnName))
            end
        end

        ::continue::
    end

    local scrW, scrH = draw.GetScreenSize()
    draw.SetFont(indicatorFont)
    if lethalDetected then
        draw.Color(0, 255, 0, 255)
        draw.Text(scrW / 2 - 40, indicatorY, "READY")
    else
        draw.Color(255, 0, 0, 255)
        draw.Text(scrW / 2 - 50, indicatorY, "NOT READY")
    end

    if shouldCharge then warp.TriggerCharge() end
    gui.SetValue("double tap", setDoubleTap and "force always" or "none")
end

callbacks.Register("Draw", "single_point_enemy_esp", singlePointESP)
