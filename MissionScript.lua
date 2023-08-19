local NBUNITSCREATED = 100;
local DEBUG = false;
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
    unit.units[1].unitId = NBUNITSCREATED
    unit.units[1].name = name .. NBUNITSCREATED
    unit.name = "group-" .. name .. NBUNITSCREATED
    NBUNITSCREATED = NBUNITSCREATED + 1
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
    if containsTextIgnoreCase(event.text, "LAV25") then
        local newUnit = createLAV25()
        newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
        newUnit = setUnitName(newUnit, "unit")
        coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    elseif containsTextIgnoreCase(event.text, "MORTIER") then
        local newUnit = createMortar()
        newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
        newUnit = setUnitName(newUnit, "unit")
        coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    elseif containsTextIgnoreCase(event.text, "IGLA") then
        local newUnit = createIGLA()
        newUnit = setUnitPosition(newUnit, event.pos.x, event.pos.z)
        newUnit = setUnitName(newUnit, "unit")
        coalition.addGroup(unitCountry, Group.Category.GROUND, newUnit)
    end
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
