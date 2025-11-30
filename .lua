-- NORTHWIND MOBILE KILL AURA (REAL DAMAGE) - DELTA SAFE

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local me = Players.LocalPlayer

local remote = RS.DefinEvents.InstanceRequestFunction
local function invoke(...) return remote:InvokeServer(...) end

-- GC SCAN (SMALL + MOBILE SAFE)
local wrap, weapons, dmgTable, getPlayer
for _,v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        if v.Wrap then wrap = v end
        if v.Cutlass and v["Boarding axe"] then weapons = v end
        if v.OnDamaged then dmgTable = v end
        if v.GetPlayer then getPlayer = v end
    end
end

local OnDamaged = dmgTable.OnDamaged

local function getEquipped()
    return getPlayer:GetPlayer():GetSelectedToolItem()
end

local function constants(name)
    local w = weapons[name]
    return w and w.Constants
end

local KA = false
local TP = false
local RANGE = 12

local function hitPacket(root)
    return {
        HitPart = root,
        Position = root.Position,
        Normal = Vector3.new(0,1,0),
        Material = Enum.Material.Plastic
    }
end

local function getTarget()
    local char = me.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local mypos = hrp.Position
    local best, dist = nil, RANGE

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= me and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (mypos - plr.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                local w = wrap:Wrap(plr)
                if w.Health > 0 then
                    best = plr
                    dist = d
                end
            end
        end
    end

    return best
end

task.spawn(function()
    while task.wait() do
        if KA then
            local eq = getEquipped()
            if not eq then continue end

            local model = eq[1]
            local name = eq[2]
            local data = constants(name)
            if not data then continue end

            local target = getTarget()
            if not target then continue end

            local root = target.Character.HumanoidRootPart
            if TP then
                me.Character.HumanoidRootPart.CFrame = root.CFrame
            end

            invoke(model, "SetDirection", "Right")
            invoke(model, "Charge")
            task.wait(data.ChargeDelay * 0.6)
            invoke(model, "BeginSwing")
            task.wait(data.SwingDelay * 0.6)
            invoke(model, "EndSwing", target)

            -- REAL DAMAGE
            OnDamaged(dmgTable, hitPacket(root), model)
        end
    end
end)

UIS.InputBegan:Connect(function(input, g)
    if g then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        KA = not KA
        print("Kill Aura:", KA)
    end
end)

print("NW Kill Aura Loaded. Toggle with ';'")
