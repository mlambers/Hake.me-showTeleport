--------------------------------
--- ShowTeleport Version 0.2 ---
--------------------------------

local ShowTeleport = {}

ShowTeleport.optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Enable this script.")
ShowTeleport.optionEnableWorldDraw = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "2. Enable world draw", "")

ShowTeleport.DoneInit = false
ShowTeleport.NeedInit = true

local widthScreen, heightScreen = nil, nil
local myHero = nil
local Memoize = nil
local memoizeImages = nil

local Assets = {}
Assets.Table = {}
Assets.Path = "panorama/images/heroes/icons/"

local FunctionFloor = math.floor
local LuaStringFind = string.find

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
	for k in pairs(ParticleData) do
		table.remove(ParticleData, k)
	end
	ParticleData = {}
	
	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	Assets.Table = {}
	Memoize = nil
	
	myHero = nil
	ShowTeleport.DoneInit = false
	ShowTeleport.NeedInit = true
end

function ShowTeleport.OnGameStart()
	for k in pairs(ParticleData) do
		table.remove(ParticleData, k)
	end
	ParticleData = {}
	
	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	Assets.Table = {}
	Memoize = nil
	
	if myHero == nil then
		myHero = Heroes.GetLocal()
	end
	
	ShowTeleport.DoneInit = false
	ShowTeleport.NeedInit = true
end

function ShowTeleport.OnGameEnd()
	for k in pairs(ParticleData) do
		table.remove(ParticleData, k)
	end
	ParticleData = {}

	widthScreen, heightScreen = nil, nil
	
	memoizeImages = nil
	Assets.Table = {}
	Memoize = nil
	
	myHero = nil
	ShowTeleport.DoneInit = false
	ShowTeleport.NeedInit = true
end

function ShowTeleport.LoadImage( ... )
	local arg = {...}
	return Renderer.LoadImage(arg[1] .. arg[2] .. "_png.vtex_c")
end

function ShowTeleport.GetDataUnique(particle)
	local idx = nil
	
	for _, v in pairs(ParticleManager.ParticleUnique) do
		if particle.name == v.Name then
			idx = particle.index
			
			if idx > -1 then
				idx = idx * -1
			end
			
			table.insert(ParticleData, {
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

function ShowTeleport.GetData(particle)
	local idx = nil
	
	for _, v in pairs(ParticleManager.ParticleNonUnique) do
		if particle.name == v.Name then
			idx = particle.index
			
			if idx > -1 then
				idx = idx * -1
			end
			
			table.insert(ParticleData, {
								index = particle.index,
								name = v.Name,
								TrackUntil = os.clock() + v.TrackDuration,
								entity = particle.entity or nil,
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

function ShowTeleport.OnParticleCreate(particle)
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	if myHero == nil then return end
	
	if ShowTeleport.GetData(particle) == false then
		ShowTeleport.GetDataUnique(particle)
	end
end

function ShowTeleport.OnParticleUpdate(particle)
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
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
							Value.SecondTexture = "minimap_heroicon_" .. NPC.GetUnitName(Value.entity)
							Value.SecondIndex = MiniMap.AddIconByName(nil, Value.SecondTexture, Value.Position, 255, 255, 255, 255, 0, 1200)
							
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
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	if myHero == nil then return end
	
	for k, Value in  pairs(ParticleData) do
		if (Value ~= nil) and (particle.index == Value.index) then
			ParticleData[k] = nil
		end
    end
end

function ShowTeleport.IsOnScreen(x, y)
	if (x < 1) or (y < 1) then 
		return false 
	end
	
	if (x > widthScreen) or ( y > widthScreen) then 
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
		
		Assets.Table = {}
		memoize = require("Utility/memoize")
		memoizeImages = memoize(ShowTeleport.LoadImage, Assets.Table)
		
		ShowTeleport.DoneInit = true
		
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		
		ShowTeleport.NeedInit = false
	end
	
	if myHero == nil then return end
	if ShowTeleport.DoneInit == false then return end
	
	for key, Value in pairs(ParticleData) do
		if Value ~= nil then
			if Value.TrackUntil - GameRules.GetGameTime() < 0 then
				table.remove(ParticleData, key)
			end
			
			if Value.Position ~= nil and Value.entity ~= nil and Entity.IsSameTeam(myHero, Value.entity) == false  then
				if Value.DormantCheck == true then
					if Entity.IsDormant(Value.entity) == true then
						MiniMap.AddIconByName(Value.IconIndex, Value.Texture, Value.Position, Value.ColorR, Value.ColorG, Value.ColorB, 255, 0.1, 1200)
						
						if Menu.IsEnabled(ShowTeleport.optionEnableWorldDraw) then
							local UnitName = NPC.GetUnitName(Value.entity)
							local x, y = Renderer.WorldToScreen(Value.Position)
							
							if ShowTeleport.IsOnScreen(x, y) == true then
								if LuaStringFind(UnitName, "npc_dota_lone_druid_bear") then
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawImage(memoizeImages("panorama/images/spellicons/", "lone_druid_spirit_bear"), (x - 24), (y - 24), 48.0, 48.0)
								else
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawImage(memoizeImages(Assets.Path, UnitName), (x - 24), (y - 24), 48.0, 48.0)
								end
							end
						end
						
					end
				else
					MiniMap.AddIconByName(Value.IconIndex, Value.Texture, Value.Position, Value.ColorR, Value.ColorG, Value.ColorB, 255, 0.1, 1200)
					
					if Value.SecondIcon == true then
						MiniMap.AddIconByName(Value.SecondIndex, Value.SecondTexture, Value.Position, 255, 255, 255, 255, 0.1, 1000)
					end
				end
			end
		end
	end
end

return ShowTeleport