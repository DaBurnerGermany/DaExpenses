Config={}
Config.Framework = "ESX" -- ESX or QB
Config.DestinationSociety = nil --society which gains the money
Config.Interval = 10 * 60 * 1000 --all 10 minutes .. 

Config.Locale = "de"

--[[
only ESX
find icons here... https://wiki.rage.mp/index.php?title=Notification_Pictures
]]--
Config.MessageIcon = "CHAR_BANK_MAZE" 


Config.ExpenseTypes = {
    VehicleTax = true,
    BankingTax = true,
    PropertyTax = true,
    CellphoneContract = true
}

--here write the correct sql here are examples
Config.BankingTaxes = {
    {use = true, payment = 40, sql = "SELECT * FROM bank_accounts WHERE citizenid=@identifier"},
    {use = true, payment = 10, sql = "SELECT * FROM bank_cards WHERE citizenid=@identifier and cardActive=1"}
}

--here write the correct sql here are examples.. identifier is on ESX the identifier and on qb it'll be replaced with the citizenid
Config.PropertyTaxes = {
    {use = false, payment = 100, sql = "SELECT * FROM player_houses where citizenid = @identifier"}, --qs housing qb .. 
    {use = true, payment = 100, sql = "SELECT * FROM player_houses where identifier = @identifier"}, --qs housing esx .. 
    {use = true, payment = 20, sql = "select * from player_houses where citizenid = @identifier"}, --qb houses .. 
    {use = true, payment = 20, sql = "select * from apartments where citizenid = @identifier"}, --qb aparentments .. 
    {use = true, payment = 20, sql = "SELECT * FROM renzu_motels where owned = @identifier"}, --renzu_motels .. 
    {use = false, payment = 40, sql = "SELECT * FROM prop_owner where owner = @identifier"}, --myProperties .. 
}

--here add the playeritems to be taxed 
Config.CellPhoneContracts = {
    {itemname = "phone", payment = 10},
}


Config.DefaultVehicleTax = 10
--if you want sth different from Config.DefaultVehicleTax
Config.VehicleTaxByModel = {
	["adder"] = 200,
	--["blista"] = 400,
}

for k,v in pairs(Config.VehicleTaxByModel) do 
    Config.VehicleTaxByModel[GetHashKey(k)] = v
end   


--here translations..
Config.Translations = {
    de = {
        not_enought_money = "Du kannst deine Abgaben nicht zahlen!"
        ,payed = "Deine Abgaben wurden von deinem Konto abgezogen!"
        ,esx_messagesender = "Steuerbüro"
        ,esx_messagesubject = "Steuern"
    },
    en = {
        not_enought_money = "You can't pay your dues!"
        ,payed = "Your taxes have been deducted from your account!"
        ,esx_messagesender = "Tax agency"
        ,esx_messagesubject = "Tax info"
    }
}