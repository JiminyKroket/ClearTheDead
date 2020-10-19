CTD = {}

CTD.Init = function()
	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Citizen.Wait(100) end
	TriggerServerEvent('CTD:LoggedIn')
end

Citizen.CreateThread(CTD.Init)