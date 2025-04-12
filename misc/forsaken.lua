local players = cloneref(game:GetService("Players"))
local run_service = cloneref(game:GetService("RunService"))
local workspace_ref = cloneref(game:GetService("Workspace"))

function create_text_label(tool)
    if tool:FindFirstChild("ToolNameLabel") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ToolNameLabel"
    billboard.Adornee = tool
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = math.huge

    local text_label = Instance.new("TextLabel")
    text_label.Size = UDim2.new(1, 0, 1, 0)
    text_label.BackgroundTransparency = 1
    text_label.Text = tool.Name
    text_label.TextColor3 = Color3.new(1, 1, 1)
    text_label.TextScaled = true
    text_label.Font = Enum.Font.SourceSansBold
    text_label.Parent = billboard

    billboard.Parent = tool
end

function apply_outline(tool)
    if not tool:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.new(1, 1, 0)
        highlight.OutlineColor = Color3.new(1, 0, 0)
        highlight.Parent = tool
    end
    create_text_label(tool)
end

function create_outline_esp(model, outline_color, fill_color)
    if model and not model:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = model
        highlight.Adornee = model
        highlight.FillTransparency = 0.75
        highlight.FillColor = fill_color
        highlight.OutlineColor = outline_color
        highlight.OutlineTransparency = 0
    end
end

function create_health_indicator(character, text_color)
    local head = character:FindFirstChild("Head")
    if head and not head:FindFirstChild("HealthGui") then
        local health_gui = Instance.new("BillboardGui")
        health_gui.Name = "HealthGui"
        health_gui.Size = UDim2.new(0, 100, 0, 30)
        health_gui.AlwaysOnTop = true
        health_gui.MaxDistance = math.huge
        health_gui.Parent = head

        local health_label = Instance.new("TextLabel")
        health_label.Size = UDim2.new(1, 0, 1, 0)
        health_label.BackgroundTransparency = 1
        health_label.TextScaled = true
        health_label.Text = ""
        health_label.TextColor3 = text_color
        health_label.Font = Enum.Font.SourceSansBold
        health_label.Parent = health_gui
    end
end

function update_health_indicators()
    for _, player in players:GetPlayers() do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            if humanoid and head then
                local text_color = humanoid.MaxHealth > 500 and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
                create_health_indicator(character, text_color)

                local health_gui = head:FindFirstChild("HealthGui")
                if health_gui then
                    local label = health_gui:FindFirstChildOfClass("TextLabel")
                    if label then
                        label.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
                        label.TextColor3 = text_color
                    end
                end
            end
        end
    end
end

function create_outline_esp_for_group(group, outline_color, fill_color)
    if group then
        for _, obj in group:GetChildren() do
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local root_part = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and root_part then
                create_outline_esp(obj, outline_color, fill_color)
            end
        end
    end
end

function highlight_generators()
    for _, obj in workspace_ref:GetDescendants() do
        if obj:IsA("Model") and obj.Name == "Generator" then
            create_outline_esp(obj, Color3.new(1, 1, 0), Color3.new(1, 1, 0.5))
        end
    end
end

function update_esp()
    while true do
        local all_players = players:GetPlayers()
        for _, player in all_players do
            local character = player.Character
            if character then
                for _, child in character:GetChildren() do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if humanoid.MaxHealth > 500 then
                        create_outline_esp(character, Color3.new(1, 0, 0), Color3.new(1, 0.5, 0.5))
                        create_health_indicator(character, Color3.new(1, 0, 0))
                    else
                        create_outline_esp(character, Color3.new(0.5, 0.5, 0.5), Color3.new(0.7, 0.7, 0.7))
                        create_health_indicator(character, Color3.new(1, 1, 1))
                    end
                end
            end
        end

        update_health_indicators()
        highlight_generators()
        task.wait(3)
    end
end
