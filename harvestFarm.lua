-- Create a daemon that harvests the crops whenever they are matured.
function main()
    -- No refuel
    while true do
        if(cropsMatured()) then
            print("Turtle is beginning to harvest crops.")
            beginHarvestCrops()
        else
            print("The crops are not ready to be harvested.")
            sleep(60)
        end
    end
end

function cropsMatured()
    local has_block, data = turtle.inspectDown()

    -- From what I tested with the crops in my farm, matured
    -- crops either had an age of 3 or 7, with the age 3 crops
    -- being bushes, such as tomatoes or berries. I would rather it
    -- be based off of the age 7 crops so that is the only thing checked here.
    -- There was also no easily discernable way to tell if age 3 crops were
    -- bushes or were age 7 crops.
    if (data["state"]["age"] == 7) then
        return true
    else
        return false
    end
end

function beginHarvestCrops()

    MAX_TIERS = 4
    MAX_CHUNKS = 4

    --cropTable = loadInCrops()
    totalSlots = loadInCrops()

    local i
    local j


    -- This is for my minecraft farm. It is set up
    -- to have 4 tiers of crops with each having 4 chunks
    -- of 4x3 areas of land.
    for i = 0, MAX_TIERS - 1, 1 do
        for j = 0, MAX_CHUNKS - 1, 1 do
            destroyAndReplantFarmArea(4, 3)

            if (j ~= MAX_CHUNKS - 1) then
                moveToNextChunk()
            end
        end

        if (i ~= MAX_TIERS - 1) then
            moveToNextTier()
        else
            moveToStart()
        end
    end
end

function loadInCrops()
    --local tempTable = {}

    turtle.select(1)

    local currentSlot = 1

    -- Find the amount of crops/seeds we have to replant.
    -- We have all of our slots filled we either crops or with cobblestone.
    -- We want to have the rest of the slots filled with any block we're not using
    -- so that any extra items do not fill our turtle and instead are picked up by our hoppers.
    while (turtle.getItemDetail(currentSlot)["name"] ~= "minecraft:cobblestone") do
        --tempTable[currentSlot] = turtle.getItemCount(currentSlot)
        currentSlot = currentSlot + 1
        turtle.select(currentSlot)
    end

    local totalSlots = currentSlot - 1

    --return tempTable
    return totalSlots
end

function destroyAndReplantFarmArea(CHUNK_LENGTH, CHUNK_WIDTH)
    local i

    -- For each row,
    for i = 0, CHUNK_WIDTH - 1, 1 do

        local j

        -- Go down the column first.
        for j = 0, CHUNK_LENGTH - 1, 1 do
            -- Dig the crop beneath us, find which crop it was, and replant it.
            turtle.digDown()

            local slotPickedUp = checkItemPickedUp()
            
            -- Make sure we did pick up a crop in the turtle.
            if (slotPickedUp ~= -1) then
                turtle.select(slotPickedUp)
                turtle.placeDown()
            end

            -- After that, we want to move to the next crop in the column.
            if (j < CHUNK_LENGTH - 1) then
                -- Don't move if it's the last block in the row.
                turtle.forward()
            end
        end

        -- Determine which way to turn on the end of a column
        if (i ~= CHUNK_WIDTH - 1) then
            if (i % 2 == 0) then
                -- Even row
                turtle.turnRight()
                turtle.forward()
                turtle.turnRight()
            else
                -- Odd row
                turtle.turnLeft()
                turtle.forward()
                turtle.turnLeft()
            end
        end
    end
end

-- Bunch of problems to consider with this one normally.
-- How do we filter out different seeds? How do we differentiate between
-- crops that plant themselves (potatoes, carrots, etc.) and crops that require
-- seeds. What if our inventory is full? What if the crops aren't placed neatly?
-- What if? What if? What if?
-- However, because we have full knowledge of how our farm is set up, we can make a turtle
-- that is best fit to that farm.
-- Our setup is everything plantable (crops/seeds) and some random block in the other slots.
-- The crops/seeds are stacks of 63, meaning we will pick up only 1 of whatever we harvest
-- and the rest are sent to storage. We can use the info of picking up whatever we just
-- harvested to figure out what to replant.
-- This is easily adjustable. Just add new crops to the turtle in stacks of 63. Also
-- handles each crop individually so we do not have to worry about any weird crop placements.
function checkItemPickedUp()
    local k
    for k = 1, totalSlots, 1 do
        if (turtle.getItemCount(k) ~= 63) then
            return k
        end
    end

    return -1
end

function moveToNextChunk()
    turtle.back()
    turtle.back()
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
end

function moveToNextTier()
    local i

    turtle.turnLeft()
    for i = 0, 10, 1 do
        turtle.forward()
    end

    for i = 0, 1, 1 do
        turtle.up()
    end

    turtle.turnLeft()

    for i = 0, 10, 1 do
        turtle.forward()
    end

    turtle.turnRight()
    turtle.turnRight()
end

-- Move to the beginning of the crop field
-- You could do this using relative position. However,
-- I do not see the farm expanding anytime soon. I'll change
-- this function if it does.
function moveToStart()
    turtle.turnLeft()

    local i
    for i = 0, 10, 1 do
        turtle.forward()
    end

    turtle.turnRight()

    for i = 0, 8, 1 do
        turtle.forward()
    end

    for i = 0, 5, 1 do
        turtle.down()
    end
end

main()