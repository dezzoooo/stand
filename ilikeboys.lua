-- _____     ______     ______     ______     ______    
--/\  __-.  /\  ___\   /\___  \   /\___  \   /\  __ \   
--\ \ \/\ \ \ \  __\   \/_/  /__  \/_/  /__  \ \ \/\ \  
-- \ \____-  \ \_____\   /\_____\   /\_____\  \ \_____\ 
--  \/____/   \/_____/   \/_____/   \/_____/   \/_____/ 
                                                         

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")


local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local following = false
local targetPlayer = nil
local offset = Vector3.new(2, 2.5, -3) 
local standMode = "default" 
local smoothness = 0.1 


local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StandExecutorGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "CommandBarFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 40)
mainFrame.Position = UDim2.new(0.5, -100, 0.9, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local commandInput = Instance.new("TextBox")
commandInput.Name = "CommandInput"
commandInput.Size = UDim2.new(0.75, 0, 1, 0)
commandInput.Position = UDim2.new(0, 0, 0, 0)
commandInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
commandInput.BackgroundTransparency = 0.5
commandInput.BorderSizePixel = 0
commandInput.PlaceholderText = "Enter command..."
commandInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
commandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
commandInput.TextSize = 14
commandInput.ClearTextOnFocus = false
commandInput.Parent = mainFrame

local executeButton = Instance.new("TextButton")
executeButton.Name = "ExecuteButton"
executeButton.Size = UDim2.new(0.25, 0, 1, 0)
executeButton.Position = UDim2.new(0.75, 0, 0, 0)
executeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
executeButton.BackgroundTransparency = 0.2
executeButton.BorderSizePixel = 0
executeButton.Text = "Execute"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.TextSize = 14
executeButton.Parent = mainFrame


local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(0, 200, 0, 25)
statusFrame.Position = UDim2.new(0.5, -100, 0.9, -65)
statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusFrame.BackgroundTransparency = 0.3
statusFrame.BorderSizePixel = 0
statusFrame.Visible = false
statusFrame.Parent = screenGui

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Stand: Inactive"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextSize = 14
statusText.Parent = statusFrame


local helpButton = Instance.new("TextButton")
helpButton.Name = "HelpButton"
helpButton.Size = UDim2.new(0, 25, 0, 25)
helpButton.Position = UDim2.new(0.5, 105, 0.9, -40)
helpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
helpButton.BackgroundTransparency = 0.2
helpButton.BorderSizePixel = 0
helpButton.Text = "?"
helpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
helpButton.TextSize = 16
helpButton.Parent = screenGui


local helpFrame = Instance.new("Frame")
helpFrame.Name = "HelpFrame"
helpFrame.Size = UDim2.new(0, 300, 0, 200)
helpFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
helpFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
helpFrame.BackgroundTransparency = 0.2
helpFrame.BorderSizePixel = 0
helpFrame.Visible = false
helpFrame.Parent = screenGui

local helpTitle = Instance.new("TextLabel")
helpTitle.Name = "HelpTitle"
helpTitle.Size = UDim2.new(1, 0, 0, 30)
helpTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
helpTitle.BackgroundTransparency = 0.2
helpTitle.BorderSizePixel = 0
helpTitle.Text = "Stand Executor Commands"
helpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
helpTitle.TextSize = 18
helpTitle.Parent = helpFrame

local helpClose = Instance.new("TextButton")
helpClose.Name = "HelpClose"
helpClose.Size = UDim2.new(0, 25, 0, 25)
helpClose.Position = UDim2.new(1, -25, 0, 0)
helpClose.BackgroundTransparency = 1
helpClose.Text = "X"
helpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
helpClose.TextSize = 18
helpClose.Parent = helpTitle

local helpContent = Instance.new("TextLabel")
helpContent.Name = "HelpContent"
helpContent.Size = UDim2.new(1, -10, 1, -40)
helpContent.Position = UDim2.new(0, 5, 0, 35)
helpContent.BackgroundTransparency = 1
helpContent.Text = ";stand [player] - Summon stand to follow player\n;unstand - Dismiss your stand\n;mode [default/protect/orbit/mimic] - Change stand behavior\n;offset [x] [y] [z] - Set custom position\n;visible [true/false] - Toggle visibility\n;anim [idle/point/wave] - Change animation\n;toggle - Hide/show UI"
helpContent.TextColor3 = Color3.fromRGB(255, 255, 255)
helpContent.TextSize = 14
helpContent.TextXAlignment = Enum.TextXAlignment.Left
helpContent.TextYAlignment = Enum.TextYAlignment.Top
helpContent.Parent = helpFrame


local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

local function findPlayer(inputName)
    inputName = inputName:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName:lower():sub(1, #inputName) == inputName or player.Name:lower():sub(1, #inputName) == inputName then
            return player
        end
    end
    return nil
end


local function setupAntiFling(char)
    if not char then return end
    
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
    end
    
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end

local function restoreCharacter(char)
    if not char then return end
    
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end


local function updateStatus()
    if following and targetPlayer then
        statusText.Text = "Stand: Following " .. targetPlayer.Name .. " (" .. standMode .. ")"
        statusFrame.Visible = true
    else
        statusText.Text = "Stand: Inactive"
        statusFrame.Visible = false
    end
end

local function stopFollowing()
    RunService:UnbindFromRenderStep("StandFollow")
    local char = LocalPlayer.Character
    if char then
        restoreCharacter(char)
    end
    following = false
    targetPlayer = nil
    updateStatus()
    notify("Stand Deactivated", "Stopped following target.")
end

local function startFollowing(player)
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        notify("Stand Error", "Player not found or not loaded.")
        return
    end
    
    targetPlayer = player
    following = true
    updateStatus()
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    setupAntiFling(char)
    
    notify("Stand Activated", "Now following " .. targetPlayer.Name)
    
    
    wait(0.1)
    
    RunService:BindToRenderStep("StandFollow", Enum.RenderPriority.Character.Value + 1, function()
        if not following or not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character then
            stopFollowing()
            return
        end
        
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local targetPos
        local lookAt = targetHRP.Position
        
        
        if standMode == "default" then
            
            targetPos = targetHRP.Position + (targetHRP.CFrame.RightVector * offset.X) + 
                      (targetHRP.CFrame.LookVector * offset.Z) + Vector3.new(0, offset.Y, 0)
        
        elseif standMode == "protect" then
            
            local closestDistance = math.huge
            local closestPosition = nil
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= targetPlayer and otherPlayer ~= LocalPlayer and 
                   otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local otherHRP = otherPlayer.Character.HumanoidRootPart
                    local distance = (otherHRP.Position - targetHRP.Position).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPosition = otherHRP.Position
                    end
                end
            end
            
            if closestPosition and closestDistance < 30 then
                local direction = (targetHRP.Position - closestPosition).Unit
                targetPos = targetHRP.Position + direction * 2 + Vector3.new(0, offset.Y, 0)
                lookAt = closestPosition
            else
                
                targetPos = targetHRP.Position + (targetHRP.CFrame.RightVector * offset.X) + 
                          (targetHRP.CFrame.LookVector * offset.Z) + Vector3.new(0, offset.Y, 0)
            end
            
        elseif standMode == "orbit" then
            
            local angle = tick() % (2 * math.pi)
            local radius = math.sqrt(offset.X^2 + offset.Z^2)
            targetPos = targetHRP.Position + Vector3.new(
                math.cos(angle) * radius,
                offset.Y,
                math.sin(angle) * radius
            )
            
        elseif standMode == "mimic" then
            
            targetPos = targetHRP.Position + (targetHRP.CFrame.RightVector * offset.X) + 
                      (targetHRP.CFrame.LookVector * offset.Z) + Vector3.new(0, offset.Y, 0)
            
            
            local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            local myHumanoid = char:FindFirstChildOfClass("Humanoid")
            
            if targetHumanoid and myHumanoid then
                local targetAnim = targetHumanoid:GetPlayingAnimationTracks()[1]
                if targetAnim then
                    
                    local animID = targetAnim.Animation.AnimationId
                    for _, track in pairs(myHumanoid:GetPlayingAnimationTracks()) do
                        if track.Animation.AnimationId ~= animID then
                            track:Stop()
                        end
                    end
                    
                    local anim = Instance.new("Animation")
                    anim.AnimationId = animID
                    myHumanoid:LoadAnimation(anim):Play()
                end
            end
        end
        
        
        local currentPos = hrp.Position
        local newPos = currentPos:Lerp(targetPos, smoothness)
        
        
        hrp.CFrame = CFrame.new(newPos, lookAt)
    end)
end


local function runCommand(text)
    local parts = {}
    for part in text:gmatch("%S+") do
        table.insert(parts, part:lower())
    end
    
    local command = parts[1]
    
    if command == ";stand" then
        if parts[2] then
            local targetName = parts[2]
            local player = findPlayer(targetName)
            if player then
                if following then
                    stopFollowing() 
                    wait(0.1) 
                end
                startFollowing(player)
            else
                notify("Stand Error", "Player not found.")
            end
        else
            notify("Stand Error", "Player name required.")
        end
    
    elseif command == ";unstand" then
        stopFollowing()
    
    elseif command == ";mode" then
        if parts[2] and (parts[2] == "default" or parts[2] == "protect" or parts[2] == "orbit" or parts[2] == "mimic") then
            standMode = parts[2]
            notify("Stand Mode", "Changed to " .. standMode .. " mode.")
            updateStatus()
        else
            notify("Stand Error", "Valid modes: default, protect, orbit, mimic")
        end
    
    elseif command == ";offset" then
        if parts[2] and parts[3] and parts[4] and tonumber(parts[2]) and tonumber(parts[3]) and tonumber(parts[4]) then
            offset = Vector3.new(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
            notify("Stand Position", "Offset updated.")
        else
            notify("Stand Error", "Format: ;offset [x] [y] [z]")
        end
    
    elseif command == ";smooth" or command == ";smoothness" then
        if parts[2] and tonumber(parts[2]) then
            local value = tonumber(parts[2])
            if value > 0 and value <= 1 then
                smoothness = value
                notify("Stand Movement", "Smoothness set to " .. value)
            else
                notify("Stand Error", "Smoothness must be between 0.01 and 1")
            end
        else
            notify("Stand Error", "Format: ;smooth [0.01-1]")
        end
    
    elseif command == ";visible" then
        if parts[2] then
            local visible = parts[2] == "true"
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = visible and 0 or 1
                    end
                end
                notify("Stand Visibility", visible and "Stand is now visible." or "Stand is now invisible.")
            end
        else
            notify("Stand Error", "Format: ;visible [true/false]")
        end
    
    elseif command == ";anim" or command == ";animation" then
        if parts[2] then
            local animType = parts[2]:lower()
            local char = LocalPlayer.Character
            if char and following then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                    
                    local animation = Instance.new("Animation")
                    
                    
                    if animType == "idle" then
                        animation.AnimationId = "rbxassetid://507766666" 
                    elseif animType == "point" then
                        animation.AnimationId = "rbxassetid://507770453" 
                    elseif animType == "wave" then
                        animation.AnimationId = "rbxassetid://507770239" 
                    else
                        notify("Stand Error", "Unknown animation.")
                        return
                    end
                    
                    local animTrack = humanoid:LoadAnimation(animation)
                    animTrack:Play()
                    notify("Stand Animation", "Playing " .. animType .. " animation.")
                end
            else
                notify("Stand Error", "Stand must be active to animate.")
            end
        else
            notify("Stand Error", "Format: ;anim [idle/point/wave]")
        end
    
    elseif command == ";toggle" then
        mainFrame.Visible = not mainFrame.Visible
        statusFrame.Visible = following and mainFrame.Visible
    end
end


executeButton.MouseButton1Click:Connect(function()
    local command = commandInput.Text
    if command ~= "" then
        runCommand(command)
        commandInput.Text = ""
    end
end)

commandInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local command = commandInput.Text
        if command ~= "" then
            runCommand(command)
            commandInput.Text = ""
        end
    end
end)

helpButton.MouseButton1Click:Connect(function()
    helpFrame.Visible = not helpFrame.Visible
end)

helpClose.MouseButton1Click:Connect(function()
    helpFrame.Visible = false
end)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Semicolon then
            commandInput:CaptureFocus()
        elseif input.KeyCode == Enum.KeyCode.F1 then
            helpFrame.Visible = not helpFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.F2 then
            mainFrame.Visible = not mainFrame.Visible
            statusFrame.Visible = following and mainFrame.Visible
        end
    end
end)


LocalPlayer.CharacterAdded:Connect(function(char)
    following = false
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    updateStatus()
    

    if targetPlayer and targetPlayer.Character then
        wait(1) 
        startFollowing(targetPlayer)
    end
end)


UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and following then
        stopFollowing()
        notify("Emergency Stop", "Stand deactivated due to emergency stop.")
    end
end)


notify("Dezzo's Stand Command", "script loaded. Press F1 for commands.", 5)
