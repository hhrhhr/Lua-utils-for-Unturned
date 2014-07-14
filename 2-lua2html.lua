local item, item2index, category, category2index, category2items, craft 
    = dofile("generated_items.lua")

local function get_row(item, num, item1, num1, tool, level, item2, num2)
    local row = [[
    <tr class="tr1">
        <td class=icon rowspan="2">&nbsp</td>
        <td class="item">%s</td>
        <td class="item1">%s</td>
        <td class="num1">%s</td>
        <td class="tool">%s</td>
    </tr>
    <tr class="tr2">
        <!-- icon -->
        <td class="num">%s</td>
        <td class="item2">%s</td>
        <td class="num2">%s</td>
        <td class="level">%s</td>
    </tr>
]]
    local str = string.format(row, 
        item, item1,          num1,          tool, 
        num,  item2 or "---", num2 or "---", level)
    return str
end


print([[<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style type="text/css">
.craft { border: 1px; border-collapse: collapse }
.craft tr:nth-of-type(2n) { background-color: #f9f9f9; }
.craft tr:nth-of-type(2n+1) { border-top: 1px solid red; }
.craft td { padding: 0.2em 0.5em; }
.icon { background-color: #f0f0f0; }
.icon:before { content: "no icon"; }
</style>
</head>
<body>]])

-- num, num1, item1, num2, item2, tool, level
print("<table class=\"craft\">")
for k, v in ipairs(craft) do
    for i, j in ipairs(v) do
        print(get_row(item[k].name, j.num, 
            item[j.item1].name, j.num1,
            j.tool, j.level,
            j.num2 > 0 and item[j.item2].name or nil, j.num2 > 0 and j.num2 or nil))
    end
end
print("</table>")

print([[</body>
</html>]])