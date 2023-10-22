-- ***********************************
-- GLOBAL
-- ***********************************

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

-- ***********************************
-- Templates
-- ***********************************

MissionScript.TEMPLATE = {}
-- https://wiki.hoggitworld.com/view/DCS_func_addGroup
MissionScript.TEMPLATE["GroupGround"] = {
    name = nil, -- required 
    task = nil, -- required 
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
    name = nil, -- required 
    task = nil, -- required 
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
    name = nil, --required
    type = nil, --required
    x = nil, --required
    y = nil, --required
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
    name = nil, --required
    type = nil, --required
    x = nil, --required
    y = nil, --required
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

    if template then
        local newUnitOrGroup = {}
        for key, value in pairs(template) do
            -- Check if the parameter is provided, otherwise, use the template value
            newUnitOrGroup[key] = parameters[key] or value
        end
        return newUnitOrGroup
    else
        return nil  -- Return nil or handle the error as needed
    end
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
        -- in lua function are also in pairs self ...
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
    return {
        ["visible"] = false,
        ["route"] =
        {
        }, -- end of ["route"]
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["units"] =
        {
            [1] =
            {
                ["type"] = dcsName,
                ["skill"] = "Average",
                ["y"] = 0,
                ["x"] = 0,
                ["name"] = "Ground Unit1",
                ["playerCanDrive"] = true,
            }, -- end of [1]
        },     -- end of ["units"]
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "Ground Group",
        ["task"] = "Ground Nothing",
    } -- end of [1]
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

    groundExam =
    {
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
                ["type"] = "M-109",
                ["transportable"] =
                {
                    ["randomTransportable"] = false,
                }, -- end of ["transportable"]
                ["unitId"] = 9,
                ["skill"] = "High",
                ["y"] = 654317.3511118,
                ["x"] = -292895.91688114,
                ["name"] = "Ground-1-4",
                ["playerCanDrive"] = true,
                ["heading"] = 0,
            }, -- end of [1]
        }, -- end of ["units"]
        ["y"] = 654317.3511118,
        ["uncontrollable"] = false,
        ["name"] = "Ground-1",
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
        ["x"] = -292895.91688114,
    } -- end of groundExam




    local farp =
    {
        ["frequency"] = 127.5,
        ["modulation"] = 0,
        ["groupId"] = 5,
        ["tasks"] =
        {
        }, -- end of ["tasks"]
        ["route"] =
        {
        }, -- end of ["route"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["type"] = "Static Invisible FARP-1",
                ["name"] = "testfarp",
                ["callsign"] =
                {
                    [1] = 2,
                    [2] = 1,
                    ["name"] = "Springfield11",
                    [3] = 1,
                }, -- end of ["callsign"]
                ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
                ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
            }, -- end of [1]
        }, -- end of ["units"]
        ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
        ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
        ["radioSet"] = false,
        ["name"] = "Rotary-1",
        ["communication"] = true,
        ["start_time"] = 0,
        ["task"] = "Transport",
        ["uncontrolled"] = false,
    } -- end of Rotary-1
    coalition.addGroup(MissionScript.getCountryIdFromCoalition(event), -1, farp)
end

local function testSpawnHeli(event)
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
                [2] =
                {
                    ["alt"] = 200,
                    ["type"] = "Turning Point",
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
                    ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
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
                }, -- end of [2]
                [3] =
                {
                    ["alt"] = 0,
                    ["type"] = "Land",
                    ["action"] = "FromGroundArea",
                    ["alt_type"] = "BARO",
                    ["form"] = "Landing",
                    ["y"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.z,
                    ["x"] = MissionScript.MARKER_TABLE:findMarkerByText("a").pos.x,
                    ["speed"] = 0,
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
                }, -- end of [3]
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
    MissionScript.setUnitName(heli, "heli")
    testSpawnFARP(event)
    coalition.addGroup(MissionScript.getCountryIdFromCoalition(event), Group.Category.HELICOPTER, heli)
end

-- *********************************** 
-- Command handling related methods 
-- ***********************************

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

    if MissionScript.containsTextIgnoreCase(event.text, "DEBUG ON") then
        DEBUG = true

    elseif MissionScript.containsTextIgnoreCase(event.text, "DEBUG OFF") then
        DEBUG = false

    elseif MissionScript.containsTextIgnoreCase(event.text, "DEBUG") then
        DEBUG = not DEBUG

    elseif MissionScript.containsTextIgnoreCase(event.text, "list") or MissionScript.containsTextIgnoreCase(event.text, "liste") then
        MissionScript.printTable("Liste", MissionScript.GROUND_UNIT:getAllSpawnableUnits())

    elseif MissionScript.containsTextIgnoreCase(event.text, "heli") then
        testSpawnHeli(event)

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

    local blueStatics = coalition.getStaticObjects(2)
    log[#log+1] = "\n--- Blue statics --- "
    printTable(blueStatics, log)

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
