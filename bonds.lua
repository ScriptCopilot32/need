pcall(function()
    workspace.StreamingEnabled = false
    workspace.SimulationRadius = math.huge
end)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")

local player   = Players.LocalPlayer
local char     = player.Character or player.CharacterAdded:Wait()
local hrp      = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local networkFolder    = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network")
local RemotePromiseMod = require(networkFolder:WaitForChild("RemotePromise"))
local ActivatePromise  = RemotePromiseMod.new("ActivateObject")

local remotesRoot       = ReplicatedStorage:WaitForChild("Remotes")
local EndDecisionRemote = remotesRoot:WaitForChild("EndDecision")

local queue_on_tp = (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport)

local bondData = {}
local seenKeys = {}

local function recordBonds()
    local runtime = Workspace:WaitForChild("RuntimeItems")
    for _, item in ipairs(runtime:GetChildren()) do
        if item.Name:match("Bond") then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                local key = ("%.1f_%.1f_%.1f"):format(
                    part.Position.X, part.Position.Y, part.Position.Z
                )
                if not seenKeys[key] then
                    seenKeys[key] = true
                    table.insert(bondData, { item = item, pos = part.Position, key = key })
                end
            end
        end
    end
end

print("=== Starting map scan ===")
local scanTarget = CFrame.new(-424.448975, 26.055481, -49040.6562, -1,0,0, 0,1,0, 0,0,-1)
local scanSteps = 50 --If you make this higher the scan maybe detects more bonds idk 
for i = 1, scanSteps do
    hrp.CFrame = hrp.CFrame:Lerp(scanTarget, i/scanSteps)
    task.wait(0.3)
    recordBonds()
    task.wait(0.1)
end
hrp.CFrame = scanTarget
task.wait(0.3)
recordBonds()

print(("→ %d Bonds found"):format(#bondData))
if #bondData == 0 then
    warn("No Bonds found – check Runtime Items shit")
    return
end

local chair = Workspace:WaitForChild("RuntimeItems"):FindFirstChild("Chair")
assert(chair and chair:FindFirstChild("Seat"), "Chair.Seat not found")
local seat = chair.Seat

seat:Sit(humanoid)
task.wait(0.2)
assert(humanoid.SeatPart == seat, "Seat error")

for idx, entry in ipairs(bondData) do
    print(("--- Bond %d/%d: %s ---"):format(idx, #bondData, entry.key))

    local targetCFrame = CFrame.new(entry.pos) * CFrame.new(0, 2, 0)
    seat:PivotTo(targetCFrame)
    task.wait(0.05)

    if humanoid.SeatPart ~= seat then
        seat:Sit(humanoid)
        task.wait(0.05)
    end

    ActivatePromise:InvokeServer(entry.item)
    task.wait(0.1) --When it warns "Not collecting", increase this to give more time

    if not entry.item.Parent then
        print("Bond collected")
    else
        warn("Increase timeout when not collecting")
    end
end

humanoid:TakeDamage(999999)
EndDecisionRemote:FireServer(false)

if queue_on_tp then
    queue_on_tp(game:HttpGet('https://raw.githubusercontent.com/ScriptCopilot32/need/refs/heads/main/bonds.lua'))
end

print("=== Script finished ===")
