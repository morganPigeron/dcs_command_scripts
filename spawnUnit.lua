local log = env.info;
local NBUNITSCREATED = 100;
-- Returns: Unit (a table representing a unit)
local function createUnit()
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


local function testSpawn(gs)
    local newUnit = createUnit()
    newUnit = setUnitPosition(newUnit, -288585.71428572, 616314.28571429)
    newUnit = setUnitName(newUnit, "test")
    coalition.addGroup(country.id.USA, Group.Category.GROUND, newUnit)
end
missionCommands.addCommand("test spawn", nil, testSpawn, nil)
