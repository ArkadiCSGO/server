ESX = nil
local PlayersVente = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_brinks:getArmoryWeapons', function(source, cb)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    cb(weapons)

  end)

end)

ESX.RegisterServerCallback('esx_brinks:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)

  local xPlayer = ESX.GetPlayerFromId(source)

  if removeWeapon then
   xPlayer.removeWeapon(weaponName)
  end

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = weapons[i].count + 1
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 1
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)

ESX.RegisterServerCallback('esx_brinks:removeArmoryWeapon', function(source, cb, weaponName)

  local xPlayer = ESX.GetPlayerFromId(source)

  xPlayer.addWeapon(weaponName, 1000)

  TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)

    local weapons = store.get('weapons')

    if weapons == nil then
      weapons = {}
    end

    local foundWeapon = false

    for i=1, #weapons, 1 do
      if weapons[i].name == weaponName then
        weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(weapons, {
        name  = weaponName,
        count = 0
      })
    end

     store.set('weapons', weapons)

     cb()

  end)

end)

RegisterServerEvent('esx_brinks:getStockItem')
AddEventHandler('esx_brinks:getStockItem', function(itemName, count)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('esx_brinks:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_brinks:putStockItems')
AddEventHandler('esx_brinks:putStockItems', function(itemName, count)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)

		local item = inventory.getItem(itemName)
		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		if item.count >= 0 and count <= playerItemCount then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('esx_brinks:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)

RegisterServerEvent('esx_brinks:GiveItem')
AddEventHandler('esx_brinks:GiveItem', function()
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  local Quantity = xPlayer.getInventoryItem(Config.Zones.Vente.ItemRequires).count

  if Quantity >= 20 then
    TriggerClientEvent('esx:showNotification', _source, _U('stop_npc'))
    return
  else
    local amount = Config.Zones.Vente.ItemAdd
    local item = Config.Zones.Vente.ItemDb_name
    xPlayer.addInventoryItem(item, amount)
    TriggerClientEvent('esx:showNotification', _source, 'Vous avez vidé ~g~x' .. amount .. ' DAB')
  end

end)

local function Vente(source)

  SetTimeout(Config.Zones.Vente.ItemTime, function()

    if PlayersVente[source] == true then

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local Quantity = xPlayer.getInventoryItem(Config.Zones.Vente.ItemRequires).count

    if Quantity < Config.Zones.Vente.ItemRemove then
      TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez plus de '..Config.Zones.Vente.ItemRequires_name..' à déposer.')
      PlayersVente[_source] = false
    else
      local amount = Config.Zones.Vente.ItemRemove
      local item = Config.Zones.Vente.ItemRequires
      xPlayer.removeInventoryItem(item, amount)
	  local societyAccount = nil
	  
	  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
		societyAccount = account
	  end)
	if societyAccount ~= nil then
		societyAccount.addMoney(Config.Zones.Vente.ItemPrice)
		TriggerClientEvent('esx:showNotification', _source, 'votre société a gagné ~g~'.. Config.Zones.Vente.ItemPrice)
		xPlayer.addMoney(Config.Zones.Vente.ItemPrice)
		TriggerClientEvent('esx:showNotification', _source, 'Vous avez reçu ~g~$' .. Config.Zones.Vente.ItemPrice)
	end
	  --
      --
      --
      Vente(_source)
    end

  end
end)
end

RegisterServerEvent('esx_brinks:startVente')
AddEventHandler('esx_brinks:startVente', function()

local _source = source

if PlayersVente[_source] == false then
  TriggerClientEvent('esx:showNotification', _source, '~r~Sortez et revenez dans la zone !')
  PlayersVente[_source] = false
else
  PlayersVente[_source] = true
  TriggerClientEvent('esx:showNotification', _source, '~g~Action ~w~en cours...')
  Vente(_source)
end
end)

RegisterServerEvent('esx_brinks:stopVente')
AddEventHandler('esx_brinks:stopVente', function()

local _source = source

if PlayersVente[_source] == true then
  PlayersVente[_source] = false
else
  PlayersVente[_source] = true
end
end)
