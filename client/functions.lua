local Utils = exports.plouffe_lib:Get("Utils")

function ChopFnc:Start()
    TriggerEvent('ooc_core:getCore', function(Core)
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        Chop.Player = Core.Player:GetPlayerData()

        self:RegisterAllEvents()
        self:ExportsAllZones()
    end)
end

function ChopFnc:ExportsAllZones()
    for k,v in pairs(Chop.Shops) do
        exports.plouffe_lib:Register(v)
    end
end

function ChopFnc:RegisterAllEvents()
    AddEventHandler("plouffe_lib:inVehicle", function(inVehicle,vehicleId)
        Chop.Utils.inCar = inVehicle
        Chop.Utils.carId = vehicleId
    end)

    AddEventHandler("plouffe_chopshop:chopstuff", function(p)
        ChopFnc:StartChop()
    end)

    AddEventHandler("plouffe_chopshop:scrapyard", function()
        ChopFnc:Scrap()
    end)

    AddEventHandler("plouffe_chopshop:starttow", function()
        ChopFnc:Tow()
    end)

    AddEventHandler("plouffe_chopshop:dropTow", function()
        ChopFnc:DropTow()
    end)

    AddEventHandler("plouffe_chopshop:refabShop", function()
        ChopFnc:RefabMenu()
    end)
end

function ChopFnc:GetClosestVehiclePart(vehicle)
    local currentLowestDst = 10
    local index,data = nil, {}

    Chop.Utils.ped = PlayerPedId()
    Chop.Utils.pedCoords = GetEntityCoords(Chop.Utils.ped)

    for k,v in pairs(Chop.Parts) do
        local boneIndx = GetEntityBoneIndexByName(vehicle, v.boneName)
        local boneCoords = GetWorldPositionOfEntityBone(vehicle,boneIndx)
        local dstCheck = #(Chop.Utils.pedCoords - boneCoords)

        if dstCheck <= v.maxDst and dstCheck < currentLowestDst then
            if v.side:find("wheel_") and not IsVehicleTyreBurst(vehicle, v.partId, true) then
                currentLowestDst = dstCheck
                index, data = k, v

            elseif v.side:find("door_") and not IsVehicleDoorDamaged(vehicle, v.partId) and GetIsDoorValid(vehicle, v.partId) and GetVehicleDoorAngleRatio(vehicle, v.partId) > 0.5 then
                currentLowestDst = dstCheck
                index, data = k, v
            elseif v.side:find("body_") then
                if v.side == "body_chassis" and ChopFnc:IsVehicleDestroyed(vehicle) then
                    currentLowestDst = dstCheck
                    index, data = k, v
                elseif v.side == "body_engine" and (GetVehicleDoorAngleRatio(vehicle, 4) > 0.5 and GetIsDoorValid(vehicle, 4) or true ) and not GetIsVehicleEngineRunning(vehicle) then
                    currentLowestDst = dstCheck
                    index, data = k, v
                end
            end
        end
    end

    return index, data, vehicle
end

function ChopFnc:IsVehicleDestroyed(vehicle)
    local destroyed = true

    for k,v in pairs(Chop.Parts) do
        local boneIndx = GetEntityBoneIndexByName(vehicle, v.boneName)
        local boneCoords = GetWorldPositionOfEntityBone(vehicle,boneIndx)

        if v.side:find("wheel_") and not IsVehicleTyreBurst(vehicle, v.partId, true) then
            destroyed = false
            break
        elseif v.side:find("door_") and not IsVehicleDoorDamaged(vehicle, v.partId) and GetIsDoorValid(vehicle, v.partId) then
            destroyed = false
            break
        end
    end

    return destroyed
end

function ChopFnc:Chop(k,v,c)
    ExecuteCommand("e mechanic")

    Utils:ProgressCircle({
        name = "chopping_car_part",
        duration = 30000,
        label = "Démontage en cours",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(cancelled)
        if not cancelled then
            ChopFnc:DestroyPart(k,v,c)
        end
        ExecuteCommand("e c")
    end)
end

function ChopFnc:StartChop()
    local carId, dst = Utils:GetClosestVehicle()
    if dst <= 6.0 then
        local k, v, carId = ChopFnc:GetClosestVehiclePart(carId)
        if k then
            ChopFnc:Chop(k,v,carId)
        end
    end
end

function ChopFnc:IsThisATowTruc(car)
    local model = GetEntityModel(car)

    for k,v in pairs(Chop.TowTruck) do
        if model == v.model then
            return true, v.offSet
        end
    end

    return false
end

function ChopFnc:DestroyPart(k,v,c)
    local init = GetGameTimer()
    local plate = GetVehicleNumberPlateText(c)

    ChopFnc:ControlEntity(c)

    if v.side:find("wheel_") and not IsVehicleTyreBurst(c, v.partId, true) then
        SetVehicleTyreBurst(c, v.partId, true, 1)
    elseif v.side:find("door_") and not IsVehicleDoorDamaged(c, v.partId) and GetIsDoorValid(c, v.partId) then
        SetVehicleDoorBroken(c, v.partId, 1)
    elseif v.side:find("body_") then
        if v.boneName == "chassis_dummy" and ChopFnc:IsVehicleDestroyed(c) then
            SetVehicleUndriveable(c, true)
            SetVehicleOilLevel(c, 0)
            SetVehicleBodyHealth(c, 0)
        elseif v.boneName == "engine" then
            SetVehicleUndriveable(c, true)
            SetVehicleOilLevel(c, 0)
            SetVehicleBodyHealth(c, 0)
            SetVehicleEngineOn(c,false,true,true)
        end
    end

    TriggerServerEvent("plouffe_chopshop:chopDone",{plate = plate, boneName = v.boneName},Chop.Utils.MyAuthKey)
end

function ChopFnc:CanTow()
    return not LocalPlayer.state.dead and not LocalPlayer.state.cuffed and not Chop.Utils.inCar
end

function ChopFnc:Tow()
    Chop.Utils.ped = PlayerPedId()
    Chop.Utils.pedCoords = GetEntityCoords(Chop.Utils.ped)
    local closestVehicle, dst = Utils:GetClosestVehicle()
    local isTowTruck, offset = ChopFnc:IsThisATowTruc(closestVehicle)

    if dst <= 5.0 and ChopFnc:CanTow() then
        ExecuteCommand("e mechanic")
        Utils:ProgressCircle({
            name = "towing_car",
            duration = 60000,
            label = "Remorquage en cours",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(cancelled)
            if not cancelled then
                if isTowTruck then
                    if not IsEntityAttached(closestVehicle) then
                        local vehicleToTow, vehicleDst =  Utils:GetClosestVehicle(GetOffsetFromEntityInWorldCoords(closestVehicle, offset.x, offset.y, offset.z))
                        if GetPedInVehicleSeat(vehicleToTow, -1) == 0 then
                            local towTruckCoords = GetEntityCoords(closestVehicle)
                            local carHeighAboveGround = GetEntityHeightAboveGround(vehicleToTow)
                            local shit = 0.0
                            local init = GetGameTimer()
                            local hasControl = ChopFnc:ControlEntity(vehicleToTow)

                            if hasControl and vehicleToTow ~= 0 and vehicleDst < 10.0 and (GetEntityCoords(vehicleToTow).z - carHeighAboveGround) < towTruckCoords.z + 0.425 and not IsEntityAttached(vehicleToTow) then
                                repeat
                                    shit = shit + 0.01
                                    AttachEntityToEntity(vehicleToTow, closestVehicle, 0, 0.0, -3.0, shit, 0.0, 0.0, 0.0, true, true, false, false, 0, true)
                                until (GetEntityCoords(vehicleToTow).z - carHeighAboveGround) > towTruckCoords.z + 0.425 or GetGameTimer() - init > 1000
                            end
                        end
                    end
                end
            end
            ExecuteCommand("e c")
        end)
    end
end

function ChopFnc:DropTow()
    local isTowTruck, offset
    local closestVehicle, dst = Utils:GetClosestVehicle()
    Chop.Utils.ped = PlayerPedId()
    Chop.Utils.pedCoords = GetEntityCoords(Chop.Utils.ped)
    if dst <= 5.0 and ChopFnc:CanTow() and closestVehicle and closestVehicle ~= 0 then
        ExecuteCommand("e mechanic")
        Utils:ProgressCircle({
            name = "towing_car",
            duration = 5000,
            label = "Descente du véhicule",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(cancelled)
            if not cancelled then
                local car = GetEntityAttachedTo(closestVehicle)
                isTowTruck, offset = ChopFnc:IsThisATowTruc(car)
                DetachEntity(closestVehicle, true, true)
                SetEntityCoords(closestVehicle, GetOffsetFromEntityInWorldCoords(car, offset.x, offset.y, offset.z))
            end
            ExecuteCommand("e c")
        end)
    end
end

function ChopFnc:Scrap()
    ChopFnc:ControlEntity(Chop.Utils.carId)
    Utils:ProgressCircle({
        name = "sending_car_to_scrap",
        duration = 60000,
        label = "Envoie",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(cancelled)
        if not cancelled then
            local plate = GetVehicleNumberPlateText(Chop.Utils.carId)
            DeleteEntity(Chop.Utils.carId)
            TriggerServerEvent("plouffe_chopshop:scrapedCar",{plate = plate, boneName = "car"},Chop.Utils.MyAuthKey)
        end
    end)
end

function ChopFnc:ControlEntity(e)
    local init = GetGameTimer()
    NetworkRequestControlOfEntity(e)
    while not NetworkHasControlOfEntity(e) and GetGameTimer() - init < 10000 do
        NetworkRequestControlOfEntity(e)
        Wait(0)
    end
    return NetworkHasControlOfEntity(e)
end

function ChopFnc:RefabMenu()
    exports.ooc_menu:Open(Chop.Menu.refab, function(params)
        if not params then
            return
        end

        local model = params.type
        exports.ooc_menu:Open(Chop.Menu.types, function(params)
            if not params then
                return
            end

            local type = params.type
            TriggerServerEvent("plouffe_chopshop:exangeparts", model, type, Chop.Utils.MyAuthKey)
        end)
    end)
end

function CanTowExp()
    local closestVehicle, dst = Utils:GetClosestVehicle()
    local isTowTruck, offset = ChopFnc:IsThisATowTruc(closestVehicle)

    if dst <= 5.0 and ChopFnc:CanTow() and isTowTruck then
        return true
    else
        local car = GetEntityAttachedTo(closestVehicle)
        isTowTruck, offset = ChopFnc:IsThisATowTruc(car)
        if isTowTruck then
            return true
        end
    end
    return false
end

function CanDropExp()
    local closestVehicle, dst = Utils:GetClosestVehicle()
    local isTowTruck, offset = ChopFnc:IsThisATowTruc(closestVehicle)
    local car = GetEntityAttachedTo(closestVehicle)

    if dst <= 5.0 and ChopFnc:CanTow() and not isTowTruck and car and car ~= 0 then
        return true
    end
    return false
end

exports("CanTow", CanTowExp)
exports("CanDropTow", CanDropExp)
