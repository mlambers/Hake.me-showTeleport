------------------------------------
--- ShowTeleport.lua Version 0.5 ---
------------------------------------

local ShowTeleport = {
	optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Enable this script."),
	optionEnableWorldDraw = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "2. Enable world draw", ""),
	NeedInit = true
}

local widthScreen, heightScreen = nil, nil
local myHero = nil
local FunctionFloor = math.floor
local LuaStringFind = string.find
local ValueOnDraw, ValueParticleUpdate, ValueParticleDestroy = nil, nil, nil
local TempUnitName, xCoor, yCoor = nil, nil, nil

local ParticleManager = {
	{
		{
			["Name"] = "teleport_start",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = true,
			["MinimapImage"] = "minimap_herocircle"
		},
		{
			["Name"] = "teleport_start_bots",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = true,
			["MinimapImage"] = "minimap_herocircle"
		},
		{
			["Name"] = "teleport_end",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["DormantCheck"] = false,
			["MinimapImage"] = "minimap_ping_teleporting"
		},
		{
			["Name"] = "teleport_end_bots",
			["TrackDuration"] = 5,
			["ColorR"] = nil,
			["ColorG"] = nil,
			["ColorB"] = nil,
			["SecondIcon"] = true,
			["DormantCheck"] = false,
			["MinimapImage"] = "minimap_ping_teleporting"
		},
		{
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
	Console.Print("\n[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.5 ] Script load.\n\n")
	
	for i = #ParticleData, 1, -1 do
		ParticleData[i] = nil
	end
	ParticleData = {}
	
	widthScreen, heightScreen = nil, nil

	myHero = nil
	ValueOnDraw, ValueParticleUpdate, ValueParticleDestroy = nil, nil, nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	ShowTeleport.NeedInit = true
end

function ShowTeleport.OnGameEnd()
	for i = #ParticleData, 1, -1 do
		ParticleData[i] = nil
	end
	ParticleData = {}

	widthScreen, heightScreen = nil, nil
	
	ValueOnDraw, ValueParticleUpdate, ValueParticleDestroy = nil, nil, nil
	myHero = nil
	TempUnitName, xCoor, yCoor = nil, nil, nil
	ShowTeleport.NeedInit = true
	
	collectgarbage("collect")
	
	Console.Print("\n[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.5 ] Game end. Reset all variable.\n\n")
end

function ShowTeleport.IsUniqueParticle(particle)
	local idx = nil
	local ValueUniqueParticle = nil
	
	for i = 1, 5 do
		ValueUniqueParticle = ParticleManager[1][i]
	
		if particle.name == ValueUniqueParticle.Name then
			idx = particle.index
			
			if idx > -1 then
				idx = idx * -1
			end
			
			ParticleData[#ParticleData + 1] = {
				index = particle.index,
				name = ValueUniqueParticle.Name,
				TrackUntil = GameRules.GetGameTime() + ValueUniqueParticle.TrackDuration,
				entity = particle.entityForModifiers or nil,
				Position = nil,
				IconIndex = idx,
				SecondIndex = nil,
				ColorR = ValueUniqueParticle.ColorR,
				ColorG = ValueUniqueParticle.ColorG,
				ColorB = ValueUniqueParticle.ColorB,
				SecondIcon = ValueUniqueParticle.SecondIcon or false,
				DormantCheck = ValueUniqueParticle.DormantCheck,
				Texture = ValueUniqueParticle.MinimapImage or nil,
				SecondTexture = nil
			}
			return true
		end
	end
	
	return false
end

function ShowTeleport.IsNonUniqueParticle(particle)
	local idx = nil
	local ValueParticleNonUnique = ParticleManager[2]
	
	if particle.name == ValueParticleNonUnique[1] then
		idx = particle.index
			
		if idx > -1 then
			idx = idx * -1
		end
			
		ParticleData[#ParticleData + 1] = {
			index = particle.index,
			name = ValueParticleNonUnique[1],
			TrackUntil = GameRules.GetGameTime() + ValueParticleNonUnique[2],
			entity = particle.entity or nil,
			Position = nil,
			IconIndex = idx,
			SecondIndex = nil,
			ColorR = ValueParticleNonUnique[3],
			ColorG = ValueParticleNonUnique[4],
			ColorB = ValueParticleNonUnique[5],
			SecondIcon = ValueParticleNonUnique.SecondIcon or false,
			DormantCheck = ValueParticleNonUnique[6],
			Texture = ValueParticleNonUnique[7] or nil,
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
	
	ValueParticleUpdate = nil
	
	for i = 1, #ParticleData do
		ValueParticleUpdate = ParticleData[i]
		
		if ValueParticleUpdate ~= nil and particle.index == ValueParticleUpdate.index then
			if particle.controlPoint == 0 then
				if ParticleManager[3][1][ValueParticleUpdate.name] then
					if ValueParticleUpdate.Position == nil then
						ValueParticleUpdate.Position = particle.position
					end
				end
			end
			
			if particle.controlPoint == 1 then
				if ParticleManager[3][2][ValueParticleUpdate.name] then
					if ValueParticleUpdate.Position == nil then
						ValueParticleUpdate.Position = particle.position
						
						if ValueParticleUpdate.SecondIcon == true and ValueParticleUpdate.SecondTexture == nil then
							ValueParticleUpdate.SecondTexture = Hero.GetIcon(ValueParticleUpdate.entity)
							ValueParticleUpdate.SecondIndex = MiniMap.AddIcon(nil, ValueParticleUpdate.SecondTexture, ValueParticleUpdate.Position, 255, 255, 255, 255, 0, 1200)
							
							if ValueParticleUpdate.SecondIndex > -1 then
								ValueParticleUpdate.SecondIndex = ValueParticleUpdate.SecondIndex * -1
							end
						end
					end
				end
			end
			
			if particle.controlPoint == 2 then
				if ParticleManager[3][3][ValueParticleUpdate.name] then
					if ValueParticleUpdate.ColorR == nil then
						ValueParticleUpdate.ColorR = FunctionFloor(255 * particle.position:GetX())
					end
					
					if ValueParticleUpdate.ColorG == nil then
						ValueParticleUpdate.ColorG = FunctionFloor(255 * particle.position:GetY())
					end
					
					if ValueParticleUpdate.ColorB == nil then
						ValueParticleUpdate.ColorB = FunctionFloor(255 * particle.position:GetZ())
					end
					
					if ValueParticleUpdate.SecondIcon == true and ValueParticleUpdate.SecondTexture == nil then
						ValueParticleUpdate.SecondTexture = Hero.GetIcon(ValueParticleUpdate.entity)
						ValueParticleUpdate.SecondIndex = MiniMap.AddIcon(nil, ValueParticleUpdate.SecondTexture, ValueParticleUpdate.Position, 255, 255, 255, 255, 0, 1200)
							
						if ValueParticleUpdate.SecondIndex > -1 then
							ValueParticleUpdate.SecondIndex = ValueParticleUpdate.SecondIndex * -1
						end
					end
				end
			end
			
			if particle.controlPoint == 5 then
				if ParticleManager[3][4][ValueParticleUpdate.name] then
					if ValueParticleUpdate.Position == nil then
						ValueParticleUpdate.Position = particle.position
					end
				end
			end
        end
	end
end

function ShowTeleport.OnParticleDestroy(particle)
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if myHero == nil then return end
	
	ValueParticleDestroy = nil
	
	for i = #ParticleData, 1, -1 do
		ValueParticleDestroy = ParticleData[i]

		if 
			ValueParticleDestroy ~= nil
			and particle.index == ValueParticleDestroy.index
		then
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


function ShowTeleport.OnUpdate()
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	
	if ShowTeleport.NeedInit == true then
		widthScreen, heightScreen = Renderer.GetScreenSize()
		
		for i = #ParticleData, 1, -1 do
			ParticleData[i] = nil
		end
		ParticleData = {}
		
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		
		ValueOnDraw, ValueParticleUpdate, ValueParticleDestroy = nil, nil, nil
		TempUnitName, xCoor, yCoor = nil, nil, nil
		ShowTeleport.NeedInit = false
		
		Console.Print("\n[" .. os.date("%I:%M:%S %p") .. "] - - [ ShowTeleport.lua ] [ Version 0.5 ] Game started, init script done.\n\n")
	end
	
	if myHero == nil then return end
end

function ShowTeleport.OnDraw()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ShowTeleport.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	if ShowTeleport.NeedInit == true then return end
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
						
						--[[
							This is drawing world icon for example in teleport will draw image on ground when teleport from fog.
						--]]
						if Menu.IsEnabled(ShowTeleport.optionEnableWorldDraw) == true then
							TempUnitName = NPC.GetUnitName(ValueOnDraw.entity)
							xCoor, yCoor = Renderer.WorldToScreen(ValueOnDraw.Position)
							
							if ShowTeleport.IsOnScreen(xCoor, yCoor) == true then
								Renderer.SetDrawColor(255, 255, 255, 255)
								
								if LuaStringFind(TempUnitName, "npc_dota_lone_druid_bear") then
									Renderer.DrawImage("panorama/images/heroes/npc_dota_lone_druid_bear_png.vtex_c", (xCoor - 24), (yCoor - 24), 48, 48)
								else
									Renderer.DrawIcon(Hero.GetIcon(ValueOnDraw.entity), (xCoor - 24), (yCoor - 24), 48, 48)
								end
							end
						end
								
					end
				else
					--[[
						This is draw hero icon for example furion skill 2.
					--]]
					MiniMap.AddIconByName(ValueOnDraw.IconIndex, ValueOnDraw.Texture, ValueOnDraw.Position, ValueOnDraw.ColorR, ValueOnDraw.ColorG, ValueOnDraw.ColorB, 255, 0.1, 1200)
							
					if ValueOnDraw.SecondIcon == true then
						MiniMap.AddIcon(ValueOnDraw.SecondIndex, ValueOnDraw.SecondTexture, ValueOnDraw.Position, 255, 255, 255, 255, 0.1, 900)
					end
				end
			end
		end
	end
end

return ShowTeleport