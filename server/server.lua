ESX = nil 
QBCore = nil 

if Config.Framework == "ESX" then 
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "QB" then
	QBCore = exports['qb-core']:GetCoreObject()
end 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Interval)
        local xPlayers = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            local totalDues = 0
            totalDues = totalDues + getVehicleTax(xPlayer)
            totalDues = totalDues + getCellPhoneContactCosts(xPlayer)
            totalDues = totalDues + getPropertyTaxes(xPlayer)
            totalDues = totalDues + getBankingTaxes(xPlayer)

            if totalDues > 0 then 
                if removePlayerMoney(xPlayer, totalDues) then 
                    sendMoneyToSociety(totalDues)
                    notify(xPlayer, Config.Translations[Config.Locale].payed .. " $" .. totalDues)
                else
                    notify(xPlayer, Config.Translations[Config.Locale].not_enought_money .. " $" .. totalDues)
                end 
            end 
        end
    end
end)


function getBankingTaxes(xPlayer) 
    local retval = 0
    if Config.ExpenseTypes.BankingTax then 
        local identifier = getPlayerIdentifier(xPlayer)

        for k,v in Config.BankingTaxes do
            if v.use then 
                local taxPer = v.payment

                local data = {}
                local query = v.sql
                data = MySQL.Sync.fetchAll(query, {
                    ["@identifier"] = identifier
                })
                retval = retval + (#data * taxPer)
            end 
        end
    end 
    return retval    
end 
function getPropertyTaxes(xPlayer) 
    local retval = 0
    if Config.ExpenseTypes.PropertyTax then 
        local identifier = getPlayerIdentifier(xPlayer)

        for k,v in Config.PropertyTaxes do
            if v.use then 
                local taxPer = v.payment

                local data = {}
                local query = v.sql
                data = MySQL.Sync.fetchAll(query, {
                    ["@identifier"] = identifier
                })
                retval = retval + (#data * taxPer)
            end 
        end
    end 
    return retval    
end 

function getCellPhoneContactCosts(xPlayer)
    local retval = 0

    if Config.ExpenseTypes.CellphoneContract then 
        for k,v in pairs(Config.CellPhoneContracts) do 
            local itemcnt = getPlayerItemCount(xPlayer, v.itemname)

            if itemcnt > 0 then 
                retval = retval + (itemcnt * v.payment)
            end 
        end
    end     
    return retval 
end 

function getVehicleTax(xPlayer)
    local query = ""
    local identifier = getPlayerIdentifier(xPlayer)
    local retval = 0

    if Config.ExpenseTypes.VehicleTax then 
        if Config.Framework == "ESX" then 
            query = "SELECT * FROM owned_vehicles where owner = @identifier"

            local data = MySQL.Sync.fetchAll(query,{
                ["@identifier"] = identifier
            })

            for k,v in pairs(data) do 
                local json = json.decode(v.vehicle)
                local model = json.model

                retval = retval + getTaxByVehicleModel(model)
            end 

        elseif Config.Framework == "QB" then 
            query = "SELECT * FROM player_vehicles where citizenid = @identifier"

            local data = MySQL.Sync.fetchAll(query,{
                ["@identifier"] = identifier
            })

            for k,v in pairs(data) do 
                local model = v.hash
                retval = retval + getTaxByVehicleModel(model)
            end 
        end 
    end 

    return retval
end 


function getPlayerBySource(_source)
    if Config.Framework == "ESX" then 
        return ESX.GetPlayerFromId(_source)
	elseif Config.Framework == "QB" then 
        return QBCore.Functions.GetPlayer(_source)
    end 
end 


function getPlayerIdentifier(xPlayer)
	if Config.Framework == "ESX" then 
		return xPlayer.identifier
	else 
		return xPlayer.PlayerData.citizenid
	end 
end 

function getTaxByVehicleModel(model)
    if model ~= nil then 
        return 0 
    end 
    return Config.VehicleTaxByModel[model] or Config.DefaultVehicleTax
end 

function getPlayerItemCount(xPlayer, itemname)
    if Config.Framework == "ESX" then 
        return xPlayer.getInventoryItem(itemname).count or 0
    elseif Config.Framework == "QB" then 
        return xPlayer.Functions.GetItemByName(itemname).count or 0
    end 
end 



function getAllPlayers()
    if Config.Framework == "ESX" then 
        return ESX.GetExtendedPlayers()

    elseif Config.Framework == "QB" then 
        return QBCore.Functions.GetPlayers()
    end 
end 


function notify(xPlayer, message)
    if Config.Framework == "ESX" then 
        TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, Config.Translations[Config.Locale].esx_messagesender , Config.Translations[Config.Locale].esx_messagesubject, message, 'CHAR_BANK_MAZE', 9)
    elseif Config.Framework == "QB" then 
        TriggerClientEvent('QBCore:Notify', xPlayer.PlayerData.source, message)
    end 
end 

function removePlayerMoney(xPlayer, amount)
    if Config.Framework == "ESX" then 
        if xPlayer.getAccountMoney("bank") < amount then 
            return false
        end
        xPlayer.removeAccountMoney('bank', amount)
    elseif Config.Framework == "QB" then 
        if xPlayer.Functions.GetMoney("bank") < amount then 
            return false
        end 
        xPlayer.Functions.RemoveMoney('bank', amount)
    end 

    return true
end 


function sendMoneyToSociety(amount)
    if Config.DestinationSociety == nil or Config.DestinationSociety == "" then 
        return 
    end 

    if Config.Framework == "ESX" then 
        TriggerEvent('esx_addonaccount:getSharedAccount', Config.DestinationSociety, function (account)
            account.addMoney(amount)
        end)
    elseif Config.Framework == "QB" then 
        exports["qs-management"]:AddMoney(Config.DestinationSociety, amount)
    end 
end 

