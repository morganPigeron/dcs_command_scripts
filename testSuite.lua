local lu = require('luaunit')

-- Create a dummy "world" table for testing
world = {
    addEventHandler = function(eventHandler)
    end
}
local mis = require('MissionScript')

-- LuaUnit test class
TestSetUnitPosition = {}

function TestSetUnitPosition:testPositionSetting()
    local unit = {
        units = {
            [1] = {
                x = 0,
                y = 0
            }
        },
        x = 0,
        y = 0
    }

    local newX = 100
    local newY = 200

    local result = mis.setUnitPosition(unit, newX, newY)

    lu.assertEquals(result.units[1].x, newX)
    lu.assertEquals(result.units[1].y, newY)
    lu.assertEquals(result.x, newX)
    lu.assertEquals(result.y, newY)
end

-- Run the tests
os.exit(lu.LuaUnit.run())
