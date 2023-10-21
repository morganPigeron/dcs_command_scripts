-- ***********************************
-- GLOBAL
-- ***********************************

local MissionScript = {}
MissionScript.GROUND_UNIT = {}
MissionScript.NB_UNITS_CREATED = 100
local DEBUG = false

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

local function handleSpawnCommand(event)
    MissionScript.GROUND_UNIT:spawn(event.text, event.pos.x, event.pos.z, MissionScript.getCountryIdFromCoalition(event))
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
                    ["alt"] = 10,
                    ["type"] = "TakeOffParking",
                    ["action"] = "From Parking Area",
                    ["alt_type"] = "BARO",
                    ["form"] = "From Parking Area",
                    ["y"] = 622076.61801342,
                    ["x"] = -267973.77528983,
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
                    ["helipadId"] = 12,
                }, -- end of [1]
                [2] =
                {
                    ["alt"] = 2000,
                    ["type"] = "Turning Point",
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = 615899.60909444,
                    ["x"] = -279297.64010796,
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
                    ["alt"] = 2000,
                    ["type"] = "Turning Point",
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = 629730.91889102,
                    ["x"] = -278300.78895145,
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
                }, -- end of [3]
                [4] =
                {
                    ["alt"] = 13,
                    ["type"] = "Land",
                    ["action"] = "Landing",
                    ["alt_type"] = "BARO",
                    ["form"] = "Landing",
                    ["y"] = 647279.46875,
                    ["x"] = -281782.46875,
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
                    ["airdromeId"] = 23,
                }, -- end of [4]
            }, -- end of ["points"]
        }, -- end of ["route"]
        ["hidden"] = false,
        ["units"] =
        {
            [1] =
            {
                ["alt"] = 10,
                ["hardpoint_racks"] = true,
                ["alt_type"] = "BARO",
                ["livery_id"] = "Mi-17 CIA Afghanistan",
                ["skill"] = "High",
                ["parking"] = "1",
                ["ropeLength"] = 15,
                ["speed"] = 41.666666666667,
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
                ["parking_id"] = "1",
                ["x"] = -267973.77528983,
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
                ["y"] = 622076.61801342,
            }, -- end of [1]
            [2] =
            {
                ["alt"] = 10,
                ["hardpoint_racks"] = true,
                ["alt_type"] = "BARO",
                ["livery_id"] = "USA_AFG",
                ["skill"] = "High",
                ["ropeLength"] = 15,
                ["speed"] = 41.666666666667,
                ["AddPropAircraft"] =
                {
                    ["ExhaustScreen"] = true,
                    ["CargoHalfdoor"] = true,
                    ["GunnersAISkill"] = 90,
                    ["AdditionalArmor"] = true,
                    ["NS430allow"] = true,
                }, -- end of ["AddPropAircraft"]
                ["type"] = "Mi-8MT",
                ["unitId"] = 14,
                ["psi"] = 2.6422217449925,
                ["y"] = 622116.61801342,
                ["x"] = -268013.77528983,
                ["name"] = "Rotary-1-2",
                ["payload"] =
                {
                    ["pylons"] =
                    {
                        [7] =
                        {
                            ["CLSID"] = "KORD_12_7",
                        }, -- end of [7]
                        [8] =
                        {
                            ["CLSID"] = "PKT_7_62",
                        }, -- end of [8]
                    }, -- end of ["pylons"]
                    ["fuel"] = "1929",
                    ["flare"] = 128,
                    ["chaff"] = 0,
                    ["gun"] = 100,
                }, -- end of ["payload"]
                ["onboard_num"] = "051",
                ["callsign"] =
                {
                    [1] = 2,
                    [2] = 1,
                    ["name"] = "Springfield12",
                    [3] = 2,
                }, -- end of ["callsign"]
                ["heading"] = -2.6422217449925,
            }, -- end of [2]
        }, -- end of ["units"]
        ["y"] = 622076.61801342,
        ["radioSet"] = false,
        ["name"] = "Rotary-1",
        ["communication"] = true,
        ["x"] = -267973.77528983,
        ["start_time"] = 0,
        ["task"] = "Transport",
        ["uncontrolled"] = false,
    } -- end of Rotary-1
    MissionScript.setUnitName(heli, "heli")
    coalition.addGroup(MissionScript.getCountryIdFromCoalition(event), Group.Category.HELICOPTER, heli)
end

-- *********************************** 
-- Command handling related methods 
-- ***********************************

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
        testSpawnHeli()
    end
end

local function handleMarkChange(event)
    handleSpawnCommand(event)
    handleScriptCommand(event)
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

return MissionScript
