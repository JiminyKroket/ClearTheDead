CTD = {}
CTD.ScriptName = GetCurrentResourceName()
CTD.MaxStartTilWipe = 100 -- MAXIMUM VALUE ALLOWED FOR lastLogin COLMUN BEFORE USER IDENTIFIER IS WIPED FROM ALL TABLES IN CTD.DATABASETABLES
CTD.DatabaseTables = { -- SET ALL DATABASE TABLE NAME HERE AS THE KEY:['TABLE_NAME'], AND THE IDENTIFIER COLUMN AS THE VALUE:= 'IDENTIFIER_COLUMN'
    -- ['TABLE_NAME'] = 'IDENTIFIER_COLUMN'
    ['users'] = 'identifier',
    ['owned_vehicles'] = 'owner',
}
SECOND = 1
MINUTE = 60
HOUR = 60 * HOUR
DAY = 24 * HOUR
MONTH = 30 * DAY

CTD.NeededTimeToBeDead = 30 * DAY --After 30 days remove players
-- THIS INFORMATION IS NOT STORED IN A CONFIG FILE FOR MULTIPLE REASONS, JUST PUT THE INFO HERE AND LEAVE IT
-- LEAVE EVERYTHING ELSE ALONE --

AddEventHandler('onResourceStart', function(resName)
    if resName ~= GetCurrentResourceName() then
        return
    end

    --After restart check for dead people
	CTD.CheckWipe()
end)

--Checking for wipe
CTD.CheckWipe = function()
	local preparedQuery = string.format('SELECT * FROM `%s` WHERE `lastLogin` > @lastWipe', CTD.DatabaseTables['users'])
	MySQL.Async.fetchAll(preparedQuery, {
		['@lastWipe'] = os.time()-CTD.NeededTimeToBeDead
	}, function(data)
		if data == nil then
			print('[%s] Cannot search players, please check if you install this script correctly!', GetCurrentResourceName())
			return
		end

		if data[1] ~= nil then
			print('[%s] Find dead players, starting removing process!', GetCurrentResourceName())
			for _, user in pairs(data) do
				CTD.WipePlayer(user.identifier)
			end
		else
			print('[%s] Dont find any people to wipe, your server is really good!', GetCurrentResourceName())
		end
	end)
end

CTD.WipePlayer = function(id)
    for k, v in pairs(CTD.DatabaseTables) do
        MySQL.Async.execute('DELETE FROM `' .. k .. '` WHERE `' .. v .. '` = @id', { ['@id'] = id })
    end
    print('[' .. CTD.ScriptName .. '] : Visit spindlescripts.com & rcore.cz to support development')
    print('[' .. CTD.ScriptName .. '] : Wiped player with identifier: ' .. id)
end

CTD.PlayerLogged = function()
    local IdentifierList = GetPlayerIdentifiers(source)
    MySQL.Async.fetchAll('SELECT `identifier` FROM `users`', {}, function(users)
        for i = 1, #users do
            for k, v in ipairs(IdentifierList) do
                if v:match(users[i].identifier) then
                    print('[' .. CTD.ScriptName .. '] : Visit spindlescripts.com & rcore.cz to support development')
                    print('[' .. CTD.ScriptName .. '] : Setting player with identifier: ' .. users[i].identifier .. ' lastLogin value to 0')
                    MySQL.Async.execute('UPDATE `users` SET `lastLogin` = CURRENT_TIMESTAMP WHERE `' .. CTD.DatabaseTables['users'] .. '` = @id', { ['@id'] = users[i].identifier })
                    break
                end
            end
        end
    end)
end

RegisterNetEvent('CTD:LoggedIn')
AddEventHandler('CTD:LoggedIn', CTD.PlayerLogged)