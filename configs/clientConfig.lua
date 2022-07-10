Chop = {}
ChopFnc = {} 
TriggerServerEvent("plouffe_chopshop:sendConfig")

RegisterNetEvent("plouffe_chopshop:getConfig",function(list)
	if list == nil then
		CreateThread(function()
			while true do
				Wait(0)
				Chop = nil
				ChopFnc = nil
			end
		end)
	else
		Chop = list
		ChopFnc:Start()
	end
end)