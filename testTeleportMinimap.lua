local testTeleportMinimap = {}

testTeleportMinimap.optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Turn On/Off this script.")
testTeleportMinimap.optionEnableWorldDraw = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "2. Enable world draw", "")
testTeleportMinimap.optionEnableLogging = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "3. Enable logging", "Should just disable this, only for development")

testTeleportMinimap.UtilityTable = {
	{
		teleport_start = true,
		teleport_start_bots = true,
		furion_teleport = true,
	},
	
	{ 
		teleport_end = true,
		teleport_end_bots = true,
		furion_teleport_end = true
	},
	
	{
		teleport_start = true,
		teleport_end = true,
		teleport_start_bots = true,
		teleport_end_bots = true,
		furion_teleport = true,
		furion_teleport_end = true
	},
	
	{
		{255, 255, 255},
		{51, 117, 255},
		{102, 255, 191},
		{191, 0, 191},
		{243, 240, 11},
		{255, 107, 0},
		{254, 134, 194},
		{161, 180, 71},
		{101, 217, 247},
		{0, 131, 33},
		{164, 105, 0}
	}
}

local GameTime = 0
local particlesTable = {}
local LuaStringFind = string.find
local Assets = {}
Assets.Images = {}
Assets.Path = "panorama/images/heroes/icons/"

function testTeleportMinimap.OnScriptLoad()
	for i = #particlesTable, 1, -1 do
		particlesTable[i] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
end

function testTeleportMinimap.OnGameStart()
	for i = #particlesTable, 1, -1 do
		particlesTable[i] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
end

function testTeleportMinimap.OnGameEnd()
	for i = #particlesTable, 1, -1 do
		particlesTable[i] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
end

function testTeleportMinimap.InsertParticleTable(particle)
    local myHero = Heroes.GetLocal()
	
	if testTeleportMinimap.UtilityTable[3][particle.name] and (particle.entity or particle.entityForModifiers) then
		if particle.entity and (particle.name == "furion_teleport") and not Entity.IsSameTeam(myHero, particle.entity)  then
			if Entity.IsHero(particle.entity) then
				particlesTable[#particlesTable + 1] =  {
					index = particle.index,
					name = particle.name,
					ent = particle.entity,
					endTime = GameRules.GetGameTime() + 5,
					isHero = true,
					playerID = Hero.GetPlayerID(particle.entity)
				}
				
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success added particle['" .. particle.name .. "'] into table.")
				end
				
				return true
			else
				local entOwner = Entity.GetOwner(particle.entity)
				particlesTable[#particlesTable + 1] = {
					index = particle.index,
					name = particle.name,
					ent = particle.entity,
					endTime = GameRules.GetGameTime() + 5,
					isHero = false,
					playerID = Hero.GetPlayerID(entOwner)
				}
				
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success added particle['" .. particle.name .. "'] into table.")
				end
				
				return true
			end
		elseif particle.entityForModifiers and particle.name ~= "furion_teleport" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers) then
			if Entity.IsHero(particle.entityForModifiers) then
				particlesTable[#particlesTable + 1] = {
					index = particle.index,
					name = particle.name,
					ent = particle.entityForModifiers,
					endTime = GameRules.GetGameTime() + 5,
					isHero = true,
					playerID = Hero.GetPlayerID(particle.entityForModifiers)
				}
					
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success added particle['" .. particle.name .. "'] into table.")
				end
					
				return true
			else
				local entOwner = Entity.GetOwner(particle.entityForModifiers)
				particlesTable[#particlesTable + 1] = {
					index = particle.index,
					name = particle.name,
					ent = particle.entityForModifiers,
					endTime = GameRules.GetGameTime() + 5,
					isHero = false,
					playerID = Hero.GetPlayerID(entOwner)
				}
					
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success added particle['" .. particle.name .. "'] into table.")
				end
					
				return true
			end
		end	
	end
    return false
end

function testTeleportMinimap.OnParticleCreate(particle)
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	
	testTeleportMinimap.InsertParticleTable(particle)
end

function testTeleportMinimap.OnParticleUpdate(particle)
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	
	for i = 1, #particlesTable do
		local tableValue = particlesTable[i]
		if (tableValue ~= nil) and (particle.index == tableValue.index) then
			if particle.controlPoint == 1 and tableValue.name == "furion_teleport_end" then
				particlesTable[i].position = particle.position
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success update particle['" .. tableValue.name .. "'] position vector.")
				end
			elseif particle.controlPoint == 0 and tableValue.name ~= "furion_teleport_end" then
				particlesTable[i].position = particle.position
				if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
					Log.Write("Success update particle['" .. tableValue.name .. "'] position vector.")
				end
			end
		end
	end
end

function testTeleportMinimap.OnParticleUpdateEntity(particle)
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	
	for i = 1, #particlesTable do
		local tableValue = particlesTable[i]
        if (tableValue ~= nil) and particle.index == tableValue.index then
			if particle.controlPoint == 0 and (tableValue.name == "teleport_end" or tableValue.name == "teleport_end_bots") then
				particlesTable[i].position = particle.position
			end
        end
    end
end

function testTeleportMinimap.OnParticleDestroy(particle)
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	
	for i = 1, #particlesTable do
        if (particlesTable[i] ~= nil) and particle.index == particlesTable[i].index then
            particlesTable[i] = nil
			if Menu.IsEnabled(testTeleportMinimap.optionEnableLogging) then
				Log.Write("Success delete table using OnParticleDestroy.")
			end
        end
    end
end

function testTeleportMinimap.LoadImage(prefix, name, path)
	local imageHandle = Assets.Images[prefix .. name]

	if (imageHandle == nil) then
		
		imageHandle = Renderer.LoadImage(path .. name .. "_png.vtex_c")
		Assets.Images[prefix .. name] = imageHandle
		imageHandle = nil
	end
	
	return Assets.Images[prefix .. name]
end

function testTeleportMinimap.IsOnScreen(x, y)
	if (x < 1) or (y < 1) then 
		return false 
	end
	
	local widthScreen, heightScreen = Renderer.GetScreenSize()
	
	if (x > widthScreen) or ( y > widthScreen) then 
		return false
	end
	
	return true
end

function testTeleportMinimap.OnDraw()
	if Engine.IsInGame() == false then return end
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	
	GameTime = GameRules.GetGameTime()
	
	for i = 1, #particlesTable do
		local tableValue = particlesTable[i]
		if tableValue ~= nil then
			local particle_end_time = tableValue.endTime
			local particle_position = tableValue.position
			local particle_name = tableValue.name
			local particle_ent = tableValue.ent
			local indexTable = tableValue.playerID + 2
			
			local redChannel = testTeleportMinimap.UtilityTable[4][indexTable][1]
			local greenChannel = testTeleportMinimap.UtilityTable[4][indexTable][2]
			local blueChannel = testTeleportMinimap.UtilityTable[4][indexTable][3]
			local alphaChannel = 255
		
			if particle_end_time > GameTime then
				if particle_position then
					
					if testTeleportMinimap.UtilityTable[1][particle_name] and Entity.IsDormant(particle_ent) then
						if tableValue.isHero then
							MiniMap.AddIconByName(nil, "minimap_herocircle", particle_position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1100)
						else
							MiniMap.AddIconByName(nil, "minimap_enemyimage", particle_position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1100)
						end
						
						if Menu.IsEnabled(testTeleportMinimap.optionEnableWorldDraw) then
							local UnitName = NPC.GetUnitName(particle_ent)
							local x, y = Renderer.WorldToScreen(particle_position)
							if testTeleportMinimap.IsOnScreen(x, y) then
								if LuaStringFind(UnitName, "npc_dota_lone_druid_bear") then
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawImage(testTeleportMinimap.LoadImage("icon_", "lone_druid_spirit_bear", "panorama/images/spellicons/"), (x - 24), (y - 24), 48.0, 48.0)
								else
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawImage(testTeleportMinimap.LoadImage("icon_", UnitName, Assets.Path), (x - 24), (y - 24), 48.0, 48.0)
								end
							end
						end
						
					elseif testTeleportMinimap.UtilityTable[2][particle_name] then
						if tableValue.isHero then
							MiniMap.AddIconByName(nil, "minimap_ping_teleporting", particle_position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1100)
						else
							MiniMap.AddIconByName(nil, "minimap_ping_teleporting", particle_position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1100)
						end
					end
				end
			else
				particlesTable[i] = nil
			end
		end
	end
end

return testTeleportMinimap