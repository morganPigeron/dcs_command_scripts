-- ***********************************
-- GLOBAL
-- ***********************************
local LOCK = true
local DEBUG = false
local MissionScript = {}

MissionScript.GROUND_UNIT = {}

-- Global counter to track number of unit spawned by this script
MissionScript.NB_UNITS_CREATED = 0

-- hold a table with all marker, text in position.
-- goal is to reuse a certain marker to access its position.
-- Ex navigate to marker "point B"
MissionScript.MARKER_TABLE = {}

local function logger(log)
    if type(log) == "string" then
        log = {log} -- Wrap the string in a table
    end
    if #log > 0 then
        trigger.action.outText(table.concat(log), 60)
    end
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- ***********************************
-- Templates
-- ***********************************

MissionScript.TEMPLATE = {}
-- https://wiki.hoggitworld.com/view/DCS_func_addGroup
MissionScript.TEMPLATE["GroupGround"] = {
    name = "Ground Group",
    task = "Ground Nothing",
    groupId = nil,
    start_time = nil,
    lateActivation = nil,
    hidden = nil,
    hiddenOnPlanner = nil,
    hiddenOnMFD = nil,
    route = nil,
    visible = nil,
    uncontrollable = nil,
}

MissionScript.TEMPLATE["GroupAir"] = {
    name = "Air Group",
    task = "Air Nothing",
    groupId = nil,
    start_time = nil,
    lateActivation = nil,
    hidden = nil,
    hiddenOnPlanner = nil,
    hiddenOnMFD = nil,
    route = nil,
    uncontrolled = nil,
    modulation = nil,
    frequency = nil,
    communication = nil,
}

MissionScript.TEMPLATE["UnitAir"] = {
    name = "unit air", --required
    type = "unit air", --required
    x = 0, --required
    y = 0, --required
    alt = nil, --required
    alt_type = nil, --required 
    speed = nil, --required
    payload = nil, --required
    callsign = nil, --required
    unitId = nil,
    heading = nil,
    skill = nil,
    livery_id = nil, --required
    psi = nil, --required
    onboard_num = nil, --required
    ropeLength = nil, --required
}

MissionScript.TEMPLATE["UnitGround"] = {
    name = "unit ground", --required
    type = "unit ground", --required
    x = 0, --required
    y = 0, --required
    unitId = nil,
    heading = nil,
    skill = nil,
    coldAtStart = nil,
    playerCanDrive = nil,
}

-- ***********************************
-- Templates END
-- ***********************************

-- ***********************************
-- GLOBAL END
-- ***********************************

-- ***********************************
-- MissionScript related methods
-- ***********************************

function MissionScript.setUnitPosition(unit, x, y)
    unit.units[1].x = x
    unit.units[1].y = y
    unit.x = x
    unit.y = y
    return unit
end

-- get unit struct and name string. 
-- use Global counter to suffix name by increment to avoid same name
-- units in unit struct are also incremented to avoid same name
function MissionScript.setUnitName(unit, name)
    for i, u in ipairs(unit.units) do
    u.unitId = MissionScript.NB_UNITS_CREATED
    u.name = name .. "-" .. i .. "-" .. MissionScript.NB_UNITS_CREATED
    unit.name = "group-" .. name .. "-" .. i .. "-" .. MissionScript.NB_UNITS_CREATED
    MissionScript.NB_UNITS_CREATED = MissionScript.NB_UNITS_CREATED + 1
    end
    return unit
end

-- will search text in string, ignoring Case
function MissionScript.containsTextIgnoreCase(text, searchText)
    local lowercaseText = string.lower(text)
    local lowercaseSearchText = string.lower(searchText)
    return string.find(lowercaseText, lowercaseSearchText, 1, true) ~= nil
end

function MissionScript.printTable(title, rows)
    local m = {}
    m[#m + 1] = "\n" .. title .. ": \n"
    for _, row in ipairs(rows) do
        m[#m + 1] = row .. "\n"
    end
    trigger.action.outText(table.concat(m), 60)
end

function MissionScript.getCountryIdFromCoalition(event)
    local unitCountry
    if event.coalition == coalition.side.RED then
        unitCountry = country.id.RUSSIA
    elseif event.coalition == coalition.side.BLUE then
        unitCountry = country.id.USA
    else
        unitCountry = country.id.RUSSIA
    end
    return unitCountry
end

-- ***********************************
-- MissionScript related methods END
-- ***********************************

-- *********************************** 
-- TEMPLATE related methods
-- ***********************************

function MissionScript.TEMPLATE:GenerateUnitOrGroup(templateName, parameters)
    local template = self[templateName]

    local newUnitOrGroup = {}
    for key, value in pairs(template) do
        -- Check if the parameter is provided, otherwise, use the template value
        newUnitOrGroup[key] = parameters[key] or value
    end
    return newUnitOrGroup
end

function MissionScript.TEMPLATE:newGround(parameters)
    return self:GenerateUnitOrGroup("GroupGround", parameters)
end

function MissionScript.TEMPLATE:newUnit(parameters)
    return self:GenerateUnitOrGroup("UnitGround", parameters)
end

-- *********************************** 
-- TEMPLATE related methods END
-- ***********************************

-- *********************************** 
-- MARKER_TABLE related methods
-- ***********************************

-- add marker to table
-- looks like there is no way to get remove event
-- so I will remove old one if text is equivalent
function MissionScript.MARKER_TABLE:addMarker(marker_event)
    self[marker_event.idx] = {text = marker_event.text, pos = marker_event.pos}
end

-- modify existing marker
function MissionScript.MARKER_TABLE:modifyMarker(marker_event)
    self[marker_event.idx] = {text = marker_event.text, pos = marker_event.pos}
end

-- find marker by text
-- will find the one with higest id wich is the last one with this text
function MissionScript.MARKER_TABLE:findMarkerByText(searchText)
    local highestId = -1
    local highestIdData = nil

    for id, markerData in pairs(self) do
        -- TODO search text but without special characters
        if type(markerData) == "table" then
            if markerData.text == searchText and id > highestId then
                highestId = id
                highestIdData = markerData
            end
        end
    end

    return highestIdData
end

-- print marker
function MissionScript.MARKER_TABLE:print()
    local log = {}
    for id, markerData in pairs(self) do
        -- in lua function are also in pairs self ...
        if type(markerData) == "table" then
            log[#log+1] = "\nMarker id: " .. id .. " " .. markerData.text
        end
    end
    logger(log)
end

-- *********************************** 
-- MARKER_TABLE related methods END
-- ***********************************

-- *********************************** 
-- GROUND_UNIT related methods
-- ***********************************

-- Function to add unitName-dcsName pairs to the table
function MissionScript.GROUND_UNIT:addUnitPair(unitName, dcsName)
    local name = string.upper(unitName)
    self[name] = dcsName
end

-- Function to get dcsName from unitName
function MissionScript.GROUND_UNIT:getDCSName(unitName)
    local name = string.upper(unitName)
    return self[name]
end

-- Function to check if unitName exist
function MissionScript.GROUND_UNIT:isUnitExist(unitName)
    local name = string.upper(unitName)
    return self[name] ~= nil
end

-- Function to create unit, must check if exist before!
function MissionScript.GROUND_UNIT:create(unitName)
    local dcsName = self:getDCSName(unitName)
    local group = MissionScript.TEMPLATE:newGround({})
    local unit = MissionScript.TEMPLATE:newUnit({type = dcsName})
    group.units = {}
    group.units[1] = unit
    return group
end

-- Function to spawn unit at x and y position with a certain country
function MissionScript.GROUND_UNIT:spawn(unitName, x, y, unitCountryId)
    if self:isUnitExist(unitName) then
        local newUnit = self:create(unitName)
        newUnit = MissionScript.setUnitPosition(newUnit, x, y)
        newUnit = MissionScript.setUnitName(newUnit, "unit")
        coalition.addGroup(unitCountryId, Group.Category.GROUND, newUnit)
    end
end

function MissionScript.GROUND_UNIT:getAllSpawnableUnits()
    local units = {}
    for unitName, value in pairs(self) do
        if type(value) ~= "function" then
            table.insert(units, " - " .. unitName .. " => " .. value)
        end
    end
    return units
end

-- *********************************** 
-- GROUND_UNIT related methods END
-- ***********************************

-- NEED invisible FARP to land
local function testSpawnFARP(event)

--    local farp =
--    {
--        ["frequency"] = 127.5,
--        ["modulation"] = 0,
--        ["groupId"] = 5,
--        ["tasks"] =
--        {
--        }, -- end of ["tasks"]
--        ["route"] =
--        {
--        }, -- end of ["route"]
--        ["hidden"] = false,
--        ["units"] =
--        {
--            [1] =
--            {
--                ["type"] = "FARP",
--                ["name"] = "testfarp",
--                ["callsign"] =
--                {
--                    [1] = 2,
--                    [2] = 1,
--                    ["name"] = "Springfield11",
--                    [3] = 1,
--                }, -- end of ["callsign"]
--                ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
--                ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
--            }, -- end of [1]
--        }, -- end of ["units"]
--        ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
--        ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
--        ["radioSet"] = false,
--        ["name"] = "Rotary-1",
--        ["communication"] = true,
--        ["start_time"] = 0,
--        ["task"] = "Transport",
--        ["uncontrolled"] = false,
--    } -- end of Rotary-1

    local group = MissionScript.TEMPLATE:newGround({
        y = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
        x = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
    })
    group["frequency"] = 127.5
    group["modulation"] = 0
    group["callsign"] = {name = "london"}
    local unit = MissionScript.TEMPLATE:newUnit({
        type = "FARP",
        y = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
        x = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
        callsign = 1
    })
    group.units = {}
    group.units[1] = unit

    coalition.addGroup(MissionScript.getCountryIdFromCoalition(event), -1, group)
end

local function SpawnMI8(event)
    local startPos, endPos = event.text:find("heli", 1, true)
    local waypointList = {}  -- Initialize an empty table to store the words
    local waypointTemplate =
    {
        ["alt"] = 200,
        ["type"] = "Turning Point",
        ["action"] = "Turning Point",
        ["alt_type"] = "BARO",
        ["form"] = "Turning Point",
        ["y"] = nil,
        ["x"] = nil,
        ["speed"] = 41.666666666667,
        ["task"] =
        {
            ["id"] = "ComboTask",
            ["params"] =
            {
                ["tasks"] =
                {
                }, -- end of ["tasks"]
            }, -- end of ["params"]
        }, -- end of ["task"]
    } -- end of [2]

    local heli =
    {
        ["frequency"] = 127.5,
        ["modulation"] = 0,
        ["groupId"] = 5,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["route"] =
        {
            ["points"] =
            {
                [1] =
                {
                    ["alt"] = 0,
                    ["type"] = "TakeOffGround",
                    ["action"] = "From Ground Area",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = event.pos.z,
                    ["x"] = event.pos.x,
                    ["speed"] = 41.666666666667,
                    ["task"] =
                    {
                        ["id"] = "ComboTask",
                        ["params"] =
                        {
                            ["tasks"] =
                            {
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                }, -- end of [1]
            }, -- end of ["points"]
        }, -- end of ["route"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["alt"] = 0,
                ["hardpoint_racks"] = false,
                ["alt_type"] = "BARO",
                ["livery_id"] = "Mi-17 CIA Afghanistan",
                ["skill"] = "High",
                ["ropeLength"] = 15,
                ["speed"] = 0,
                ["AddPropAircraft"] =
                {
                    ["ExhaustScreen"] = false,
                    ["CargoHalfdoor"] = true,
                    ["GunnersAISkill"] = 90,
                    ["AdditionalArmor"] = false,
                    ["NS430allow"] = true,
                }, -- end of ["AddPropAircraft"]
                ["type"] = "Mi-8MT",
                ["unitId"] = 13,
                ["psi"] = 2.6422217449925,
                ["name"] = "Rotary-1-1",
                ["payload"] =
                {
                    ["pylons"] =
                    {
                    }, -- end of ["pylons"]
                    ["fuel"] = "1929",
                    ["flare"] = 128,
                    ["chaff"] = 0,
                    ["gun"] = 100,
                }, -- end of ["payload"]
                ["onboard_num"] = "050",
                ["callsign"] =
                {
                    [1] = 2,
                    [2] = 1,
                    ["name"] = "Springfield11",
                    [3] = 1,
                }, -- end of ["callsign"]
                ["heading"] = -2.6422217449925,
                ["y"] = event.pos.z,
                ["x"] = event.pos.x,
            }, -- end of [1]
        }, -- end of ["units"]
        ["y"] = event.pos.z,
        ["x"] = event.pos.x,
        ["radioSet"] = false,
        ["name"] = "Rotary-1",
        ["communication"] = true,
        ["start_time"] = 0,
        ["task"] = "Transport",
        ["uncontrolled"] = false,
    } -- end of Rotary-1

    if startPos then
        local remainingText = event.text:sub(endPos + 1)  -- Get the text after "heli"
        -- Iterate and match words, and store them in the table
        for word in remainingText:gmatch("%w+") do
            table.insert(waypointList, word)
        end
    end


    for _, waypoint in pairs(waypointList) do
        local waypointMarker = MissionScript.MARKER_TABLE:findMarkerByText(waypoint)
        if waypointMarker then
            -- create a deepcopy of template 
            local newPoint = deepcopy(waypointTemplate)
            newPoint.x = waypointMarker.pos.x
            newPoint.y = waypointMarker.pos.z
            table.insert(heli.route.points, newPoint)
        end
    end

    if #heli.route.points < 2 then
        logger("Error waypoint not found\nMarker 1 text: waypoint\nMarker 2 text: heli waypoint")
        return;
    end

    MissionScript.setUnitName(heli, "heli")
    -- TODO what happen with farp in dcs ?? testSpawnFARP(event)
    coalition.addGroup(MissionScript.getCountryIdFromCoalition(event), Group.Category.HELICOPTER, heli)
end

-- *********************************** 
-- Command handling related methods 
-- ***********************************

-- Function to log the data recursively
local function logClassData(class, indent, log)
    indent = indent or 0
    local prefix = string.rep("  ", indent) -- Adjust the spacing as needed

    for key, value in pairs(class) do
        if type(value) == "table" then
            -- If the value is a table, log it and call the function recursively
            log[#log+1] = "\n" .. prefix .. key .. " (Table):"
            logClassData(value, indent + 1, log)
        else
            -- If the value is not a table, log it directly
            log[#log+1] = "\n" .. prefix .. key .. " (Value): " .. tostring(value)
        end
    end
end

-- debug method to print event as a table in logger
local function printTable(event, log)
    for key, value in pairs(event) do
        log[#log+1] = "\n" .. key .. " : " .. tostring(value)
    end
end

local function handleSpawnCommand(event)
    MissionScript.GROUND_UNIT:spawn(event.text, event.pos.x, event.pos.z, MissionScript.getCountryIdFromCoalition(event))
end

local function handleScriptCommand(event)

    -- TODO find a better way to lock command 
    if MissionScript.containsTextIgnoreCase(event.text, "master") then
        LOCK = false
    end

    if LOCK then
        return
    end
    -- lock command end

    if MissionScript.containsTextIgnoreCase(event.text, "DEBUG ON") then
        DEBUG = true

    elseif MissionScript.containsTextIgnoreCase(event.text, "DEBUG OFF") then
        DEBUG = false

    elseif MissionScript.containsTextIgnoreCase(event.text, "DEBUG") then
        DEBUG = not DEBUG

    elseif MissionScript.containsTextIgnoreCase(event.text, "list") or MissionScript.containsTextIgnoreCase(event.text, "liste") then
        MissionScript.printTable("Liste", MissionScript.GROUND_UNIT:getAllSpawnableUnits())

    elseif MissionScript.containsTextIgnoreCase(event.text, "heli") then
        SpawnMI8(event)

    elseif MissionScript.containsTextIgnoreCase(event.text, "marker") then
        MissionScript.MARKER_TABLE:print()

    end
end

local function handleMarkChange(event)
    MissionScript.MARKER_TABLE:modifyMarker(event)
    handleSpawnCommand(event)
    handleScriptCommand(event)
end

local function handleMarkAdd(event)
    MissionScript.MARKER_TABLE:addMarker(event)
end


local function handleDebug(event)
    local log = {}
    log[#log+1] = "\n*** event id => " .. event.id .. " ***"

    if event.id == world.event.S_EVENT_MARK_CHANGE then
        log[#log+1] = "\n--- Event mark change --- "
        printTable(event, log)
    end

    if event.id == world.event.S_EVENT_MARK_ADDED then
        log[#log+1] = "\n--- Event mark added --- "
        printTable(event, log)
    end

    if event.id == world.event.S_EVENT_MARK_REMOVE then
        log[#log+1] = "\n--- Event mark remove --- "
        printTable(event, log)
    end

    local blueStatics = coalition.getAirbases(coalition.side.BLUE)
    log[#log+1] = "\n--- Blue groups --- "
    --logClassData(blueStatics, 0, log)
    logClassData(Airbase.getDesc(blueStatics[1]), 0, log)
    logger(log)
end

-- *********************************** 
-- Command handling related methods END 
-- ***********************************

-- *********************************** 
-- Entry point
-- Script start here
-- ***********************************

MissionScript.GROUND_UNIT:addUnitPair("LAV25", "LAV-25")
MissionScript.GROUND_UNIT:addUnitPair("MORTIER", "2B11 mortar")
MissionScript.GROUND_UNIT:addUnitPair("IGLA", "SA-18 Igla manpad")
MissionScript.GROUND_UNIT:addUnitPair("BTR", "BTR-80")
MissionScript.GROUND_UNIT:addUnitPair("TUNGUSKA", "2S6 Tunguska")
MissionScript.GROUND_UNIT:addUnitPair("SHILKA", "ZSU-23-4 Shilka")

local eventHandler = {}
function eventHandler:onEvent(event)

    if event.id == world.event.S_EVENT_MARK_CHANGE then
        handleMarkChange(event)
    end

    if event.id == world.event.S_EVENT_MARK_ADDED then
        handleMarkAdd(event)
    end

    if DEBUG then
        handleDebug(event)
    end
end

world.addEventHandler(eventHandler)

return MissionScript
