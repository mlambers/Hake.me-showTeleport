local testTeleportMinimap = {}

testTeleportMinimap.optionEnable = Menu.AddOption({"TEST", "Minimap Teleport Info"}, "1. On/Off script.", "Shows teleport")
testTeleportMinimap.optionEnableWorldDraw = Menu.AddOption({"TEST", "Minimap Teleport Info"}, "2. Enable world draw.", "")
testTeleportMinimap.particleTable = {}
testTeleportMinimap.rgbaTable = { }
testTeleportMinimap.rgbaTable[0] = 
{
	redChannel = 44,
    greenChannel = 103,
    blueChannel = 226,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[1] = 
{
	redChannel = 102,
    greenChannel = 255,
    blueChannel = 191,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[2] = 
{
	redChannel = 191,
    greenChannel = 0,
    blueChannel = 191,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[3] = 
{
	redChannel = 243,
    greenChannel = 240,
    blueChannel = 11,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[4] = 
{
	redChannel = 255,
    greenChannel = 107,
    blueChannel = 0,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[5] = 
{
	redChannel = 254,
    greenChannel = 134,
    blueChannel = 194,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[6] = 
{
	redChannel = 161,
    greenChannel = 180,
    blueChannel = 71,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[7] = 
{
	redChannel = 101,
    greenChannel = 217,
    blueChannel = 247,
    alphaChannel = 255
}

testTeleportMinimap.rgbaTable[8] = 
{
	redChannel = 0,
    greenChannel = 131,
    blueChannel = 33,
    alphaChannel = 255
}		

testTeleportMinimap.rgbaTable[9] = 
{
	redChannel = 164,
    greenChannel = 105,
    blueChannel = 0,
    alphaChannel = 255
}

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

function testTeleportMinimap.OnUpdate()
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
					MiniMap.AddIconByName(nil, "minimap_ping_teleporting", tableParticle.position, testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["redChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["greenChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["blueChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["alphaChannel"], 0.1, 1000)
					
				else
					local entOwner = Entity.GetOwner(tableParticle.ent)
					MiniMap.AddIconByName(nil, "minimap_ping_teleporting", tableParticle.position, testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["redChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["greenChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["blueChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["alphaChannel"], 0.1, 1000)
				end
				
			elseif tableParticle.position and (tableParticle.name == "teleport_start" or tableParticle.name == "teleport_start_bots"  or tableParticle.name == "furion_teleport") and Entity.IsDormant(tableParticle.ent) then
				if Entity.IsHero(tableParticle.ent) then
					--MiniMap.AddIcon(nil, Hero.GetIcon(tableParticle.ent), tableParticle.position, testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["redChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["greenChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["blueChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["alphaChannel"], 0.1, 900)
					MiniMap.AddIconByName(nil, "minimap_herocircle", tableParticle.position, testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["redChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["greenChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["blueChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(tableParticle.ent)]["alphaChannel"], 0.1, 1000)
					if Menu.IsEnabled(testTeleportMinimap.optionEnableWorldDraw) then 
						local x, y = Renderer.WorldToScreen(tableParticle.position)
						Renderer.SetDrawColor(255, 255, 255, 255)
						Renderer.DrawImage( GUIDB.Image('mini_' .. NPC.GetUnitName(tableParticle.ent)), x, y, 50, 50)
					end
					
				else
					local entOwner = Entity.GetOwner(tableParticle.ent)
					MiniMap.AddIconByName(nil, "minimap_enemyimage", tableParticle.position, testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["redChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["greenChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["blueChannel"], testTeleportMinimap.rgbaTable[Hero.GetPlayerID(entOwner)]["alphaChannel"], 0.1, 1000)
					if Menu.IsEnabled(testTeleportMinimap.optionEnableWorldDraw) then 
						local x, y = Renderer.WorldToScreen(tableParticle.position)
						Renderer.SetDrawColor(255, 255, 255, 255)
						Renderer.DrawImage( GUIDB.Image('mini_' .. NPC.GetUnitName(entOwner)), x, y, 50, 50)
					end
				end
            end
			
		end
	end
end

return testTeleportMinimap