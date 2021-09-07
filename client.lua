
local config = {
        position = vector3(0.11, 0, 0.015),
        rotation = vector3(0, 0, 0),
        model = `s_antiquerevolver01x`
}

local flintlock

local function GetPedCurrentWeaponEntityIndex(ped, p1)
        return Citizen.InvokeNative(0x3B390A939AF0B5FC, ped, p1)
end

local function GiveWeaponToPed(ped, weaponHash, ammoCount, bForceInHand, bForceInHolster, attachPoint, bAllowMultipleCopies, p7, p8, addReason, bIgnoreUnlocks, p11, p12)
        return Citizen.InvokeNative(0x5E3BDDBCB83F3D84, ped, weaponHash, ammoCount, bForceInHand, bForceInHolster, attachPoint, bAllowMultipleCopies, p7, p8, addReason, bIgnoreUnlocks, p11, p12)
end

local function SetPedWeaponAmmoType(ped, weaponHash, ammoHash)
        return Citizen.InvokeNative(0xCC9C4393523833E2, ped, weaponHash, ammoHash)
end

local function cleanWeapon(weapon)
        Citizen.InvokeNative(0xA7A57E89E965D839, weapon, 0.0)
        Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weapon, 0.0)
        Citizen.InvokeNative(0x812CE61DEBCAB948, weapon, 0.0)
        Citizen.InvokeNative(0xE22060121602493B, weapon, 0.0)
end

local function dirtyWeapon(weapon)
        Citizen.InvokeNative(0xA7A57E89E965D839, weapon, 1.0)
        Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weapon, 1.0)
        Citizen.InvokeNative(0x812CE61DEBCAB948, weapon, 1.0)
        Citizen.InvokeNative(0xE22060121602493B, weapon, 1.0)
end

local function loadModel(model)
        if not IsModelInCdimage(model) then
                return false
        end

        RequestModel(model)

        while not HasModelLoaded(model) do
                Citizen.Wait(0)
        end

        return true
end

local function giveWeaponToPed(ped)
        GiveWeaponToPed(ped, `WEAPON_PISTOL_VOLCANIC`, 100, true, false, 0, true, 0.0, 0.0, 0, true, 0.0, false)

        local timeout = GetGameTimer() + 1000
        local weapon

        while not weapon and GetGameTimer() < timeout do
                weapon = GetPedCurrentWeaponEntityIndex(ped, 0)
                Citizen.Wait(0)
        end

        return weapon
end

local function createFlintlock()
        local playerPed = PlayerPedId()

        local weapon = giveWeaponToPed(playerPed)

        if not weapon then
                return
        end

        if not loadModel(config.model) then
                return
        end

        SetEntityAlpha(weapon, 0)
        dirtyWeapon(weapon)

        local flintlock = CreateObject(config.model, 0.0, 0.0, 0.0, true, true, false)
        SetModelAsNoLongerNeeded(config.model)

        AttachEntityToEntity(flintlock, weapon, 0, config.position, config.rotation, false, false, false, false, 0, true, false, false)

        return flintlock
end

local function deleteFlintlock(flintlock)
        local weapon = GetEntityAttachedTo(flintlock)
        DeleteObject(flintlock)
        cleanWeapon(weapon)
        DeleteObject(weapon)
end

RegisterNetEvent("flintlock", function()
        if flintlock and not DoesEntityExist(flintlock) then
                flintlock = nil
        end

        if flintlock and not IsEntityAttached(flintlock) then
                deleteFlintlock(flintlock)
                flintlock = nil
        end

        if flintlock then
                deleteFlintlock(flintlock)
                flintlock = nil
        else
                flintlock = createFlintlock()
        end
end)

AddEventHandler("onResourceStop", function(resourceName)
        if GetCurrentResourceName() == resourceName and flintlock then
                deleteFlintlock(flintlock)
        end
end)

Citizen.CreateThread(function()
        TriggerEvent("chat:addSuggestion", "/flintlock", "Equip a flintlock pistol")
end)
