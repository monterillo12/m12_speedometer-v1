ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local MinHitDmg     = 200

local isDriving     = false
local isEngineOn    = false
local belt, cruiser = false, false

local healthBuffer  = {}
local isBlackedOut  = false

local w             = 2000

CreateThread(function()

    local vehicle

    while true do
    
        Wait(w)

        local ped   = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
        isDriving   = IsPedInAnyVehicle(ped, false)
        isEngineOn  = GetIsVehicleEngineRunning(vehicle)

        -- Si comienza a conducir y el motor esta encendido
        if isDriving == 1 and isEngineOn == 1 then

            if w ~= 50 then
                w = 50
                SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
                DisplayRadar(true)
                SendNUIMessage({action = 'show'})
                startBlackOut()
            end

            local speed                = math.floor(GetEntitySpeed(vehicle) * 3.6)
            local gear                 = GetVehicleCurrentGear(vehicle)
            local fuel                 = math.ceil(GetVehicleFuelLevel(vehicle) or 0)
            local health               = math.floor(GetVehicleEngineHealth(vehicle) / 10)
            local indicators           = GetVehicleIndicatorLights(vehicle)
            local _,lightson,highbeams = GetVehicleLightsState(vehicle)

            SendNUIMessage({
                action     = 'tick',
                speed      = speed,
                gear       = gear,
                fuel       = fuel,
                health     = health,
                belt       = belt,
                indicators = indicators,
                lightson   = lightson,
                highbeams  = highbeams,
            })

        -- En caso de que baje o se caiga del vehiculo
        else

            if w ~= 2000 then
                w = 2000
                SendNUIMessage({action = 'hide'})
                DisplayRadar(false)
                cruiser = false
                belt    = false
                vehicle = nil
            end

        end

    end
end)

RegisterKeyMapping('*togglebelt', 'Seat Belt', 'keyboard', 'b')
RegisterCommand('*togglebelt', function()
    if belt then
        belt = false
    else
        local vehicleClass = GetVehicleClass(GetVehiclePedIsIn(PlayerPedId(), false))
        if vehicleClass ~= 8 and vehicleClass ~= 13 and vehicleClass ~= 14 and vehicleClass ~= 15 and vehicleClass ~= 16 then
            belt = true
        end
    end
end)

RegisterKeyMapping('*togglecruiser', 'Cruise control', 'keyboard', 'capital')
RegisterCommand('*togglecruiser', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle or vehicle == 1 then
        if cruiser then
            SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
        else
            SetEntityMaxSpeed(vehicle, GetEntitySpeed(vehicle))
        end
        cruiser = not cruiser
    end
end)

function blackout()
    
	if not isBlackedOut then

		isBlackedOut = true

        local vehicle = GetVehiclePedIsUsing(PlayerPedId(),false)
        SetVehicleEngineOn(vehicle, false, true, true)

        DoScreenFadeOut(100)
        StartScreenEffect('DeathFailOut', 0, true)
        SetTimecycleModifier("hud_def_blur")
        Wait(1000)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(1000)
        Wait(1000)

        DoScreenFadeOut(100)
        Wait(750)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(750)
        Wait(750)

        DoScreenFadeOut(100)
        Wait(500)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
        DoScreenFadeIn(500)
        Wait(500)

        DoScreenFadeOut(100)
        Wait(250)
        DoScreenFadeIn(250)
        isBlackedOut = false

        SetTimecycleModifier('BarryFadeOut')
        SetTimecycleModifierStrength(math.min(0.1 / 10, 0.6))
        
        SetTimecycleModifier("REDMIST_blend")
        ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)
        Wait(3000)
                
        SetTimecycleModifier("hud_def_desat_Trevor")
        
        Wait(1000)
        
        SetTimecycleModifier("")
        SetTransitionTimecycleModifier("")
        StopGameplayCamShaking()
        StopScreenEffect('DeathFailOut')

        SetVehicleEngineOn(vehicle, true, false, true)

	end
end

function calcDistance(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return {x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0}
end

function startBlackOut()
    CreateThread(function()
        while isDriving do

            Wait(50)
            local ped = PlayerPedId()

            local pedVeh    = GetVehiclePedIsIn(ped, false)
            local vc        = GetVehicleClass(pedVeh)
            healthBuffer[2] = healthBuffer[1]
            healthBuffer[1] = GetVehicleEngineHealth(pedVeh)
            
            if (healthBuffer[2] ~= nil) and (healthBuffer[2] - healthBuffer[1]) > MinHitDmg then
                
                if vc ~= 8 or vc ~= 13 or vc ~= 14 or vc ~= 15 or vc ~= 16 then

                    isDriving  = false
                    isEngineOn = false
                    healthBuffer[1] = nil
                    healthBuffer[2] = nil

                    if not belt then

                        local coords = GetEntityCoords(ped)
                        local throw = calcDistance(ped)

                        if (IsVehicleWindowIntact(pedVeh, 6)) then
                            SmashVehicleWindow(pedVeh, 6)
                        end

                        SetEntityCoords(ped, coords.x + throw.x, coords.y + throw.y, coords.z-0.47, true, true, true)
                        Wait(1)
                        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
                    else
                        blackout()
                    end

                end
            end

        end
    end)
end