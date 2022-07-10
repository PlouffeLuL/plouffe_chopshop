RegisterNetEvent("plouffe_chopshop:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    if registred then
        local cbArray = Chop
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_chopshop:getConfig",playerId,cbArray)
    else
        TriggerClientEvent("plouffe_chopshop:getConfig",playerId,nil)
    end
end)

RegisterNetEvent("plouffe_chopshop:chopDone",function(data,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) then
        if Auth:Events(playerId,"plouffe_chopshop:chopDone") then
            ChopFnc:GiveItemOnChopDone(playerId,data)
        end
    end
end)

RegisterNetEvent("plouffe_chopshop:scrapedCar",function(data,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) then
        if Auth:Events(playerId,"plouffe_chopshop:scrapedCar") then
            ChopFnc:GiveItemOnChopDone(playerId,data)
        end
    end
end)

RegisterNetEvent("plouffe_chopshop:exangeparts",function(model,type,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) then
        if Auth:Events(playerId,"plouffe_chopshop:exangeparts") then
            ChopFnc:ExangeParts(playerId,model,type)
        end
    end
end)