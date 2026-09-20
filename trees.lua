local M = {}
local refuel = require("refuel")

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

function M.isHoldingSapling(slot)
  local block = turtle.getItemDetail(slot, true)
  if block == nil then return false end
  return block.tags["minecraft:saplings"]
end

function M.plantSapling()
  local have_sapling = false
  for i = 1, 16 do
    turtle.select(i)
    if M.isHoldingSapling(i) then
      have_sapling = true
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

M.goToGround()

while true do
  local ok, err = M.destroyTree()
  if not ok then
	  print(err)
		break
  end
  ok, err = M.plantSapling()
  if not ok then
    print(err)
    break
  end
end
