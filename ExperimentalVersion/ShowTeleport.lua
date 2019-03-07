-------------------------------------
--- ShowTeleport.lua Version 0.6a ---
-------------------------------------

local ShowTeleport = {
	optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Enable this script."),
	optionEnableWorldDraw = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "2. Enable world draw", ""),
	NeedInit = true
}

local widthScreen, heightScreen = nil, nil
local myHero = nil
local FunctionFloor = math.floor
local LuaStringFind = string.find
local ValueParticleUpdate = nil
local TempUnitName, xCoor, yCoor = nil, nil, nil

local ParticleManager = {
	{
		["teleport_start"] = {
			["Name"] = "teleport_start",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = true,
			["MinimapImage"] = "minimap_herocircle"
		},
		["teleport_start_bots"] = {
			["Name"] = "teleport_start_bots",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = true,
			["MinimapImage"] = "minimap_herocircle"
		},
		["teleport_end"] = {
			["Name"] = "teleport_end",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = false,
			["MinimapImage"] = "minimap_ping_teleporting"
		},
		["teleport_end_bots"] = {
			["Name"] = "teleport_end_bots",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["SecondIcon"] = true,
			["DormantCheck"] = false,
			["MinimapImage"] = "minimap_ping_teleporting"
		},
		["furion_teleport_end"] = {
			["Name"] = "furion_teleport_end",
			["TrackDuration"] = 5,
			["ColorR"] = 255,
			["ColorG"] = 0,
			["ColorB"] = 0,
			["SecondIcon"] = true,
			["DormantCheck"] = false,
			["MinimapImage"] = "minimap_ping_teleporting"
		}
	},
	--[[
		1 -> ["Name"]
		2 -> ["TrackDuration"]
		3 -> ["ColorR"]
		4 -> ["ColorG"]
		5 -> ["ColorB"]
		6 -> ["DormantCheck"]
		7 -> ["MinimapImage"]
	--]]
	{
		"furion_teleport",
		5,
		255,
		0,
		0,
		true,
		"minimap_herocircle"
	},
	{
		{
			["teleport_start"] = true,
			["teleport_start_bots"] = true,
			["furion_teleport"] = true
		},
		{
			["furion_teleport_end"] = true
		},
		{
			["teleport_start"] = true,
			["teleport_start_bots"] = true,
			["teleport_end"] = true,
			["teleport_end_bots"] = true
		},
		{
			["teleport_end"] = true,
			["teleport_end_bots"] = true
		}
	}
}

local ParticleData = {}

function ShowTeleport.OnScriptLoad()
	for k, v in pairs( ParticleData ) do
		ParticleData[ k ] = nil
	end

	widthScreen, heightScreen = nil, nil

	myHero = nil
	ValueParticleUpdate = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	ShowTeleport.NeedInit = true
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.6a ] Script load.")
end

function ShowTeleport.OnGameEnd()
	for k, v in pairs( ParticleData ) do
		ParticleData[ k ] = nil
	end

	widthScreen, heightScreen = nil, nil
	
	ValueParticleUpdate = nil
	myHero = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	ShowTeleport.NeedInit = true
	
	collectgarbage("collect")
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.6a ] Game end. Reset all variable.")
end

function ShowTeleport.IsUniqueParticle(particle)
	if ParticleManager[1][particle.name] then
		local idx = particle.index
		local ValueParticleUnique = ParticleManager[1][particle.name]
		
		if idx > -1 then
			idx = idx * -1
		end
		
		ParticleData[tostring(particle.index)] = {
			index = particle.index,
			name = ValueParticleUnique.Name,
			TrackUntil = GameRules.GetGameTime() + ValueParticleUnique.TrackDuration,
			entity = particle.entityForModifiers or nil,
			Position = nil,
			IconIndex = idx,
			SecondIndex = nil,
			ColorR = ValueParticleUnique.ColorR,
			ColorG = ValueParticleUnique.ColorG,
			ColorB = ValueParticleUnique.ColorB,
			SecondIcon = ValueParticleUnique.SecondIcon or false,
			DormantCheck = ValueParticleUnique.DormantCheck,
			Texture = ValueParticleUnique.MinimapImage or nil,
			SecondTexture = nil
		}
		
		return true
	end
	
	return false
end

function ShowTeleport.IsNonUniqueParticle(particle)
	if particle.name == ParticleManager[2][1] then
		local idx = particle.index
		
		if idx > -1 then
			idx = idx * -1
		end
			
		ParticleData[tostring(particle.index)] = {
			index = particle.index,
			name = ParticleManager[2][1],
			TrackUntil = GameRules.GetGameTime() + ParticleManager[2][2],
			entity = particle.entity or nil,
			Position = nil,
			IconIndex = idx,
			SecondIndex = nil,
			ColorR = ParticleManager[2][3],
			ColorG = ParticleManager[2][4],
			ColorB = ParticleManager[2][5],
			SecondIcon = false,
			DormantCheck = ParticleManager[2][6],
			Texture = ParticleManager[2][7] or nil,
			SecondTexture = nil
		}
			
		return true
	end

	return false
end

function ShowTeleport.OnParticleCreate(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
	if ShowTeleport.IsUniqueParticle(particle) == false then
		ShowTeleport.IsNonUniqueParticle(particle)
	end
end

function ShowTeleport.OnParticleUpdate(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
	ValueParticleUpdate = ParticleData[tostring(particle.index)] or nil
	
	if ValueParticleUpdate == nil then return end
	
	if particle.controlPoint == 0 then
		if ParticleManager[3][1][ValueParticleUpdate.name] then
			if ValueParticleUpdate.Position == nil then
				ParticleData[tostring(particle.index)].Position = particle.position
			end
		end
	end
			
	if particle.controlPoint == 1 then
		if ParticleManager[3][2][ValueParticleUpdate.name] then
			if ValueParticleUpdate.Position == nil then
				ParticleData[tostring(particle.index)].Position = particle.position
						
				if ValueParticleUpdate.SecondIcon == true and ValueParticleUpdate.SecondTexture == nil then
					ParticleData[tostring(particle.index)].SecondTexture = Hero.GetIcon(ValueParticleUpdate.entity)
					ParticleData[tostring(particle.index)].SecondIndex = MiniMap.AddIcon(nil, ValueParticleUpdate.SecondTexture, ParticleData[tostring(particle.index)].Position, 255, 255, 255, 255, 0, 1200)
							
					if ValueParticleUpdate.SecondIndex > -1 then
						ParticleData[tostring(particle.index)].SecondIndex = ParticleData[tostring(particle.index)].SecondIndex * -1
					end
				end
			end
		end
	end
			
	if particle.controlPoint == 2 then
		if ParticleManager[3][3][ValueParticleUpdate.name] then
			if ValueParticleUpdate.ColorR == nil then
				ParticleData[tostring(particle.index)].ColorR = FunctionFloor(255 * particle.position:GetX())
			end
					
			if ValueParticleUpdate.ColorG == nil then
				ParticleData[tostring(particle.index)].ColorG = FunctionFloor(255 * particle.position:GetY())
			end
					
			if ValueParticleUpdate.ColorB == nil then
				ParticleData[tostring(particle.index)].ColorB = FunctionFloor(255 * particle.position:GetZ())
			end
					
			if ValueParticleUpdate.SecondIcon == true and ValueParticleUpdate.SecondTexture == nil then
				ParticleData[tostring(particle.index)].SecondTexture = Hero.GetIcon(ValueParticleUpdate.entity)
				ParticleData[tostring(particle.index)].SecondIndex = MiniMap.AddIcon(nil, ValueParticleUpdate.SecondTexture, ValueParticleUpdate.Position, 255, 255, 255, 255, 0, 1200)
							
				if ValueParticleUpdate.SecondIndex > -1 then
					ParticleData[tostring(particle.index)].SecondIndex = ValueParticleUpdate.SecondIndex * -1
				end
			end
		end
	end
	
	if particle.controlPoint == 5 then
		if ParticleManager[3][4][ValueParticleUpdate.name] then
			if ValueParticleUpdate.Position == nil then
				ParticleData[tostring(particle.index)].Position = particle.position
			end
		end
	end
end

function ShowTeleport.OnParticleDestroy(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end

	ParticleData[tostring(particle.index)] = nil
end

function ShowTeleport.IsOnScreen(x, y)
	if (x < 1) or (y < 1) or (x > widthScreen) or (y > heightScreen) then 
		return false 
	end
	
	return true
end

function ShowTeleport.OnDraw()
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if Engine.IsInGame() == false then return end
	
	if myHero == nil then
		myHero = Heroes.GetLocal() or nil
	end
	
	if ShowTeleport.NeedInit == true then
		for k, v in pairs( ParticleData ) do
			ParticleData[ k ] = nil
		end
		
		ValueParticleUpdate = nil
		TempUnitName, xCoor, yCoor = nil, nil, nil
		widthScreen, heightScreen = Renderer.GetScreenSize()
		
		ShowTeleport.NeedInit = false
		
		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.6a ] Game started, init script done.")
	end
	
	if myHero == nil then return end
	
	for k, v in pairs( ParticleData ) do
	
		if v.TrackUntil - GameRules.GetGameTime() < 0 then
			ParticleData[ k ] = nil
		end
					
		if 
			v.Position ~= nil
			and v.entity ~= nil
			and Entity.IsSameTeam(myHero, v.entity) == false
		then
			if v.DormantCheck == true then
				if Entity.IsDormant(v.entity) == true then
					MiniMap.AddIconByName(v.IconIndex, v.Texture, v.Position, v.ColorR, v.ColorG, v.ColorB, 255, 0.1, 1200)
						
					--[[
						This is drawing world icon for example in teleport will draw image on ground when teleport from fog.
					--]]
					if Menu.IsEnabled(ShowTeleport.optionEnableWorldDraw) == true then
						TempUnitName = NPC.GetUnitName(v.entity)
						xCoor, yCoor = Renderer.WorldToScreen(v.Position)
							
						if ShowTeleport.IsOnScreen(xCoor, yCoor) == true then
							Renderer.SetDrawColor(255, 255, 255, 255)
							
							if LuaStringFind(TempUnitName, "npc_dota_lone_druid_bear") then
								Renderer.DrawImage("panorama/images/heroes/npc_dota_lone_druid_bear_png.vtex_c", (xCoor - 24), (yCoor - 24), 48, 48)
							else
								Renderer.DrawIcon(Hero.GetIcon(v.entity), (xCoor - 24), (yCoor - 24), 48, 48)
							end
						end
					end
								
				end
			else
				--[[
					This is draw hero icon for example furion skill 2.
				--]]
				MiniMap.AddIconByName(v.IconIndex, v.Texture, v.Position, v.ColorR, v.ColorG, v.ColorB, 255, 0.1, 1200)
							
				if v.SecondIcon == true then
					MiniMap.AddIcon(v.SecondIndex, v.SecondTexture, v.Position, 255, 255, 255, 255, 0.1, 900)
				end
			end
		end
	end
end

return ShowTeleport