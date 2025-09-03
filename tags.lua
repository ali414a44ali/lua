-- ملف: tags.lua
local tags = {}

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

-- تخزين التاكات
if not redis:get("tags") then
    redis:set("tags", "{}")
end

local add_tag_step = {}

-- دالة للتحقق من صلاحيات المستخدم حسب الرتب الموجودة في rotba.lua
local function has_permission(msg)
    local user_id = msg.sender_user_id
    if TheBasicsz[user_id] then return true end   -- المنشئ الأساسي
    if Originatorsz[user_id] then return true end -- المنشئ
    if Managersz[user_id] then return true end    -- المدير
    return false
end

-- دالة Zelzal(msg) للتعامل مع أوامر التاكات
function tags.Zelzal(msg)
    local text = msg.text
    local tags_data = JSON.decode(redis:get("tags") or "{}")

    -- إضافة تاك
    if text == "اضف تاك" and has_permission(msg) then
        add_tag_step[msg.chat_id] = {step="name", from=msg.sender_user_id}
        return "↜ ارسل الان اسم التاك 🌹"
    end

    -- استلام الاسم
    if add_tag_step[msg.chat_id] and add_tag_step[msg.chat_id].step == "name" and add_tag_step[msg.chat_id].from == msg.sender_user_id then
        local tag_name = text
        add_tag_step[msg.chat_id] = {step="user", from=msg.sender_user_id, name=tag_name}
        return "↜ تم حفظ الاسم ("..tag_name..") ✅\n↜ الان ارسل اليوزر 🌹"
    end

    -- استلام اليوزر
    if add_tag_step[msg.chat_id] and add_tag_step[msg.chat_id].step == "user" and add_tag_step[msg.chat_id].from == msg.sender_user_id then
        local tag_name = add_tag_step[msg.chat_id].name
        local tag_user = text

        if tags_data[tag_name] then
            return "↜ هذا التاك موجود بالفعل ❌"
        end

        tags_data[tag_name] = tag_user
        redis:set("tags", JSON.encode(tags_data))
        add_tag_step[msg.chat_id] = nil
        return "↜ تم حفظ التاك بنجاح ✅\n"..tag_name.." → "..tag_user
    end

    -- مسح تاك
    if text:match("^مسح تاك (.+)$") and has_permission(msg) then
        local del_name = text:match("^مسح تاك (.+)$")
        if tags_data[del_name] then
            tags_data[del_name] = nil
            redis:set("tags", JSON.encode(tags_data))
            return "↜ تم مسح التاك ("..del_name..") ✅"
        else
            return "↜ هذا التاك مو موجود ❌"
        end
    end

    -- عرض قائمة التاكات
    if text == "قائمة التاكات" then
        local list = "↜ قائمة التاكات المضافة 📋:\n"
        for k,v in pairs(tags_data) do
            list = list.."\n"..k.." → "..v
        end
        return list
    end

    -- مسح جميع التاكات
    if text == "مسح قائمة التاكات" and has_permission(msg) then
        redis:set("tags", "{}")
        return "↜ تم مسح جميع التاكات ✅"
    end

    -- الرد عند ذكر التاك
    for name, user in pairs(tags_data) do
        if text:match("%f[%w]"..name.."%f[%W]") then
            local reply = tag_replies[math.random(#tag_replies)]
            return reply.." : "..user
        end
    end

    return nil
end

return tags
