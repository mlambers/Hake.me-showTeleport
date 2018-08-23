local testTeleportMinimap = {}

testTeleportMinimap.optionEnable = Menu.AddOption({"mlambers", "Minimap Teleport Info"}, "1. Enable", "Turn On/Off this script.")

testTeleportMinimap.UtilityTable = {
	{
		teleport_end = true,
		teleport_end_bots = true,
		furion_teleport = true,
		furion_teleport_end = true
	}
}

testTeleportMinimap.NeedInit = true
testTeleportMinimap.DoneInit = false
local widthScreen, heightScreen = nil, nil
local myHero = nil
local GameTime = 0
local particlesTable = {}
local LuaMathFloor = math.floor

local Assets = {}
Assets.Images = {}
Assets.Path = "panorama/images/heroes/icons/"

function testTeleportMinimap.OnScriptLoad()
	for k in pairs(particlesTable) do
		particlesTable[k] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
	widthScreen, heightScreen = nil, nil
	myHero = nil
	testTeleportMinimap.DoneInit = false
	testTeleportMinimap.NeedInit = true
end

function testTeleportMinimap.OnGameStart()
	for k in pairs(particlesTable) do
		particlesTable[k] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
	
	if myHero == nil then
		myHero = Heroes.GetLocal()
	end
	
	widthScreen, heightScreen = nil, nil

	testTeleportMinimap.DoneInit = false
	testTeleportMinimap.NeedInit = true
end

function testTeleportMinimap.OnGameEnd()
	for k in pairs(particlesTable) do
		particlesTable[k] = nil
	end
	particlesTable = {}
	
	for k in pairs(Assets.Images) do
		Assets.Images[k] = nil
	end
	Assets.Images = {}
	
	GameTime = 0
	widthScreen, heightScreen = nil, nil
	myHero = nil
	testTeleportMinimap.DoneInit = false
	testTeleportMinimap.NeedInit = true
end

function testTeleportMinimap.InsertParticleTable(particle)
	if testTeleportMinimap.UtilityTable[1][particle.name] then
		if (particle.name == "teleport_end" or particle.name == "teleport_end_bots") and Entity.IsSameTeam(myHero, particle.entityForModifiers) == false then
			particlesTable[#particlesTable + 1] =  {
				index = particle.index,
				name = particle.name,
				PositionCaster = nil,
				PositionEnd = nil,
				RedVal = nil,
				GreenVal = nil,
				BlueVal = nil,
				HasSecondIcon = false,
				SecondIcon = nil,
				ent = nil,
				endTime = GameRules.GetGameTime() + 5,
			}
			
			return true
		elseif (particle.name == "furion_teleport_end") and Entity.IsSameTeam(myHero, particle.entityForModifiers) == false then
			particlesTable[#particlesTable + 1] =  {
				index = particle.index,
				name = particle.name,
				PositionCaster = nil,
				PositionEnd = nil,
				RedVal = 128,
				GreenVal = 128,
				BlueVal = 128,
				HasSecondIcon = true,
				SecondIcon = Hero.GetIcon(particle.entityForModifiers),
				ent = particle.entityForModifiers,
				endTime = GameRules.GetGameTime() + 5,
			}
			
			return true
		elseif (particle.name == "furion_teleport") and Entity.IsSameTeam(myHero, particle.entity) == false then
			particlesTable[#particlesTable + 1] =  {
				index = particle.index,
				name = particle.name,
				PositionCaster = nil,
				PositionEnd = nil,
				RedVal = 255,
				GreenVal = 255,
				BlueVal = 255,
				HasSecondIcon = false,
				SecondIcon = nil,
				ent = particle.entity,
				endTime = GameRules.GetGameTime() + 5,
			}
			
			return true
		end	
	end
    return false
end

function testTeleportMinimap.OnParticleCreate(particle)
	if Menu.IsEnabled(testTeleportMinimap.optionEnable) == false then return end
	
	testTeleportMinimap.InsertParticleTable(particle)
end

function testTeleportMinimap.OnParticleUpdate(particle)
	if Menu.IsEnabled(testTeleportMinimap.optionEnable) == false then return end
	
	for k, tableValue in  pairs(particlesTable) do
		if (tableValue ~= nil) and (particle.index == tableValue.index) then
			if particle.controlPoint == 0 and (tableValue.name == "furion_teleport") then
				if tableValue.PositionCaster == nil then
					tableValue.PositionCaster = particle.position
				end
			elseif particle.controlPoint == 1 and (tableValue.name == "furion_teleport_end") then
				if tableValue.PositionEnd == nil then
					tableValue.PositionEnd = particle.position
				end
			elseif particle.controlPoint == 5 and (tableValue.name == "teleport_end" or tableValue.name == "teleport_end_bots") then
				if tableValue.PositionEnd == nil then
					tableValue.PositionEnd = particle.position
				end
			elseif particle.controlPoint == 2 and (tableValue.name == "teleport_end" or tableValue.name == "teleport_end_bots") then
				if tableValue.RedVal == nil then
					tableValue.RedVal = LuaMathFloor(particle.position:GetX() * 255)
				end
				
				if tableValue.GreenVal == nil then
					tableValue.GreenVal = LuaMathFloor(particle.position:GetY() * 255)
				end
				
				if tableValue.BlueVal == nil then
					tableValue.BlueVal = LuaMathFloor(particle.position:GetZ() * 255)
				end
			end
		end
	end
end

function testTeleportMinimap.OnParticleUpdateEntity(particle)
	if Menu.IsEnabled(testTeleportMinimap.optionEnable) == false then return end
	
	for k, tableValue in  pairs(particlesTable) do
		if (tableValue ~= nil) and (particle.index == tableValue.index) then
			if particle.controlPoint == 3 and (tableValue.name == "teleport_end" or tableValue.name == "teleport_end_bots") then
				if tableValue.PositionCaster == nil then
					tableValue.PositionCaster = particle.position
					tableValue.ent = particle.entity
				end
			
			end
		end
	end
end

function testTeleportMinimap.OnParticleDestroy(particle)
	if Menu.IsEnabled(testTeleportMinimap.optionEnable) == false then return end
	
	for k, tableValue in  pairs(particlesTable) do
		if (tableValue ~= nil) and (particle.index == tableValue.index) then
			particlesTable[k] = nil
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
	
	if (x > widthScreen) or ( y > widthScreen) then 
		return false
	end
	
	return true
end

function testTeleportMinimap.OnDraw()
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(testTeleportMinimap.optionEnable) == false then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	
	if testTeleportMinimap.NeedInit then
		widthScreen, heightScreen = Renderer.GetScreenSize()
		
		if myHero == nil then
			myHero = Heroes.GetLocal()
		end
		
		testTeleportMinimap.DoneInit = true
	end
	
	if not myHero then return end
	
	GameTime = GameRules.GetGameTime()
	
	if testTeleportMinimap.DoneInit then
		for k, tableValue in pairs(particlesTable) do
			if tableValue ~= nil then
				if GameTime >= tableValue.endTime then
					particlesTable[k] = nil
				end
				
				if tableValue.PositionEnd then
					MiniMap.AddIconByName(nil, "minimap_ping_teleporting", tableValue.PositionEnd, tableValue.RedVal, tableValue.GreenVal, tableValue.BlueVal, 255, 0.15, 1200)
					if tableValue.HasSecondIcon then
						MiniMap.AddIcon(nil, tableValue.SecondIcon, tableValue.PositionEnd, 255, 255, 255, 255, 0.15, 1000)
					end
				end
				
				if tableValue.PositionCaster and Entity.IsDormant(tableValue.ent) then
					if Entity.IsHero(tableValue.ent) then
						MiniMap.AddIconByName(nil, "minimap_herocircle", tableValue.PositionCaster, tableValue.RedVal, tableValue.GreenVal, tableValue.BlueVal, 255, 0.15, 1200)
					else
						MiniMap.AddIconByName(nil, "minimap_enemyimage", tableValue.PositionCaster, 255, 255, 255, 255, 0.15, 1200)
					end
				end
			end
		end
	end
end


return testTeleportMinimap