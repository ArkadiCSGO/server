ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_worek:closest')
AddEventHandler('esx_worek:closest', function()
    local name = GetPlayerName(najblizszy)
    TriggerClientEvent('esx_worek:nalozNa', najblizszy)
end)

RegisterServerEvent('esx_worek:sendclosest')
AddEventHandler('esx_worek:sendclosest', function(closestPlayer)
    najblizszy = closestPlayer
end)

RegisterServerEvent('esx_worek:zdejmij')
AddEventHandler('esx_worek:zdejmij', function()
    TriggerClientEvent('esx_worek:zdejmijc', najblizszy)
end)

ESX.RegisterUsableItem('headbag', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx_worek:naloz', _source)
    TriggerEvent('esx_worek:debugger', source)
end)

ESX.RegisterServerCallback('NB:getUsergroup', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local group = xPlayer.getGroup()
  cb(group)
end)

function getMaximumGrade(jobname)
    local result = MySQL.Sync.fetchAll("SELECT * FROM job_grades WHERE job_name=@jobname  ORDER BY `grade` DESC ;", {
        ['@jobname'] = jobname
    })
    if result[1] ~= nil then
        return result[1].grade
    end
    return nil
end

RegisterServerEvent("SyncAnnonce")
AddEventHandler('SyncAnnonce', function(inputText)
TriggerClientEvent('DisplayAnnonce', -1, inputText)
end)

RegisterServerEvent("SyncPurge")
AddEventHandler('SyncPurge', function(inputText)
TriggerClientEvent('DisplayPurge', -1, inputText)
end)

-------------------------------------------------------------------------------Admin Menu

-- ME COMMAND (/me [Message]) Outcomes: Name Message (All in purple)
TriggerEvent('es:addCommand', 'me', function(source, args, user)
    table.remove(args, 1)
    local pname = GetPlayerName(source)
    TriggerClientEvent("sendProximityMessageMe", -1, source, pname, table.concat(args, " "))
end, function(source, args, user)
    TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

RegisterServerEvent("AdminMenu:giveCash")
AddEventHandler("AdminMenu:giveCash", function(money)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addMoney((total))
	local item = ' $ d\'argent !'
	local message = 'Tu t\'est GIVE '
	TriggerClientEvent('esx:showNotification', _source, message.." "..total.." "..item)

end)

RegisterServerEvent("AdminMenu:giveBank")
AddEventHandler("AdminMenu:giveBank", function(money)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('bank', total)
	local item = ' $ en banque.'
	local message = 'Tu t\'es octroyé '
	TriggerClientEvent('esx:showNotification', _source, message.." "..total.." "..item)

end)

RegisterServerEvent("AdminMenu:giveDirtyMoney")
AddEventHandler("AdminMenu:giveDirtyMoney", function(money)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('black_money', total)
	local item = ' $ d\'argent sale.'
	local message = 'Tu t\'es octroyé '
	TriggerClientEvent('esx:showNotification', _source, message.." "..total.." "..item)

end)

-------------------------------------------------------------------------------Grade Menu
RegisterServerEvent('NB:promouvoirplayer')
AddEventHandler('NB:promouvoirplayer', function(target)

	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local maximumgrade = tonumber(getMaximumGrade(sourceXPlayer.job.name)) -1 

	if(targetXPlayer.job.grade == maximumgrade)then
		TriggerClientEvent('esx:showNotification', _source, "Vous devez demander une autorisation du ~r~Gouvernement~w~.")
	else
		if(sourceXPlayer.job.name == targetXPlayer.job.name)then

			local grade = tonumber(targetXPlayer.job.grade) + 1 
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~promu "..targetXPlayer.name.."~w~.")
			TriggerClientEvent('esx:showNotification', target,  "Vous avez été ~g~promu par ".. sourceXPlayer.name.."~w~.")		

		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")

		end

	end 
		
end)

RegisterServerEvent('NB:destituerplayer')
AddEventHandler('NB:destituerplayer', function(target)

	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if(targetXPlayer.job.grade == 0)then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ davantage.")
	else
		if(sourceXPlayer.job.name == targetXPlayer.job.name)then

			local grade = tonumber(targetXPlayer.job.grade) - 1 
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé "..targetXPlayer.name.."~w~.")
			TriggerClientEvent('esx:showNotification', target,  "Vous avez été ~r~rétrogradé par ".. sourceXPlayer.name.."~w~.")		

		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")

		end

	end 
		
end)

RegisterServerEvent('NB:recruterplayer')
AddEventHandler('NB:recruterplayer', function(target, job, grade)

	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	
		targetXPlayer.setJob(job, grade)

		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté "..targetXPlayer.name.."~w~.")
		TriggerClientEvent('esx:showNotification', target,  "Vous avez été ~g~embauché par ".. sourceXPlayer.name.."~w~.")		

end)

RegisterServerEvent('NB:virerplayer')
AddEventHandler('NB:virerplayer', function(target)

	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"

	if(sourceXPlayer.job.name == targetXPlayer.job.name)then
		targetXPlayer.setJob(job, grade)

		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré "..targetXPlayer.name.."~w~.")
		TriggerClientEvent('esx:showNotification', target,  "Vous avez été ~g~viré par ".. sourceXPlayer.name.."~w~.")	
	else

		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")

	end

end)