-- show a alert box
-- env.info("test alert", true)

env.info("v1", true)

function EventHandler(event)
    env.info(event.toString(), false)
end

world.addEventHandler(EventHandler)
