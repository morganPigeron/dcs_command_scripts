local lu = require('luaunit')

-- Create a dummy "world" table for testing
world = {
    addEventHandler = function(eventHandler)
    end
}
coalition = {
}
Group = {
    Category = {
        Ground = "Ground"
    }
}

local mis = require('MissionScript')

TestGenericFunctions = {}

function TestGenericFunctions:testPositionSetting()
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

function TestGenericFunctions:testNameSetting()
    local unit = {
        units = {
            [1] = {
                unitId = 0,
                name = ""
            }
        },
        name = ""
    }

    local testName = "TestUnit"

    local result = mis.setUnitName(unit, testName)

    lu.assertEquals(result.units[1].unitId, 100)
    lu.assertEquals(result.units[1].name, testName .. 100)
    lu.assertEquals(result.name, "group-" .. testName .. 100)
    lu.assertEquals(mis.NB_UNITS_CREATED, 101) -- NB_UNITS_CREATED should be incremented
end

function TestGenericFunctions:testTextContainment()
    local text = "Hello, World!"
    local searchText = "world"

    -- Test that searchText is contained in text, ignoring case
    local result = mis.containsTextIgnoreCase(text, searchText)
    lu.assertTrue(result)

    -- Test with different cases
    local searchText2 = "HeLLo"
    local searchText3 = "WORLD!"

    local result2 = mis.containsTextIgnoreCase(text, searchText2)
    local result3 = mis.containsTextIgnoreCase(text, searchText3)

    lu.assertTrue(result2)
    lu.assertTrue(result3)
end

function TestGenericFunctions:testTextNonContainment()
    local text = "Hello, World!"
    local searchText = "foo"

    -- Test that searchText is not contained in text, ignoring case
    local result = mis.containsTextIgnoreCase(text, searchText)
    lu.assertFalse(result)
end

TestGroundUnitTable = {}

function TestGroundUnitTable:setUp()
    -- Create a new GROUND_UNIT table for each test
    self.groundUnit = {}

    -- Load the functions from MissionScript.GROUND_UNIT
    self.groundUnit.addUnitPair = mis.GROUND_UNIT.addUnitPair
    self.groundUnit.getDCSName = mis.GROUND_UNIT.getDCSName
    self.groundUnit.isUnitExist = mis.GROUND_UNIT.isUnitExist
    self.groundUnit.create = mis.GROUND_UNIT.create
    self.groundUnit.getAllSpawnableUnits = mis.GROUND_UNIT.getAllSpawnableUnits
    self.groundUnit.spawn = mis.GROUND_UNIT.spawn

    -- Initialize the GROUND_UNIT with sample data
    self.groundUnit:addUnitPair("LAV25", "LAV-25")
    self.groundUnit:addUnitPair("BTR", "BTR-80")
    -- Add more sample data as needed
end

function TestGroundUnitTable:testAddUnitPair()
    local unitName = "TestUnit"
    local dcsName = "Test-DCS-Name"

    self.groundUnit:addUnitPair(unitName, dcsName)
    lu.assertEquals(self.groundUnit:getDCSName(unitName), dcsName)
end

function TestGroundUnitTable:testGetDCSName()
    local unitName = "LAV25"
    local expectedDCSName = "LAV-25"

    local resultDCSName = self.groundUnit:getDCSName(unitName)
    lu.assertEquals(resultDCSName, expectedDCSName)
end

function TestGroundUnitTable:testIsUnitExist()
    local existingUnitName = "LAV25"
    local nonExistingUnitName = "NonExistentUnit"

    lu.assertTrue(self.groundUnit:isUnitExist(existingUnitName))
    lu.assertFalse(self.groundUnit:isUnitExist(nonExistingUnitName))
end

function TestGroundUnitTable:testCreate()
    local unitName = "LAV25"
    local expectedDCSName = "LAV-25"

    local result = self.groundUnit:create(unitName)

    lu.assertEquals(result.units[1].type, expectedDCSName)
    lu.assertFalse(result.visible)
    lu.assertTrue(result.taskSelected)
    lu.assertEquals(result.groupId, 2)
    -- Add more assertions for other properties
end

function TestGroundUnitTable:testSpawn()
    -- Mock setUnitPosition and setUnitName
    mis.setUnitPosition = function(unit, x, y)
        unit.x = x
        unit.y = y
        return unit
    end
    mis.setUnitName = function(unit, name)
        unit.name = name
        return unit
    end

    local unitName = "LAV25"
    local x = 100
    local y = 200
    local unitCountryId = 1

    local addGroupCalled = false
    -- Mock only the part of coalition.addGroup related to adding a group
    coalition.addGroup = function(countryId, category, groupData)
        addGroupCalled = true
    end

    -- Test the spawn function when unit exists
    self.groundUnit:spawn(unitName, x, y, unitCountryId)
    lu.assertTrue(addGroupCalled)

    -- Test the spawn function when unit does not exist
    addGroupCalled = false
    self.groundUnit:spawn("NonExistentUnit", x, y, unitCountryId)
    lu.assertFalse(addGroupCalled)
end

function TestGroundUnitTable:testGetAllSpawnableUnits()
    local units = self.groundUnit:getAllSpawnableUnits()

    lu.assertEquals(#units, 2) -- Number of units added in setUp
    -- Add more assertions for the content of units
end

-- Run the tests
os.exit(lu.LuaUnit.run())
