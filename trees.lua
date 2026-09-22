local M = {}
local refuel = require("refuel")

-- checks that there is an err, and prints it.
local function logErr(ok, err)
  if ok == false then -- can be nil
    err = err or "no error msg"
	  print(err)
  end
  return ok, err
end

-- Check if the block in front of the turtle is a log.
function M.isLog()
	local ok, block = turtle.inspect()
	return ok and block.tags["minecraft:logs"]
end

-- Destroy tree in front of turtle.
function M.destroyTree()
  local distance = 0
  -- Start ascent!
  while turtle.detect() do
    local found_log = M.isLog()
    if not found_log then
      break
    end
    -- Check if refueling is neccessary.
    if turtle.getFuelLevel() < 100 then
      refuel.refuel()
    end
    local dug, _ = turtle.dig()
    if not dug then break end
    dug, _ = turtle.digUp()
    local moved, _ = turtle.up()
    if not moved then break end
    distance = distance + 1
  end
  if distance == 0 then return true end
  print(distance,
    "blocks from starting position.")
  -- Start descent!
  for i = 1, distance do
    local mDown = false
    repeat
      mDown, _ = turtle.down()
      if not mDown then turtle.digDown() end
    until mDown
  end
  return true
end

function M.isSlotWithSapling(slot)
  local block = turtle.getItemDetail(slot, true)
  if block == nil then return false end
  return block.tags["minecraft:saplings"]
end

function M.plantSapling()
  local have_sapling = false
  for i = 1, 16 do
    turtle.select(i)
    if M.isSlotWithSapling(i) then
      have_sapling = true
      -- No error check. Assume sapling already placed if failed.
      turtle.place()
      break
    end
  end
  if not have_sapling then
	  return false, "Out of Saplings!!!"
  end
  return true
end

function M.goToGround()
  while turtle.detectDown() == false do
    turtle.down()
  end
end

function M.doSingleTreeFarm()
  M.goToGround()
  while true do
    local ok, err = M.destroyTree()
    if not ok then print(err) break end
    ok, err = M.plantSapling()
    if not ok then print(err) break end
  end
end

-- This is where the large tree farm is being tested.
--[[ UNFINISHED!!!
The turtle should plant trees in a box (clockwise),
guided by an outer ring of blocks that are not
logs or saplings.
]]--

--[[ NOTES:
-There is a bug finding where to go if there is no sapling or log in front.
-Refueling is not automatic.
-Restocking saplings is not automatic.
-Depositing logs is not automatic,
  but can be worked around by filling every slot
  and relying on a vacuum chest.
]]--

-- Go from one sapling spot to the next.
function M.doLoopingTreeFarm(stall_time)
  stall_time = stall_time or 0
  M.goToGround()

  local function continueRoute()
    turtle.turnLeft()
    turtle.forward()
   	if turtle.detect() then -- wall found
      turtle.turnRight()
      turtle.forward()
      turtle.turnRight()
    else
      turtle.turnRight()
    end
    return true
  end

  --[[ First it needs to check that it is positioned by
  looking around for walls, saplings, and logs. ]]--
 	local ok, block = turtle.inspect()
	local found_wall = ok and not block.tags["minecraft:logs"] and not block.tags["minecraft:saplings"]
	local found_sapling = ok and block.tags["minecraft:saplings"]
	local found_log = ok and block.tags["minecraft:logs"]

	-- Bootstrap checks
	if found_wall then
		turtle.turnRight()
		turtle.forward()
    turtle.turnRight()
	elseif found_sapling then
	  continueRoute()
	elseif found_log then
    M.destroyTree()
  elseif not turtle.detect() then
    --[[ this is where it could be stuck in a
    corner or in front of a planting spot. ]]--
    -- Check if next to a log/sapling
    turtle.turnRight()
   	ok, block = turtle.inspect()
    found_sapling = ok and block.tags["minecraft:saplings"]
    found_log = ok and block.tags["minecraft:logs"]
    if found_sapling then
      continueRoute()
    elseif found_log then
      M.destroyTree()
      M.plantSapling()
    else
      print("TREEFARM IS WANDERING... WHERE AM I?!")
      return false
    end
	end

  while true do
    if not logErr(M.destroyTree()) then break end
    if not logErr(M.plantSapling()) then break end
    if not logErr(continueRoute()) then break end
    sleep(stall_time)
  end
end

return M
