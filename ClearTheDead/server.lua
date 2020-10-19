CTD = {}
CTD.ScriptName = GetCurrentResourceName()
CTD.MaxStartTilWipe = 100 -- MAXIMUM VALUE ALLOWED FOR NOLOG COLMUN BEFORE USER IDENTIFIER IS WIPED FROM ALL TABLES IN CTD.DATABASETABLES
CTD.DatabaseTables = { -- SET ALL DATABASE TABLE NAME HERE AS THE KEY:['TABLE_NAME'], AND THE IDENTIFIER COLUMN AS THE VALUE:= 'IDENTIFIER_COLUMN'
	-- ['TABLE_NAME'] = 'IDENTIFIER_COLUMN'
	['users'] = 'identifier',
	['owned_vehicles'] = 'owner',
}
-- THIS INFORMATION IS NOT STORED IN A CONFIG FILE FOR MULTIPLE REASONS, JUST PUT THE INFO HERE AND LEAVE IT
-- LEAVE EVERYTHING ELSE ALONE --

CTD.Init = function()
	print('['..CTD.ScriptName..'] : Visit spindlescripts.com to support development')
	print('['..CTD.ScriptName..'] : Increasing user noLog values')
	MySQL.Async.execute('UPDATE `users` SET `noLog` = `noLog`+1',{},function(change)
		if change then
			Citizen.Wait(100)
			MySQL.Async.fetchAll('SELECT `noLog`,`identifier` FROM `users`', {}, function(users)
				for i = 1,#users do
					if users[i].noLog > CTD.MaxStartTilWipe then
						CTD.WipePlayer(users[i].identifier)
					end
				end
			end)
			print('['..CTD.ScriptName..'] : Visit spindlescripts.com to support development')
			print('['..CTD.ScriptName..'] : Checking players gone for more than '..CTD.MaxStartTilWipe..' script starts')
		end
	end)
end

CTD.WipePlayer = function(id)
	for k,v in pairs(CTD.DatabaseTables) do
		MySQL.Async.execute('DELETE FROM `'..k..'` WHERE `'..v..'` = @id',{['@id'] = id})
	end
	print('['..CTD.ScriptName..'] : Visit spindlescripts.com to support development')
	print('['..CTD.ScriptName..'] : Wiped player with identifier: '..id)
end

CTD.PlayerLogged = function()
	local IdentifierList = GetPlayerIdentifiers(source)
	MySQL.Async.fetchAll('SELECT `identifier` FROM `users`', {}, function(users)
		for i = 1,#users do
			for k,v in ipairs(IdentifierList) do
				if v:match(users[i].identifier) then
					print('['..CTD.ScriptName..'] : Visit spindlescripts.com to support development')
					print('['..CTD.ScriptName..'] : Setting player with identifier: '..users[i].identifier..' noLog value to 0')
					MySQL.Async.execute('UPDATE `users` SET `noLog` = 0 WHERE `'..CTD.DatabaseTables['users']..'` = @id',{['@id'] = users[i].identifier})
					break
				end
			end
		end
	end)
end

RegisterNetEvent('CTD:LoggedIn')
AddEventHandler('CTD:LoggedIn', CTD.PlayerLogged)

Citizen.CreateThread(CTD.Init)