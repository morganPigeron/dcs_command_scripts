local NBUNITSCREATED = 100;
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

local function testSpawn(pos)
    local newUnit = createLAV25()
    newUnit = setUnitPosition(newUnit, pos.x, pos.y)
    newUnit = setUnitName(newUnit, "test")
    coalition.addGroup(country.id.USA, Group.Category.GROUND, newUnit)
end
missionCommands.addCommand("test spawn", nil, testSpawn, { x = 0, y = 0 })

local e = {}
function e:onEvent(event)
    local m = {}
    m[#m + 1] = "Event ID: "
    m[#m + 1] = event.id
    if event.initiator then
        m[#m + 1] = "\nInitiator : "
        m[#m + 1] = event.initiator:getPlayerName()
    end
    if event.weapon then
        m[#m + 1] = "\nWeapon : "
        m[#m + 1] = event.weapon:getTypeName()
    end
    if event.target then
        m[#m + 1] = "\nTarget : "
        m[#m + 1] = event.target:getName()
    end


    --comment change on map
    if event.id == 26 then
        if event.text then
            m[#m + 1] = "\nText : "
            m[#m + 1] = event.text
        end

        if event.pos then
            m[#m + 1] = "\nPos : "
            m[#m + 1] = event.pos.x .. " " .. event.pos.z

            testSpawn({ x = event.pos.x, y = event.pos.z })
        end
    end
    trigger.action.outText(table.concat(m), 60)
end

world.addEventHandler(e)
