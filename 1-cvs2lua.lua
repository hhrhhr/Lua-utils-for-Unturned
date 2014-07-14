if not arg[1] then
    print("no arguments")
    os.exit(false, true)
end
print()

local csv = {}

local category2index = {}
local category = {}
local category2items = {}
local item2index = {}
local item = {}
local craft = {}

local index_item = 0

category[1] = "unique"
category2index["unique"] = 1
category2items[1] = {}
local index_category = 1


-- parse .csv -----------------------------------------------------------------
local l = 0
for line in io.lines(arg[1]) do
    if l ~= 0 then
        local t = {}
        for l in string.gmatch(line, "([^,]*),") do
            table.insert(t, l)
        end
        table.insert(csv, t)
    end
    l = l + 1
end
print("csv input\t: " .. l .. " lines")

-- helper functions -----------------------------------------------------------
local function check_category(cat)
    if not category2index[cat] then
        index_category = index_category + 1
        category[index_category] = cat
        category2index[cat] = index_category
        category2items[index_category] = {}
    end
end

local function check_name(name, cat)
    if name == "" then return end
    if not item2index[name] then 
        index_item = index_item + 1
        item2index[name] = index_item
        local cat_idx = category2index[cat] or 1
        item[index_item] = {name = name, cat = cat_idx}
        table.insert(category2items[cat_idx], index_item)
        craft[index_item] = {}
    end
end


-- find categories ------------------------------------------------------------
for k, v in ipairs(csv) do
    check_category(v[1])
end
print("categories\t: " .. index_category)
index_category = nil

-- find craftable items -------------------------------------------------------
for k, v in ipairs(csv) do
    check_name(v[3], v[1]) -- item
end
print("items\t\t: " .. index_item .. " craftable")

-- find for uncraftable items -------------------------------------------------
for k, v in ipairs(csv) do
    check_name(v[5]) -- item1
    check_name(v[7]) -- item2
end
print("items\t\t: " .. index_item .. " total")
index_item = nil


-- fill craft table -----------------------------------------------------------
for k, v in ipairs(csv) do
    local idx = item2index[v[3]]
    if item[idx].cat > 1 then
        local t = {num = tonumber(v[2]), 
                    num1 = tonumber(v[4]), item1 = item2index[v[5]], 
                    tool = v[8], level = v[9]}
        if #v[6] > 0 then
            t.num2 = tonumber(v[6])
            t.item2 = item2index[v[7]]
        else
            t.num2 = 0
            t.item2 = 0
        end
        table.insert(craft[idx], t)
    end
end
print("craft table:\t: " .. #craft .. " blueprints")


-- make lua -------------------------------------------------------------------
local w = assert(io.open("generated_items.lua", "w+"))

w:write("local item={")
for k, v in ipairs(item) do
    local str = "[%d]={[\"cat\"]=%d,[\"name\"]=\"%s\"},"
    w:write(string.format(str, k, v.cat, v.name))
end
w:write("}\n")

w:write("local item2index={")
for k, v in pairs(item2index) do
    w:write(string.format("[\"%s\"]=%d,", k, v))
end
w:write("}\n")

w:write("local category={")
for k, v in ipairs(category) do
    w:write(string.format("[%d]=\"%s\",", k, v))
end
w:write("}\n")

w:write("local category2index={")
for k, v in pairs(category2index) do
    w:write(string.format("[\"%s\"]=%d,", k, v))
end
w:write("}\n")

w:write("local category2items={")
for k, v in ipairs(category2items) do
    w:write(string.format("[%d]={%s},", k, table.concat(v, ",")))
end
w:write("}\n")

w:write("local craft={\n")
for k, v in ipairs(craft) do
    w:write(string.format("\n[%d]={", k))
    for i, j in ipairs(v) do
        w:write(string.format("\n[%d]={", i))
        for n, m in pairs(j) do
            if type(m) == "string" then
                w:write(string.format("[\"%s\"]=\"%s\",", n, m))
            else
                w:write(string.format("[\"%s\"]=%d,", n, m))
            end
        end
        w:write("},")
    end
    w:write("},")
end
w:write("}\n")


w:write("return item, item2index, category, category2index, category2items, craft\n")

w:close()

print("\nlua tables saved, all done\n")
