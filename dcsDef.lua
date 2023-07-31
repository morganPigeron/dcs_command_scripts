--- add message to simulator log with caption "INFO", "WARNING" or "ERROR". Message box is optional.
---@param message string
---@param showMessageBox boolean
---@meta
function env.info(message, showMessageBox) end

--- add message to simulator log with caption "INFO", "WARNING" or "ERROR". Message box is optional.
---@param message string
---@param showMessageBox boolean
---@meta
function env.warning(message, showMessageBox) end

--- add message to simulator log with caption "INFO", "WARNING" or "ERROR". Message box is optional.
---@param message string
---@param showMessageBox boolean
---@meta
function env.error(message, showMessageBox) end

--- enables/disables appearance of message box each time lua error occurs.
---@param on boolean
---@meta
function env.setErrorMessageBoxEnabled(on) end

--- returns model time in seconds.
---@return Time
---@meta
function timer.getTime() end

--- returns mission time in seconds.
---@return Time
---@meta
function timer.getAbsTime() end

--- returns mission start time
---@return Time
---@meta
function timer.getTime0() end

---@meta
Event = {
    id = enum
    world.event,
    time = Time,
    initiator = Unit,
    target = Unit,
    place = Unit,
    subPlace = enum
    world.BirthPlace,
    weapon = Weapon
}
