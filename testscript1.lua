-- show a alert box
-- env.info("test alert", true)

-- env.info("v1", true)

-- function EventHandler(event)
--     env.info(event.toString(), false)
-- end

-- world.addEventHandler(EventHandler)


env.setErrorMessageBoxEnabled(false)

local gameState = {}

local function setup()
    gameState.startTime = env.mission.start_time
    gameState.theatre = env.mission.theatre
    gameState.version = env.mission.version
end

local function printState()
    env.info(
        "startTime: " .. gameState.startTime ..
        "\ntheatre: " .. gameState.theatre ..
        "\nversion: " .. gameState.version
        , true)
end

setup()
-- printState()

-- add menu
-- local function CommandFunction(gs)
--     env.info(gs.startTime, true)
-- end
-- missionCommands.addCommand("test command", nil, CommandFunction, gameState)

env.info("start my script", false)

local groupData = {
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
            ["y"] = 616314.28571429,
            ["x"] = -288585.71428572,
            ["name"] = "Ground Unit1",
            ["playerCanDrive"] = true,
            ["heading"] = 0.28605144170571,
        }, -- end of [1]
    },     -- end of ["units"]
    ["y"] = 616314.28571429,
    ["x"] = -288585.71428572,
    ["name"] = "Ground Group",
    ["start_time"] = 0,
    ["task"] = "Ground Nothing",
} -- end of [1]

function EventHandler(event)
    env.info("event :" .. event.id, false)
end

world.addEventHandler(EventHandler)

local function CommandFunction(gs)
    coalition.addGroup(country.id.USA, Group.Category.GROUND, groupData)
end
missionCommands.addCommand("test command", nil, CommandFunction, gameState)
