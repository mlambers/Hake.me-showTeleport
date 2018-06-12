local testTeleportMinimap = {}
local funcFloor = math.floor
testTeleportMinimap.optionEnable = Menu.AddOption({"TEST", "Minimap Teleport Info"}, "1. On/Off script.", "Shows teleport")
testTeleportMinimap.optionEnableWorldDraw = Menu.AddOption({"TEST", "Minimap Teleport Info"}, "2. Enable world draw.", "")
testTeleportMinimap.particleTable = {}
testTeleportMinimap.rgbaTable = { }
testTeleportMinimap.rgbaTable[-1] = 
{
	color = Vector(1.0, 1.0, 1.0)
}

testTeleportMinimap.rgbaTable[0] = 
{
	color = Vector(0.20000001788139, 0.4588235616684, 1.0)
}

testTeleportMinimap.rgbaTable[1] = 
{
	color = Vector(0.40000003576279, 1.0, 0.74901962280273)
}

testTeleportMinimap.rgbaTable[2] = 
{
	color = Vector(0.74901962280273, 0.0, 0.74901962280273)
}

testTeleportMinimap.rgbaTable[3] = 
{
	color = Vector(0.95294123888016, 0.94117653369904, 0.04313725605607)
}

testTeleportMinimap.rgbaTable[4] = 
{
	color = Vector(1.0, 0.41960787773132, 0.0)
}

testTeleportMinimap.rgbaTable[5] = 
{
	color = Vector(0.99607849121094, 0.52549022436142, 0.7607843875885)
}

testTeleportMinimap.rgbaTable[6] = 
{
	color = Vector(0.63137257099152, 0.70588237047195, 0.27843138575554) 
}

testTeleportMinimap.rgbaTable[7] = 
{
	color = Vector(0.39607846736908, 0.85098046064377, 0.96862751245499)
}

testTeleportMinimap.rgbaTable[8] = 
{
	color = Vector(0.0, 0.5137255191803, 0.1294117718935)
}		

testTeleportMinimap.rgbaTable[9] = 
{
	color = Vector(0.64313727617264, 0.41176474094391, 0.0)
}

function testTeleportMinimap.OnScriptLoad()
	testTeleportMinimap.particleTable = {}
end

function testTeleportMinimap.OnGameStart()
	testTeleportMinimap.particleTable = {}
end
function testTeleportMinimap.OnGameEnd()
	testTeleportMinimap.particleTable = {}
end

function testTeleportMinimap.InsertParticleTable(particle)
    local myHero = Heroes.GetLocal()

   if particle.name == "teleport_end" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers) then

    
		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entityForModifiers,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	elseif particle.name == "teleport_end_bots" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers) then

    
		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entityForModifiers,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	elseif particle.name == "furion_teleport_end" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers ) then

    
		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entityForModifiers ,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	elseif particle.name == "teleport_start_bots" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers) then

    
		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entityForModifiers,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	elseif particle.name == "teleport_start" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers) then

		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entityForModifiers,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	elseif particle.name == "furion_teleport" and not Entity.IsSameTeam(Heroes.GetLocal(), particle.entityForModifiers ) then

    
		local temptable = 
		{
			index = particle.index,
			name = particle.name,
			ent = particle.entity ,
			endTime = GameRules.GetGameTime() + 10
		}
		table.insert(testTeleportMinimap.particleTable, temptable)
		
		return true
	end

    return false
end


function testTeleportMinimap.OnParticleCreate(particle)

	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	if not Heroes.GetLocal() then return end
	--Log.Write(particle.name)
	testTeleportMinimap.InsertParticleTable(particle)
end

function testTeleportMinimap.OnParticleUpdate(particle)
    for k, tableParticle in ipairs(testTeleportMinimap.particleTable) do
        if particle.index == tableParticle.index then
			if tableParticle.name == "furion_teleport_end" and particle.controlPoint == 1 then
				tableParticle.position = particle.position
			elseif tableParticle.name ~= "furion_teleport_end" and particle.controlPoint == 0 then
				tableParticle.position = particle.position
			end
        end
    end
end

function testTeleportMinimap.OnParticleUpdateEntity(particle)
	--if particle.controlPoint ~= 0 then return end
    for k, tableParticle in ipairs(testTeleportMinimap.particleTable) do
        if particle.index == tableParticle.index then
			if particle.controlPoint == 0 and (tableParticle.name == "teleport_end" or tableParticle.name == "teleport_end_bots") then
			
				tableParticle.position = particle.position
			end
            
        end
    end
end



function testTeleportMinimap.OnParticleDestroy(particle)
	for k, tableParticle in ipairs(testTeleportMinimap.particleTable) do
        if particle.index == tableParticle.index then
            table.remove(testTeleportMinimap.particleTable, k)
        end
    end
end

function testTeleportMinimap.OnDraw()
	if not Menu.IsEnabled(testTeleportMinimap.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	
	if not myHero then return end
	
	
	
	for i, tableParticle in ipairs(testTeleportMinimap.particleTable) do
		local timeLeft = math.max(tableParticle.endTime - GameRules.GetGameTime(), 0)
		
        if timeLeft <= 0 then
            table.remove(testTeleportMinimap.particleTable, i)
		else
			if tableParticle.position and (tableParticle.name == "teleport_end" or tableParticle.name == "teleport_end_bots" or tableParticle.name == "furion_teleport_end") then 
				if Entity.IsHero(tableParticle.ent) then
					local vectorColor = testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["color"]
					local redChannel = funcFloor(vectorColor:GetX() * 255)
					local greenChannel = funcFloor(vectorColor:GetY() * 255)
					local blueChannel = funcFloor(vectorColor:GetZ() * 255)
					local alphaChannel = 255
					MiniMap.AddIconByName(nil, "minimap_ping_teleporting", tableParticle.position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1000)
					
				else
					local entOwner = Entity.GetOwner(tableParticle.ent)
					local vectorColor = testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["color"]
					local redChannel = funcFloor(vectorColor:GetX() * 255)
					local greenChannel = funcFloor(vectorColor:GetY() * 255)
					local blueChannel = funcFloor(vectorColor:GetZ() * 255)
					local alphaChannel = 255
					MiniMap.AddIconByName(nil, "minimap_ping_teleporting", tableParticle.position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1000)
				end
				
			elseif tableParticle.position and (tableParticle.name == "teleport_start" or tableParticle.name == "teleport_start_bots"  or tableParticle.name == "furion_teleport") and Entity.IsDormant(tableParticle.ent) then
				if Entity.IsHero(tableParticle.ent) then
					local vectorColor = testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["color"]
					local redChannel = funcFloor(vectorColor:GetX() * 255)
					local greenChannel = funcFloor(vectorColor:GetY() * 255)
					local blueChannel = funcFloor(vectorColor:GetZ() * 255)
					local alphaChannel = 255
					MiniMap.AddIconByName(nil, "minimap_herocircle", tableParticle.position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1000)
					if Menu.IsEnabled(testTeleportMinimap.optionEnableWorldDraw) then 
						local x, y = Renderer.WorldToScreen(tableParticle.position)
						local specsize = 50 - math.floor(50 / 4)
						Renderer.SetDrawColor(255, 255, 255, 255)
						Renderer.DrawImage( GUIDB.Image('mini_' .. NPC.GetUnitName(tableParticle.ent)), x - math.ceil(specsize / 2), y - math.ceil(specsize / 2), specsize, specsize)
					end
					
				else
					local entOwner = Entity.GetOwner(tableParticle.ent)
					local vectorColor = testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["color"]
					local redChannel = funcFloor(vectorColor:GetX() * 255)
					local greenChannel = funcFloor(vectorColor:GetY() * 255)
					local blueChannel = funcFloor(vectorColor:GetZ() * 255)
					local alphaChannel = 255
					
					MiniMap.AddIconByName(nil, "minimap_enemyimage", tableParticle.position, redChannel, greenChannel, blueChannel, alphaChannel, 0.1, 1000)
					if Menu.IsEnabled(testTeleportMinimap.optionEnableWorldDraw) then 
						local x, y = Renderer.WorldToScreen(tableParticle.position)
						local specsize = 50 - math.floor(50 / 4)
						Renderer.SetDrawColor(255, 255, 255, 255)
						Renderer.DrawImage( GUIDB.Image('mini_' .. NPC.GetUnitName(entOwner)), x - math.ceil(specsize / 2), y - math.ceil(specsize / 2), specsize, specsize)
					end
				end
            end
			
		end
	end
end

return testTeleportMinimap