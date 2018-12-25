---------------------------------
--- ShowTeleport Version 0.3 ---
---------------------------------

local ShowTeleport = {
	optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Enable this script."),
	optionEnableWorldDraw = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "2. Enable world draw", ""),
	NeedInit = true
}

local widthScreen, heightScreen = nil, nil
local myHero = nil
local Memoize = nil
local memoizeImages = nil

local AssetsTable = {}

local FunctionFloor = math.floor
local LuaStringFind = string.find
local ValueOnDraw = nil
local TempUnitName, xCoor, yCoor = nil, nil, nil

local ParticleManager = {
	ParticleUnique = {
		{
			Name = "teleport_start",
			TrackDuration = 5,
			ColorR = nil,
			ColorG = nil,
			ColorB = nil,
			DormantCheck = true,
			MinimapImage = "minimap_herocircle"
		},
		{
			Name = "teleport_start_bots",
			TrackDuration = 5,
			ColorR = nil,
			ColorG = nil,
			ColorB = nil,
			DormantCheck = true,
			MinimapImage = "minimap_herocircle"
		},
		{
			Name = "teleport_end",
			TrackDuration = 5,
			ColorR = nil,
			ColorG = nil,
			ColorB = nil,
			DormantCheck = false,
			MinimapImage = "minimap_ping_teleporting"
		},
		{
			Name = "teleport_end_bots",
			TrackDuration = 5,
			ColorR = nil,
			ColorG = nil,
			ColorB = nil,
			DormantCheck = false,
			MinimapImage = "minimap_ping_teleporting"
		},
		{
			Name = "furion_teleport_end",
			TrackDuration = 5,
			ColorR = 255,
			ColorG = 255,
			ColorB = 255,
			SecondIcon = true,
			DormantCheck = false,
			MinimapImage = "minimap_ping_teleporting"
		}
	},
	ParticleNonUnique = {
		{
			Name = "furion_teleport",
			TrackDuration = 5,
			ColorR = 255,
			ColorG = 255,
			ColorB = 255,
			DormantCheck = true,
			MinimapImage = "minimap_herocircle"
		}
	},
	GetParticleUpdateZero = {
		teleport_start = true,
		teleport_start_bots = true,
		furion_teleport = true
	},
	GetParticleUpdateOne = {
		furion_teleport_end = true
	},
	GetParticleUpdateTwo = {
		teleport_start = true,
		teleport_start_bots = true,
		teleport_end = true,
		teleport_end_bots = true
	},
	GetParticleUpdateFive = {
		teleport_end = true,
		teleport_end_bots = true
	}
}

local ParticleData = {}

function ShowTeleport.OnScriptLoad()
	for i = #ParticleData, 1, -1 do
		ParticleData[i] = nil
	end
	ParticleData = {}
	
	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	AssetsTable = {}
	Memoize = nil
	
	myHero = nil
	ValueOnDraw = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	
	Console.Print("\n================================================\n")
	Console.Print("Script: Show Teleport | Callback: OnScriptLoad\n")
	Console.Print("Date & Time: " .. (os.date("%Y-%m-%d %I:%M %p")) .. " | Version: 0.3")
	Console.Print("================================================\n\n")
	
	ShowTeleport.NeedInit = true
end

function ShowTeleport.OnGameStart()
	for i = #ParticleData, 1, -1 do
		ParticleData[i] = nil
	end
	ParticleData = {}
	
	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	AssetsTable = {}
	Memoize = nil
	
	if myHero == nil then
		myHero = Heroes.GetLocal()
	end
	ValueOnDraw = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	ShowTeleport.NeedInit = true
	
	Console.Print("\n")
	Console.Print("Script: ShowTeleport | Function: OnGameStart()")
	Console.Print("\n")
end

function ShowTeleport.OnGameEnd()
	for i = #ParticleData, 1, -1 do
		ParticleData[i] = nil
	end
	ParticleData = {}

	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	AssetsTable = {}
	Memoize = nil
	ValueOnDraw = nil
	myHero = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	collectgarbage("collect")
	ShowTeleport.NeedInit = true
	
	Console.Print("\n")
	Console.Print("Script: ShowTeleport | Function: OnGameEnd()")
	Console.Print("\n")
end

function ShowTeleport.LoadImage(option1, option2)
	return Renderer.LoadImage(option1 .. option2 .. "_png.vtex_c")
end

function ShowTeleport.GetParticleUnique(particle)
	local idx = nil
	local v = nil
	
	for i = #ParticleManager.ParticleUnique, 1, -1 do
		v = ParticleManager.ParticleUnique[i]
	
		if particle.name == v.Name then
			idx = particle.index
			
			if idx > -1 then
				idx = idx * -1
			end
			
			table.insert(
							ParticleData, 
							{
								index = particle.index,
								name = v.Name,
								TrackUntil = GameRules.GetGameTime() + v.TrackDuration,
								entity = particle.entityForModifiers or nil,
								Position = nil,
								IconIndex = idx,
								SecondIndex = nil,
								ColorR = v.ColorR,
								ColorG = v.ColorG,
								ColorB = v.ColorB,
								SecondIcon = v.SecondIcon or false,
								DormantCheck = v.DormantCheck,
								Texture = v.MinimapImage or nil,
								SecondTexture = nil
							}
						)
			
			return true
		end
	end
	return false
end

function ShowTeleport.GetParticleNonUnique(particle)
	local idx = nil
	local ValueParticleNonUnique = nil
	
	for i = #ParticleManager.ParticleNonUnique, 1, -1 do
		ValueParticleNonUnique = ParticleManager.ParticleNonUnique[i]
	
		if particle.name == ValueParticleNonUnique.Name then
			idx = particle.index
			
			if idx > -1 then
				idx = idx * -1
			end
			
			table.insert(
							ParticleData, 
							{
								index = particle.index,
								name = ValueParticleNonUnique.Name,
								TrackUntil = os.clock() + ValueParticleNonUnique.TrackDuration,
								entity = particle.entity or nil,
								Position = nil,
								IconIndex = idx,
								SecondIndex = nil,
								ColorR = ValueParticleNonUnique.ColorR,
								ColorG = ValueParticleNonUnique.ColorG,
								ColorB = ValueParticleNonUnique.ColorB,
								SecondIcon = ValueParticleNonUnique.SecondIcon or false,
								DormantCheck = ValueParticleNonUnique.DormantCheck,
								Texture = ValueParticleNonUnique.MinimapImage or nil,
								SecondTexture = nil
							}
						)
			
			return true
		end
	end
	return false
end

function ShowTeleport.OnParticleCreate(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
	if ShowTeleport.GetParticleNonUnique(particle) == false then
		ShowTeleport.GetParticleUnique(particle)
	end
end

function ShowTeleport.OnParticleUpdate(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
    for _, Value in pairs(ParticleData) do
        if Value ~= nil and particle.index == Value.index then
			if particle.controlPoint == 0 then
				if ParticleManager.GetParticleUpdateZero[Value.name] then
					if Value.Position == nil then
						Value.Position = particle.position
					end
				end
			end
			
			if particle.controlPoint == 1 then
				if ParticleManager.GetParticleUpdateOne[Value.name] then
					if Value.Position == nil then
						Value.Position = particle.position
						
						if Value.SecondIcon == true and Value.SecondTexture == nil then
							--Value.SecondTexture = "minimap_heroicon_" .. NPC.GetUnitName(Value.entity)
							Value.SecondTexture = Hero.GetIcon(Value.entity)
							Value.SecondIndex = MiniMap.AddIcon(nil, Value.SecondTexture, Value.Position, 255, 255, 255, 255, 0, 1200)
							
							if Value.SecondIndex > -1 then
								Value.SecondIndex = Value.SecondIndex * -1
							end
						end
					end
				end
			end
			
			if particle.controlPoint == 2 then
				if ParticleManager.GetParticleUpdateTwo[Value.name] then
					if Value.ColorR == nil then
						Value.ColorR = FunctionFloor(255 * particle.position:GetX())
					end
					
					if Value.ColorG == nil then
						Value.ColorG = FunctionFloor(255 * particle.position:GetY())
					end
					
					if Value.ColorB == nil then
						Value.ColorB = FunctionFloor(255 * particle.position:GetZ())
					end
				end
			end
			
			if particle.controlPoint == 5 then
				if ParticleManager.GetParticleUpdateFive[Value.name] then
					if Value.Position == nil then
						Value.Position = particle.position
					end
				end
			end
        end
    end
end

function ShowTeleport.OnParticleDestroy(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
	local Value = nil
	
	for i = #ParticleData, 1, -1 do
		Value = ParticleData[i]

		if (Value ~= nil) and (particle.index == Value.index) then
			ParticleData[i] = nil
		end
    end
end

function ShowTeleport.IsOnScreen(x, y)
	if (x < 1) or (y < 1) or (x > widthScreen) or (y > heightScreen) then 
		return false 
	end
	
	return true
end

function ShowTeleport.OnDraw()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	if ShowTeleport.NeedInit == true then
		widthScreen, heightScreen = Renderer.GetScreenSize()
		
		AssetsTable = {}
		memoize = require("Utility/memoize")
		memoizeImages = memoize(ShowTeleport.LoadImage, AssetsTable)
		
		for i = #ParticleData, 1, -1 do
			ParticleData[i] = nil
		end
		ParticleData = {}
		
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		
		ValueOnDraw = nil
		TempUnitName, xCoor, yCoor = nil, nil, nil
		ShowTeleport.NeedInit = false
	end
	
	if myHero == nil then return end
	
	for key = #ParticleData, 1, -1 do
		ValueOnDraw = ParticleData[key]
		if ValueOnDraw ~= nil then
			if ValueOnDraw.TrackUntil - GameRules.GetGameTime() < 0 then
				ParticleData[key] = nil
			end
					
			if ValueOnDraw.Position ~= nil and ValueOnDraw.entity ~= nil and Entity.IsSameTeam(myHero, ValueOnDraw.entity) == false  then
				if ValueOnDraw.DormantCheck == true then
					if Entity.IsDormant(ValueOnDraw.entity) == true then
						MiniMap.AddIconByName(ValueOnDraw.IconIndex, ValueOnDraw.Texture, ValueOnDraw.Position, ValueOnDraw.ColorR, ValueOnDraw.ColorG, ValueOnDraw.ColorB, 255, 0.1, 1200)
								
						if Menu.IsEnabled(ShowTeleport.optionEnableWorldDraw) == true then
							TempUnitName = NPC.GetUnitName(ValueOnDraw.entity)
							xCoor, yCoor = Renderer.WorldToScreen(ValueOnDraw.Position)
									
							if ShowTeleport.IsOnScreen(xCoor, yCoor) == true then
								if LuaStringFind(TempUnitName, "npc_dota_lone_druid_bear") then
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawImage(memoizeImages("panorama/images/spellicons/", "lone_druid_spirit_bear"), (xCoor - 24), (yCoor - 24), 48, 48)
								else
									--Renderer.SetDrawColor(ValueOnDraw.ColorR, ValueOnDraw.ColorG, ValueOnDraw.ColorB, 255)
									--Renderer.DrawIcon("minimap_plaincircle", (xCoor - 36), (yCoor - 38), 72, 72)
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawIcon(Hero.GetIcon(ValueOnDraw.entity), (xCoor - 24), (yCoor - 24), 48, 48)
									
								end
							end
						end
								
					end
				else
					MiniMap.AddIconByName(ValueOnDraw.IconIndex, ValueOnDraw.Texture, ValueOnDraw.Position, ValueOnDraw.ColorR, ValueOnDraw.ColorG, ValueOnDraw.ColorB, 255, 0.1, 1200)
							
					if ValueOnDraw.SecondIcon == true then
						MiniMap.AddIcon(ValueOnDraw.SecondIndex, ValueOnDraw.SecondTexture, ValueOnDraw.Position, 255, 255, 255, 255, 0.1, 1000)
					end
				end
			end
		end
	end
end

return ShowTeleport