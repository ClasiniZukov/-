local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local WebhookUrl = "https://discord.com/api/webhooks/1263401617433301043/W8jEwN8FXaQNR5vAIoNa_aYl3Djbqj8YrnHIpfWU13mdh5E3TQaOxYAUjz5LuxHixskU"
local HWID = RbxAnalyticsService:GetClientId()
local utcTime = os.time(os.date("!*t"))
local beijingTime = utcTime + (8 * 60 * 60)
local beijingTimeString = os.date("%Y-%m-%d %H:%M:%S", beijingTime)
local model = game.Game.Local.droppable["Money Printer"]
local modelfolder = game.Game.Local.droppable
local plr = Players.LocalPlayer
local userid = plr.UserId
local serverid = game.JobId
local httprequest = (syn and syn.request)
	or http and http.request
	or http_request
	or (delta and delta.request)
	or request
local webhookUrl2 = "https://discord.com/api/webhooks/1255442005392363602/uK1uTr_9FnoNu7tI4_KY9eLA581qhBncq6tbLgA1YsPupX1pOwkSUttQzo2IS3PiYdE6"
local function partMatchesProximityPrompt(part, objectText)
	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	return prompt and prompt.ObjectText == objectText
end
local function getitem(prompt)
	for i = 1, 20 do
		wait(0.5)
		fireproximityprompt(prompt)
	end
end
local function teleport()
	local PlaceId, JobId = game.PlaceId, game.JobId

	if httprequest then
		local servers = {}
		local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId)})
		local body = HttpService:JSONDecode(req.Body)
		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
					table.insert(servers, 1, v.id)
				end
			end
		end
		if #servers > 0 then
			local targetServer = servers[math.random(1, #servers)]
			local success, err = pcall(function()
				TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, Players.LocalPlayer)
			end)
			if not success then
				wait(0.5)
				teleport()
			end
		else
		end
	end
end
local function findMatchingModelWithPrompt(objectText)
	for _, model in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
		if model:IsA("Model") then
			local matchingPart = nil
			for _, part in pairs(model:GetDescendants()) do
				if (part:IsA("Part") or part:IsA("MeshPart")) and partMatchesProximityPrompt(part, objectText) then
					matchingPart = part
					break
				end
			end
			if matchingPart then
				return model, matchingPart
			end
		end
	end
	return nil, nil
end
local function sendWebhookMessage()
	local data = {
		["content"] = "머니프린터 알리미",
		["embeds"] = {{
			["title"] = "머니프린터 알리미",
			["description"] = table.concat({
				"이름: " .. plr.Name,
				"서버아이디: " .. serverid,
				"하드웨어 아이디: " .. HWID,
				"수집시간: " .. beijingTimeString
			}, "\n"),
			["type"] = "rich",
			["color"] = tonumber(0x00ff00)  -- Green color
		}}
	}

	local headers = {
		["Content-Type"] = "application/json"
	}

	local requestBody = HttpService:JSONEncode(data)

	if httprequest then
		httprequest({
			Url = WebhookUrl,
			Method = "POST",
			Headers = headers,
			Body = requestBody
		})
	else
		
	end
end
local objectText = "Money Printer"



local embedData = {
	["embeds"] = {{
		["title"] = "머니프린터봇",
		["description"] = "서버 아이디: " .. serverid .. "프린터 개수:" .. printercount,
		["type"] = "rich",
		["color"] = tonumber(0x00ff00)
	}}
}

local jsonData = HttpService:JSONEncode(embedData)


local headers = {
	["Content-Type"] = "application/json"
}

local requestData = {
	Url = webhookUrl2,
	Method = "POST",
	Headers = headers,
	Body = jsonData
}

if model then
	for _,object in ipairs(modelfolder:GetDescendants()) do
		if object.Name == "Money Printer" then
			printercount = printercount + 1
		end
	end
	httprequest(requestData)
else
	
end


while true do
	local matchingModel, matchingPart = findMatchingModelWithPrompt(objectText)
	if matchingModel and matchingPart then
		local teleportPosition = matchingPart.Position
		local player = Players.LocalPlayer
		local character = player.Character
		local humanoid = character:WaitForChild("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local prompt = matchingPart:FindFirstChildOfClass("ProximityPrompt")

		if humanoidRootPart and prompt then
			local moveDirection = Vector3.new(0, 0, 1)
			local moveSpeed = 16 
			humanoid:Move(moveDirection * moveSpeed)
			humanoidRootPart.CFrame = CFrame.new(teleportPosition)

			getitem(prompt)
		end
		wait(5)
		sendWebhookMessage()
		teleport()
	else
		teleport()
	end
	wait(0.1)
end
