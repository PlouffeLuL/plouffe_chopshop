function ChopFnc:GiveItemOnChopDone(playerId,data)
    if not data.plate then
        return
    end

    if not Server.ChoppedCars[data.plate] then
        Server.ChoppedCars[data.plate] = {}
        for k,v in pairs(Chop.Parts) do
            Server.ChoppedCars[data.plate][v.boneName] = false
        end
    end
    if not Server.ChoppedCars[data.plate][data.boneName] then
        Server.ChoppedCars[data.plate][data.boneName] = true
        for k,v in pairs(Chop.Rewards[data.boneName]) do
            local itemName = ChopFnc:GetQuality(v.item)
            if itemName:find("_") and math.random(0,100) > 75 then 
                exports.ooc_core:addItem(playerId,itemName,v.amount)
                break
            else
                exports.ooc_core:addItem(playerId,itemName,v.amount)
            end
        end
    else
        TriggerClientEvent("plouffe_lib:notify", playerId, {type = "error", txt = "Cette piece a deja été retiré de ce véchiule"})
    end
end

function ChopFnc:GetQuality(item)
    if item == "plastic" or item == "steel" or item == "money" then
        return item
    else
        local qualityRandom = math.random(1,100)
        if qualityRandom > 70 then
            return item.."_s"
        elseif qualityRandom > 55 then
            return item.."_a"
        elseif qualityRandom > 35 then
            return item.."_b"
        elseif qualityRandom > 20 then
            return item.."_c"
        else 
            return item.."_d"
        end
    end
end

function ChopFnc:ExangeParts(playerId,item,type)
    local newModel = Chop.RefabClass[type]
    local newItem = item.."_"..newModel
    local oldItem = item.."_"..type
    local oldCount = exports.ooc_core:getItemCount(playerId,oldItem)
    
    if oldCount >= 5 then
        exports.ooc_core:removeItem(playerId,oldItem,5)
        exports.ooc_core:addItem(playerId,newItem,1)
    end
end 