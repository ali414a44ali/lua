-- ملف: tags.lua
local JSON = require("libs/dkjson")
local Redis = require('libs/redis').connect('127.0.0.1', 6379)

local tags = {}

function tags.Zelzal(msg)
    local chat_id = msg.chat_id
    local user_id = msg.sender_id.user_id
    local text = msg.content.text or ""
    
    -- جمل الرد العشوائية
    local tag_replies = {
        "ياعيوني تعال 🌹",
        "وينك حبي 😭",
        "تعال شوف الموضوع 😅",
        "هلا نورت 😍",
        "الگروب منور بيك ✨",
        "لك وينك اختفيت؟ 😂",
        "ناديته الك حيل 🥺"
    }

    -- التحقق من الرتبة: المالك / المنشئ الأساسي / المنشئ / المدير
    local function is_allowed()
        return Redis:sismember(Zelzal.."Zelzal:TheBasics:Group"..chat_id,user_id) or
               Redis:sismember(Zelzal.."Zelzal:TheMasics:Group"..chat_id,user_id) or
               Redis:sismember(Zelzal.."Zelzal:Managers:Group"..chat_id,user_id) or
               user_id == Sudo_Id
    end

    -- تهيئة التخزين
    if not Redis:get("tags:"..chat_id) then
        Redis:set("tags:"..chat_id, "{}")
    end
    local add_tag_step = {}

    -- اضافة تاك
    if text == "اضف تاك" and is_allowed() then
        add_tag_step[chat_id] = {step="name", from=user_id}
        return "↜ ارسل الان اسم التاك 🌹"
    end

    -- استلام الاسم
    if add_tag_step[chat_id] and add_tag_step[chat_id].step == "name" and add_tag_step[chat_id].from == user_id then
        local tag_name = text
        add_tag_step[chat_id] = {step="user", from=user_id, name=tag_name}
        return "↜ تم حفظ الاسم ("..tag_name..") ✅\n↜ الان ارسل اليوزر 🌹"
    end

    -- استلام اليوزر
    if add_tag_step[chat_id] and add_tag_step[chat_id].step == "user" and add_tag_step[chat_id].from == user_id then
        local tag_name = add_tag_step[chat_id].name
        local tag_user = text
        local tags_table = JSON.decode(Redis:get("tags:"..chat_id))
        tags_table[tag_name] = tag_user
        Redis:set("tags:"..chat_id, JSON.encode(tags_table))
        add_tag_step[chat_id] = nil
        return "↜ تم حفظ التاك بنجاح ✅\n"..tag_name.." → "..tag_user
    end

    -- مسح تاك
    local del_name = text:match("^مسح تاك (.+)$")
    if del_name and is_allowed() then
        local tags_table = JSON.decode(Redis:get("tags:"..chat_id))
        if tags_table[del_name] then
            tags_table[del_name] = nil
            Redis:set("tags:"..chat_id, JSON.encode(tags_table))
            return "↜ تم مسح التاك ("..del_name..") ✅"
        else
            return "↜ هذا التاك مو موجود ❌"
        end
    end

    -- عرض كل التاكات
    if text == "قائمة التاكات" then
        local tags_table = JSON.decode(Redis:get("tags:"..chat_id))
        local list = "↜ قائمة التاكات المضافة 📋:\n"
        for k,v in pairs(tags_table) do
            list = list.."\n"..k.." → "..v
        end
        return list
    end

    -- مسح كل التاكات
    if text == "مسح قائمة التاكات" and is_allowed() then
        Redis:set("tags:"..chat_id, "{}")
        return "↜ تم مسح جميع التاكات ✅"
    end

    -- الرد على ذكر التاكات
    local tags_table = JSON.decode(Redis:get("tags:"..chat_id))
    for name, user in pairs(tags_table) do
        if text:match(name) then
            local reply = tag_replies[math.random(#tag_replies)]
            return reply.." : "..user
        end
    end
end

return tags
