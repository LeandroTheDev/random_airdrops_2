-- Stores the airdrops data
-- {
--  "10,10,1" = {
--      name = "Example",
--      algebricCoords = "A1", -- Algebric coords the players will see when airdrop spawn
--      spawned = false, -- Boolean to check if the airdrop is spawned in the world
--      ticksToDespawn = 100, -- Every hour a tick will be decremented, if 0 then next time the chunk is loaded we will despawn (only if spawned is true)
--      shouldRespawn = false -- If the airdrop is spawned and needs to be despawned but another airdrop spawned in the same position, then we need to respawn it
--      despawnOnNextLoad = false -- If this is false then the airdrop will not despawn until next chunk load (to prevent despawning when players is seeing)
--      despawnTries = 0 -- How many times the function despawnAirdrop could not despawn, if bigger than 5 it will be ignored permanently
--  }
-- }
local airdropsData = {};

-- Stores the Lua config with the spawner positions
-- {
--  "10,10,1" = {
--      name = "Example"
--      algebricCoords = "A1",
--  }
-- }
local airdropConfigPositions = {};

-- Stores the Lua config with the items to spawn in airdrop
-- [
--  {
--      type = "combo",
--      chance = 100,
--      child = {
--          type = "item",
--          chance = 100,
--          quantity = 5,
--          child = "Base.Axe"
--      }
--  }
-- ]
local airdropConfigLootTable = {};

--#region Configs

local function LoadAirdropPositions()
    local path = "RandomAirdropsPositions.ini"
    local fileReader = getFileReader(path, true)

    local lines = {}
    if fileReader then
        local line = fileReader:readLine()
        while line do
            table.insert(lines, line)
            line = fileReader:readLine()
        end
        fileReader:close()
    end

    -- Default value if not exist
    if #lines == 0 then
        local defaultContent = [[
return {
    ["10023,11007,0"] = { name = "March_Ridge", algebricCoords = "A1" },
    ["11702,9688,0"] = { name = "Muldraught", algebricCoords = "A1" },
    ["11580,8824,0"] = { name = "Dixie", algebricCoords = "A1" },
    ["6659,10096,0"] = { name = "Doe_Valley", algebricCoords = "A1" },
    ["10080,12603,0"] = { name = "March_Ridge", algebricCoords = "A1" },
    ["9194,11812,0"] = { name = "Rosewood", algebricCoords = "A1" },
    ["5615,5933,0"] = { name = "Riverside", algebricCoords = "A1" },
    ["11289,7114,0"] = { name = "West_Point", algebricCoords = "A1" },
    ["10150,6859,0"] = { name = "Nearest_West_Point", algebricCoords = "A1" },
    ["3785,9166,0"] = { name = "Far_Away_from_Riverside", algebricCoords = "A1" },
    ["5710,11186,0"] = { name = "Far_Away_from_Rosewood", algebricCoords = "A1" },
    ["14033,5750,0"] = { name = "Valley_Station", algebricCoords = "A1" },
    ["6598,5193,0"] = { name = "Riverside", algebricCoords = "A1" },
    ["7847,11699,0"] = { name = "Nearest_Rosewood", algebricCoords = "A1" },
    ["9790,12356,0"] = { name = "Nearest_March_Ridge", algebricCoords = "A1" },
    ["9363,12546,0"] = { name = "Nearest_Rosewood", algebricCoords = "A1" },
    ["10931,8775,0"] = { name = "Nearest_Muldraught", algebricCoords = "A1" },
    ["12832,4423,0"] = { name = "Louis_Ville", algebricCoords = "A1" },
    ["12873,2305,0"] = { name = "Louis_Ville", algebricCoords = "A1" },
    ["13180,1478,0"] = { name = "Louis_Ville", algebricCoords = "A1" },
    ["12568,1140,0"] = { name = "Louis_Ville", algebricCoords = "A1" },
    ["12227,1441,0"] = { name = "Louis_Ville", algebricCoords = "A1" }
}
]]
        local writer = getFileWriter(path, true, false)
        if writer then
            writer:write(defaultContent)
            writer:close()
        end

        airdropConfigPositions = loadstring(defaultContent)()
        DebugPrintRandomAidrops("Airdrop positions created with default content");
    else
        airdropConfigPositions = loadstring(table.concat(lines, "\n"))() or { ["missing"] = {} }
        DebugPrintRandomAidrops("Airdrop positions loaded")
    end
end

LoadAirdropPositions();

local function LoadAirdropLootTable()
    local path = "RandomAirdropsLootTable.ini"
    local fileReader = getFileReader(path, true)

    local lines = {}
    if fileReader then
        local line = fileReader:readLine()
        while line do
            table.insert(lines, line)
            line = fileReader:readLine()
        end
        fileReader:close()
    end

    -- Default value if not exist
    if #lines == 0 then
        local defaultContent = [[
return {
    {
        type = "combo",
        chance = 100,
        child = {
            {
                type = "item",
                chance = 100,
                quantity = 6,
                child = "Base.CannedCornedBeef"
            },
            {
                type = "item",
                chance = 100,
                quantity = 5,
                child = "Base.WaterBottleFull"
            },
            {
                type = "item",
                chance = 100,
                quantity = 3,
                child = "Base.CannedFruitCocktail"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Ghillie_Top"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Ghillie_Trousers"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Hat_Army"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.HolsterDouble"
            }
        }
    },
    {
        type = "combo",
        chance = 60,
        child = {
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Pistol3"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.44Clip"
            },
            {
                type = "item",
                chance = 70,
                quantity = 5,
                child = "Base.Bullets44Box"
            }
        }
    },
    {
        type = "combo",
        chance = 60,
        child = {
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Shotgun"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.AmmoStraps"
            },
            {
                type = "item",
                chance = 100,
                quantity = 1,
                child = "Base.Sling"
            },
            {
                type = "item",
                chance = 70,
                quantity = 6,
                child = "Base.ShotgunShellsBox"
            }
        }
    },
    {
        type = "combo",
        chance = 100,
        child = {
            {
                type = "item",
                chance = 70,
                quantity = 2,
                child = "Base.HandAxe"
            },
            {
                type = "item",
                chance = 70,
                quantity = 1,
                child = "Base.Crowbar"
            },
            {
                type = "item",
                chance = 70,
                quantity = 1,
                child = "Base.PetrolCan"
            }
        }
    }
}
]]
        local writer = getFileWriter(path, true, false)
        if writer then
            writer:write(defaultContent)
            writer:close()
        end

        airdropConfigLootTable = loadstring(defaultContent)()
        DebugPrintRandomAidrops("Airdrop loot table created with default content");
    else
        airdropConfigLootTable = loadstring(table.concat(lines, "\n"))() or { ["missing"] = {} }
        DebugPrintRandomAidrops("Airdrop loot table loaded")
    end
end

LoadAirdropLootTable();

--#endregion

--#region Utils

-- Check if exist player reading the airdrop chunk
local function checkPlayersAround(x, y, z)
    -- Pikcup the airdrop square
    local square = getCell():getGridSquare(x, y, z);

    -- If the square exist, theres is a player loading the chunk
    if square then
        return true;
    else
        return false
    end
end

local function getCoordsObjectFromStr(coords)
    local x, y, z = coords:match("([^,]+),([^,]+),([^,]+)");
    x = tonumber(x);
    y = tonumber(y);
    z = tonumber(z);

    return { x = x, y = y, z = z };
end

-- Add items to the airdrop
local function spawnAirdropItems(airdrop)
    -- Colecting the airdrop container
    local airdropContainer = airdrop:getPartById("TruckBed"):getItemContainer();

    -- Used for the ID attribute, all ids stored here will be ignored during the loot spawn
    local idSpawneds = {};

    local alocatedSelectedType
    -- swipe the list and call the functions
    -- based on the type.
    -- the function needs to be an parameter because
    -- its is referenced after the listSpawn
    local function listSpawn(list, selectType)
        alocatedSelectedType = selectType;
        -- Swipe all elements from the list
        for i = 1, #list do
            selectType(list[i]);
        end
    end

    -- Type: item
    local function spawnItem(child)
        airdropContainer:AddItem(child);
    end

    -- Type: combo
    local function spawnCombo(child)
        -- Iterate all elements from loot table
        listSpawn(child, alocatedSelectedType);
    end

    -- Type: oneof
    local function spawnOneof(child)
        local selectedIndex = ZombRand(#child) + 1;
        -- listSpawn only accepts lists so we needs to get the specific item
        alocatedSelectedType(child[selectedIndex]);
    end

    local function selectType(element)
        local jump = false;
        -- Checking if the variable ID exist
        if element.id then
            -- Verifying if the id has already added
            if idSpawneds[element.id] then jump = true end
        end
        -- Checking if the chancce is null
        if not element.chance then element.chance = 100 end
        -- Verifying if doesnt need to jump
        if not jump then
            -- Verifying the type
            if element.type == "combo" then
                -- Veryfing if the element has any ID
                if element.id then
                    -- If exist then add it to the idSpawneds list
                    idSpawneds[element.id] = true;
                end
                -- Verifying if quantity is not null
                if element.quantity then
                    -- Add based on the quantity
                    for _ = 1, element.quantity do
                        -- Getting the chance to spawn the child
                        if ZombRand(100) + 1 <= element.chance then
                            -- Adding the item
                            spawnCombo(element.child);
                        end
                    end
                else
                    -- Getting the chance to spawn the child
                    if ZombRand(100) + 1 <= element.chance then
                        -- Adding the item
                        spawnCombo(element.child);
                    end
                end
            elseif element.type == "item" then
                -- Veryfing if the element has any ID
                if element.id then
                    -- If exist then add it to the idSpawneds list
                    idSpawneds[element.id] = true;
                end
                -- Verifying if quantity is not null
                if element.quantity then
                    -- Add based on the quantity
                    for _ = 1, element.quantity do
                        -- Getting the chance to spawn the child
                        if ZombRand(100) + 1 <= element.chance then
                            -- Adding the item
                            spawnItem(element.child);
                        end
                    end
                else
                    -- Getting the chance to spawn the child
                    if ZombRand(100) + 1 <= element.chance then
                        -- Adding the item
                        spawnItem(element.child);
                    end
                end
            elseif element.type == "oneof" then
                -- Verifying if the element has any ID
                if element.id then
                    -- If have add it to idSpawneds list
                    idSpawneds[element.id] = true;
                end
                -- Verifying if quantity is not null
                if element.quantity then
                    -- Adding based on the quantity
                    for _ = 1, element.quantity do
                        -- Getting the chance to spawn the child
                        if ZombRand(100) + 1 <= element.chance then
                            -- Adding the item
                            spawnOneof(element.child);
                        end
                    end
                else
                    -- Getting the chance to spawn the child
                    if ZombRand(100) + 1 <= element.chance then
                        -- Adding the item
                        spawnOneof(element.child);
                    end
                end
            end
        end
    end

    -- Start the loot spawn
    listSpawn(airdropConfigLootTable, selectType);
end

-- Gets configuration available coords to spawn
local function getAvailableCoords()
    local availableCoords = {};

    for coords, _ in pairs(airdropConfigPositions) do
        local available = true;
        for iterationCoords, _ in pairs(airdropsData) do
            if iterationCoords == coords then
                available = false;
                break;
            end
        end
        if available then
            table.insert(availableCoords, coords);
        end
    end

    return availableCoords;
end

--#endregion

--#region Airdrop

-- Randomly generate a specific airdrop data.
-- Generating airdrop data does not spawn the airdrop,
-- To spawn airdrop you should use spawnAirdrop after generateAirdropData
-- to spawn a specific airdrop data you should use a object:
-- {
--  coords = "10,10,1",
--  name = "Specific name"
--  algebricCoords = "A1"
-- }
-- returns the key for airdropsData
local function generateAirdropData(specific)
    if specific then
        if not airdropsData[specific.coords] then
            airdropsData[specific.coords] = {};
            airdropsData[specific.coords].name = specific.name;
            airdropsData[specific.coords].algebricCoords = specific.algebricCoords;
            airdropsData[specific.coords].spawned = false;
            airdropsData[specific.coords].ticksToDespawn = getSandboxOptions():getOptionByName(
                "RandomAirdrops.AirdropRemovalTimer"):getValue();
            airdropsData[specific.coords].shouldRespawn = false;
            airdropsData[specific.coords].despawnOnNextLoad = false;
            airdropsData[specific.coords].despawnTries = 0;

            return specific.coords;
        else
            DebugPrintRandomAidrops("Cannot generate airdrop data from specific object, the airdrop data already exists");
            return nil;
        end
    else
        local availableCoords = getAvailableCoords();

        if #availableCoords == 0 then
            DebugPrintRandomAidrops("Cannot generate airdrop data, no available coords to use");
            return nil;
        end

        local selectedCoords = availableCoords[ZombRand(0, #availableCoords) + 1];
        local config = airdropConfigPositions[selectedCoords];

        if not config then
            DebugPrintRandomAidrops("Cannot generate airdrop data, configuration not exist for: " .. selectedCoords);
            return nil;
        end

        airdropsData[selectedCoords] = {};
        airdropsData[selectedCoords].name = config.name;
        airdropsData[selectedCoords].algebricCoords = config.algebricCoords;
        airdropsData[selectedCoords].spawned = false;
        airdropsData[selectedCoords].ticksToDespawn = getSandboxOptions():getOptionByName(
            "RandomAirdrops.AirdropRemovalTimer"):getValue();
        airdropsData[selectedCoords].shouldRespawn = false;
        airdropsData[selectedCoords].despawnOnNextLoad = false;
        airdropsData[selectedCoords].despawnTries = 0;

        return selectedCoords;
    end
end

-- Actually spawn the aidrop by position
local function spawnAirdrop(coordsStr, position)
    local square = getCell():getGridSquare(position.x, position.y, position.z);

    if square then
        local nearestVehicle = square:getVehicleContainer();
        if nearestVehicle then
            DebugPrintRandomAidrops("Cannot spawn airdrop: " ..
                coordsStr .. " something is blocking the airdrop to spawn");
            return;
        end

        local airdrop = addVehicleDebug("Base.airdrop", IsoDirections.N, nil, square);
        if airdrop then
            airdrop:repair();
            spawnAirdropItems(airdrop);
            airdropsData[coordsStr].spawned = true;

            DebugPrintRandomAidrops("Aidrop physically spawned in: " ..
                coordsStr);
        else
            DebugPrintRandomAidrops("Cannot spawn airdrop: " ..
                coordsStr .. " the airdrop did not spawn for some unkown reason");
        end
    else
        DebugPrintRandomAidrops("Cannot spawn airdrop: " ..
            coordsStr .. " chunk not loaded");
    end
end

-- Actually despawn the aidrop by position
local function despawnAirdrop(coordsStr, position)
    local square = getCell():getGridSquare(position.x, position.y, position.z);

    if square then
        local airdrop = square:getVehicleContainer();
        if airdrop then
            if airdrop:getScriptName() == "Base.airdrop" then
                airdrop:permanentlyRemove();
                airdropsData[coordsStr] = nil;

                DebugPrintRandomAidrops("Airdrop (spawned) despawned: " ..
                    coordsStr);
            else
                airdropsData[coordsStr].despawnTries = airdropsData[coordsStr].despawnTries + 1;
                DebugPrintRandomAidrops("Airdrop (spawned) cannot despawn: " ..
                    coordsStr .. " is not any airdrop in the position: " .. airdrop:getScriptName());
            end
        else
            airdropsData[coordsStr].despawnTries = airdropsData[coordsStr].despawnTries + 1;
            DebugPrintRandomAidrops("Airdrop (spawned) cannot despawn: " ..
                coordsStr .. " no airdrop found");
        end
    else
        airdropsData[coordsStr].despawnTries = airdropsData[coordsStr].despawnTries + 1;
        DebugPrintRandomAidrops("Airdrop (spawned) cannot despawn: " ..
            coordsStr .. " chunk not loaded");
    end

    if airdropsData[coordsStr].despawnTries >= 5 then
        airdropsData[coordsStr] = nil;

        DebugPrintRandomAidrops("Airdrop (spawned) cannot despawn: " ..
            coordsStr .. " giving up permanently after 5 tries");
    end
end

-- Try to spawn all airdrops that needs to be spawned
local spawnTickrate = 0;
local function trySpawnAirdrop()
    if spawnTickrate < getSandboxOptions():getOptionByName("RandomAirdrops.AirdropTickCheck"):getValue() then
        spawnTickrate = spawnTickrate + 1;
        return;
    end
    spawnTickrate = 0

    for coords, airdrop in pairs(airdropsData) do
        if not airdrop.spawned or airdrop.shouldRespawn then
            local position = getCoordsObjectFromStr(coords);
            if checkPlayersAround(position.x, position.y, position.z) then
                if not airdrop.spawned then
                    spawnAirdrop(coords, position);
                elseif airdrop.shouldRespawn then
                    despawnAirdrop(coords, position);
                    if not airdropsData[coords] then
                        local specificObject = {};
                        specificObject.coords = coords;
                        specificObject.name = airdrop.name;
                        specificObject.algebricCoords = airdrop.algebricCoords;
                        local receivedCoords = generateAirdropData(specificObject);
                        if receivedCoords then
                            spawnAirdrop(receivedCoords, position);
                        end
                    else
                        DebugPrintRandomAidrops("Cannot respawn the airdrop, the previously airdrop was not despawned: " ..
                            coords);
                    end
                end
            else
                DebugPrintRandomAidrops("Airdrop cannot be spawned in: " ..
                    coords .. " chunk is not loaded");
            end
        end
    end
end

-- Try to despawn all airdrops spawned that need to be despawned
local despawnTickrate = 0;
local function tryDespawnAirdrops()
    if despawnTickrate < getSandboxOptions():getOptionByName("RandomAirdrops.AirdropTickCheck"):getValue() then
        despawnTickrate = despawnTickrate + 1;
        return;
    end
    despawnTickrate = 0

    for coords, airdrop in pairs(airdropsData) do
        -- Check if we need to despawn
        if airdrop.ticksToDespawn <= 0 then
            -- If not spawned we just delete from memory
            if not airdrop.spawned then
                airdropsData[coords] = nil;
                DebugPrintRandomAidrops("Airdrop (not spawned) removed in: " .. coords);
            else
                local position = getCoordsObjectFromStr(coords);
                local isPlayerAround = checkPlayersAround(position.x, position.y, position.z);

                if isPlayerAround and airdrop.despawnOnNextLoad then         -- Player is loading the chunk and despawnOnNextLoad is true, remove the airdrop from existance
                    despawnAirdrop(coords, position);
                elseif isPlayerAround and not airdrop.despawnOnNextLoad then -- Player is actually seeing the airdrop, do nothing
                    DebugPrintRandomAidrops("Airdrop (spawned) cannot be removed in: " ..
                        coords .. " a player is seeing it");
                elseif not isPlayerAround then -- No chunks loaded cannot despawn
                    airdropsData[coords].despawnOnNextLoad = true;
                    DebugPrintRandomAidrops("Airdrop (spawned) cannot be removed in: " ..
                        coords .. " chunk is not loaded");
                end
            end
        end
    end
end

-- Roll a chance to spawn any random airdrop
local function rollChanceToSpawnAirdrop()
    local chance = ZombRand(0, 1000);
    DebugPrintRandomAidrops("Rolling chance to spawn airdrop: " ..
        getSandboxOptions():getOptionByName("RandomAirdrops.AirdropFrequency"):getValue() .. " >= " .. chance);
    if getSandboxOptions():getOptionByName("RandomAirdrops.AirdropFrequency"):getValue() >= chance then
        local coords = generateAirdropData();
        if coords then
            DebugPrintRandomAidrops("Airdrop Spawned on " .. coords);

            if RandomAidropsIsSinglePlayer then
                local player = getPlayer();

                local alarmSound = "airdrop" .. tostring(ZombRand(1));
                local sound = getSoundManager():PlaySound(alarmSound, false, 0);
                getSoundManager():PlayAsMusic(alarmSound, sound, false, 0);
                sound:setVolume(0.1);

                player:Say(getText("IGUI_Airdrop_Incoming", airdropsData[coords].algebricCoords,
                    getText("IGUI_Airdrop_" .. airdropsData[coords].name)));
            else
                local players = getOnlinePlayers();
                for i = 0, players:size() - 1 do
                    local player = players:get(i)
                    sendServerCommand(player, "RandomAirdrops", "newAirdrop",
                        { name = airdropsData[coords].name, algebricCoords = airdropsData[coords].algebricCoords });
                end
            end
        end
    end
end

--#endregion

--#region API

-- Spawn a airdrop on a specific position, returns the coords as string, nil if cannot spawn
-- position = { x = 10, y = 10, z = 0 }
-- name = "Something"
-- algebricCoords = "A1"
function SpawnSpecificAirdrop(position, name, algebricCoords)
    local specific = {};
    specific.coords = tostring(math.floor(position.x)) ..
        "," .. tostring(math.floor(position.y)) .. "," .. tostring(math.floor(position.z));
    specific.name = name or "Unkown";
    specific.algebricCoords = algebricCoords or "Unkown";

    return generateAirdropData(specific);
end

--#endregion

Events.OnInitGlobalModData.Add(function(isNewGame)
    airdropsData = ModData.getOrCreate("RandomAirdropsData");
end)
Events.EveryHours.Add(rollChanceToSpawnAirdrop);
Events.OnTick.Add(trySpawnAirdrop);
Events.OnTick.Add(tryDespawnAirdrops);
