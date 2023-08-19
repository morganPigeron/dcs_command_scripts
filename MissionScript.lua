-- GLOBAL
local NB_UNITS_CREATED = 100
local DEBUG = false
-- GLOBAL END

local GROUND_UNIT_LIST = {}
-- Function to add unitName-dcsName pairs to the table
function GROUND_UNIT_LIST:addUnitPair(unitName, dcsName)
    local name = string.upper(unitName)
    self[name] = dcsName
end

-- Function to get dcsName from unitName
function GROUND_UNIT_LIST:getDCSName(unitName)
    local name = string.upper(unitName)
    return self[name]
end

-- Function to check if unitName exist
function GROUND_UNIT_LIST:isUnitExist(unitName)
    local name = string.upper(unitName)
    return self[name] ~= nil
end

-- Function to create unit, must check if exist before! //TODO tell dont ask ... we want it to be spawn at the end
function GROUND_UNIT_LIST:create(unitName)
    local dcsName = self:getDCSName(unitName)
    return {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["route"] =
        {
        }, -- end of ["route"]
        ["groupId"] = 2,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["type"] = dcsName,
                ["transportable"] =
                {
                    ["randomTransportable"] = false,
                }, -- end of ["transportable"]
                ["unitId"] = 2,
                ["skill"] = "Average",
                ["y"] = 0,
                ["x"] = 0,
                ["name"] = "Ground Unit1",
                ["playerCanDrive"] = true,
                ["heading"] = 0,
            }, -- end of [1]
        },     -- end of ["units"]
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "Ground Group",
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
    } -- end of [1]
end

GROUND_UNIT_LIST:addUnitPair("LAV25", "LAV25")
GROUND_UNIT_LIST:addUnitPair("MORTIER", "2B11 mortar")
GROUND_UNIT_LIST:addUnitPair("IGLA", "SA-18 Igla manpad")

-- Returns: Unit (a table representing a unit)
local function createLAV25()
    return {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["route"] =
        {
        }, -- end of ["route"]
        ["groupId"] = 2,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["type"] = "LAV-25",
                ["transportable"] =
                {
                    ["randomTransportable"] = false,
                }, -- end of ["transportable"]
                ["unitId"] = 2,
                ["skill"] = "Average",
                ["y"] = 0,
                ["x"] = 0,
                ["name"] = "Ground Unit1",
                ["playerCanDrive"] = true,
                ["heading"] = 0,
            }, -- end of [1]
        },     -- end of ["units"]
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "Ground Group",
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
    } -- end of [1]
end

local function createMortar()
    return {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["route"] =
        {
        }, -- end of ["route"]
        ["groupId"] = 2,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["type"] = "2B11 mortar",
                ["transportable"] =
                {
                    ["randomTransportable"] = false,
                }, -- end of ["transportable"]
                ["unitId"] = 2,
                ["skill"] = "Average",
                ["y"] = 0,
                ["x"] = 0,
                ["name"] = "Ground Unit1",
                ["playerCanDrive"] = true,
                ["heading"] = 0,
            }, -- end of [1]
        },     -- end of ["units"]
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "Ground Group",
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
    } -- end of [1]
end

local function createIGLA()
    return {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["route"] =
        {
        }, -- end of ["route"]
        ["groupId"] = 2,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["type"] = "SA-18 Igla manpad",
                ["transportable"] =
                {
                    ["randomTransportable"] = false,
                }, -- end of ["transportable"]
                ["unitId"] = 2,
                ["skill"] = "Average",
                ["y"] = 0,
                ["x"] = 0,
                ["name"] = "Ground Unit1",
                ["playerCanDrive"] = true,
                ["heading"] = 0,
            }, -- end of [1]
        },     -- end of ["units"]
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "Ground Group",
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
    } -- end of [1]
end

local function setUnitPosition(unit, x, y)
    unit.units[1].x = x
    unit.units[1].y = y
    unit.x = x
    unit.y = y
    return unit
end

local function setUnitName(unit, name)
    unit.units[1].unitId = NB_UNITS_CREATED
    unit.units[1].name = name .. NB_UNITS_CREATED
    unit.name = "group-" .. name .. NB_UNITS_CREATED
    NB_UNITS_CREATED = NB_UNITS_CREATED + 1
    return unit
end

local function containsTextIgnoreCase(text, searchText)
    local lowercaseText = string.lower(text)
    local lowercaseSearchText = string.lower(searchText)
    return string.find(lowercaseText, lowercaseSearchText, 1, true) ~= nil
end

local function handleSpawnCommand(event)
    local unitCountry
    if event.coalition == coalition.side.RED then
        unitCountry = country.id.RUSSIA
    elseif event.coalition == coalition.side.BLUE then
        unitCountry = country.id.USA
    else
        unitCountry = country.id.RUSSIA
    end

    if GROUND_UNIT_LIST:isUnitExist(event.text) then
        local newUnit = GROUND_UNIT_LIST:create(event.text)
        newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
        newUnit = setUnitName(newUnit, "unit")
        coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    end

    -- if containsTextIgnoreCase(event.text, "LAV25") then
    --     local newUnit = createLAV25()
    --     newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
    --     newUnit = setUnitName(newUnit, "unit")
    --     coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    -- elseif containsTextIgnoreCase(event.text, "MORTIER") then
    --     local newUnit = createMortar()
    --     newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
    --     newUnit = setUnitName(newUnit, "unit")
    --     coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    -- elseif containsTextIgnoreCase(event.text, "IGLA") then
    --     local newUnit = createIGLA()
    --     newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
    --     newUnit = setUnitName(newUnit, "unit")
    --     coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    -- end
end

local function handleScriptCommand(event)
    if containsTextIgnoreCase(event.text, "DEBUG ON") then
        DEBUG = true
    elseif containsTextIgnoreCase(event.text, "DEBUG OFF") then
        DEBUG = false
    end
end

local function handleMarkChange(event)
    handleSpawnCommand(event)
    handleScriptCommand(event)
end

local eventHandler = {}
function eventHandler:onEvent(event)
    local m = {}
    -- m[#m + 1] = "Event ID: "
    -- m[#m + 1] = event.id
    if event.initiator then
        m[#m + 1] = "\nInitiator : "
        m[#m + 1] = event.initiator:getTypeName()
    end
    -- if event.weapon then
    --     m[#m + 1] = "\nWeapon : "
    --     m[#m + 1] = event.weapon:getTypeName()
    -- end
    -- if event.target then
    --    m[#m + 1] = "\nTarget : "
    --    m[#m + 1] = event.target:getName()
    -- end

    if event.id == world.event.S_EVENT_MARK_CHANGE then
        if event.text then
            m[#m + 1] = "\nText : "
            m[#m + 1] = event.text
        end

        if event.pos then
            m[#m + 1] = "\nPos : "
            m[#m + 1] = event.pos.x .. " " .. event.pos.z
        end

        handleMarkChange(event)
    end

    if DEBUG then
        trigger.action.outText(table.concat(m), 60)
    end
end

world.addEventHandler(eventHandler)
