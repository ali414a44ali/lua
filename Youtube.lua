-- تعريف المتغيرات الأساسية
local Zelzal = "Zelzal:"
local Fast = 7291869416  -- رقم البوت أو المسؤول
local JSON = require("dkjson") -- تأكد ان مكتبة JSON موجودة
local URL = require("socket.url") -- لتشفير الروابط

function youtube(msg)
    local text = nil
    if msg and msg.content and msg.content.text then
        local xname = Redis:get(Zelzal.."Name:Bot") or "بووت"
        text = msg.content.text.text
        local match_text = text:match("^"..xname.." (.*)$")
        if match_text then text = match_text end
    end

    local msg_chat_id = msg.chat_id
    local msg_id = msg.id

    if tonumber(msg.sender_id.user_id) == tonumber(Fast) then return false end

    -- استرجاع أي أوامر مختصرة
    if text then
        local neww = Redis:get(Zelzal.."Get:Reides:Commands:Group"..msg_chat_id..":"..text)
                     or Redis:get(Zelzal.."All:Get:Reides:Commands:Group"..text)
        if neww then text = neww end
    end

    -- دالة للتحقق من التفعيل/التعطيل
    local function isEnabled(service)
        return not Redis:get(Zelzal..service..msg_chat_id)
    end

    local function getUsername(user_id)
        local user = bot.getUser(user_id)
        return user.first_name and "["..user.first_name.."](tg://user?id="..user.id..")" or "لا يوجد اسم"
    end

    local function sendFile(path, type, username)
        if type == "video" then
            bot.sendVideo(msg_chat_id,msg_id,path,"- من قبل : "..username,"md")
        elseif type == "audio" then
            bot.sendAudio(msg_chat_id,msg_id,path,"- من قبل : "..username,"md",nil,"soundc")
        end
        os.remove(path)
    end

    -- يوتيوب/سوشل أوامر تفعيل وتعطيل
    if text == "تعطيل اليوتيوب" or text == "تعطيل يوتيوب" then
        if not msg.Addictive then return send(msg_chat_id,msg_id,'⇜ هذا الامر يخص ('..Controller_Num(7)..')',"md",true) end
        if not isEnabled("youtubee") then
            Redis:set(Zelzal.."youtubee"..msg_chat_id,"true")
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم تعطيل اليوتيوب","md",true)
        else
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم تعطيل اليوتيوب مسبقاً","md",true)
        end
    end

    if text == "تفعيل اليوتيوب" or text == "تفعيل يوتيوب" then
        if not msg.Addictive then return send(msg_chat_id,msg_id,'⇜ هذا الامر يخص ('..Controller_Num(7)..')',"md",true) end
        if not isEnabled("youtubee") then
            Redis:del(Zelzal.."youtubee"..msg_chat_id)
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم تفعيل اليوتيوب","md",true)
        else
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم تفعيل اليوتيوب مسبقاً","md",true)
        end
    end

    -- التحميل والسوشل
    local function toggleService(service,text_on,text_off)
        if not msg.Addictive then return send(msg_chat_id,msg_id,'⇜ هذا الامر يخص ('..Controller_Num(7)..')',"md",true) end
        if not isEnabled(service) then
            Redis:set(Zelzal..service..msg_chat_id,"true")
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم "..text_on,"md",true)
        else
            Redis:del(Zelzal..service..msg_chat_id)
            return send(msg_chat_id,msg_id,GetByName(msg).." ⇜ تم "..text_off,"md",true)
        end
    end

    if text:match("^(تعطيل التحميل)$") or text:match("^(تعطيل سوشل)$") then
        return toggleService("soshle",text,text)
    end
    if text:match("^(تفعيل التحميل)$") or text:match("^(تفعيل سوشل)$") then
        return toggleService("soshle",text,text)
    end

    -- للمميزين
    if text:match("^(اليوتيوب للمميزين)$") or text:match("^(سوشل للمميزين)$") then
        if not msg.TheBasicsQ then return send(msg_chat_id,msg_id,'⇜ هذا الامر يخص المالك',"md",true) end
        Redis:set(Zelzal.."sochal"..msg_chat_id,"true")
        return send(msg_chat_id,msg_id,"⇜ تم تعيين "..text.." ومافوق","md",true)
    end

    if text:match("^(اليوتيوب للاعضاء)$") or text:match("^(سوشل للاعضاء)$") then
        if not msg.TheBasicsQ then return send(msg_chat_id,msg_id,'⇜ هذا الامر يخص المالك',"md",true) end
        Redis:del(Zelzal.."sochal"..msg_chat_id)
        return send(msg_chat_id,msg_id,"⇜ تم تعيين السوشل لجميع الاعضاء","md",true)
    end

    -- تحميل الفيديو من فيسبوك
    if text and (text:match("^فيس (.*)$") or text:match("^(.*) فيس$")) then
        local facelink = text:match("^فيس (.*)$") or text:match("^(.*) فيس$")
        if isEnabled("soshle") then return false end
        if not msg.Distinguished and not isEnabled("sochal") then
            return send(msg_chat_id,msg_id,"⇜ عذراً الفيسبوك للمميزين ومافوق فقط","md",true)
        end
        local username = getUsername(msg.sender_id.user_id)
        os.execute("yt-dlp "..facelink.." --max-filesize 50M -o 'face.mkv'")
        local facefile = io.open("face.mkv","r")
        if facefile then
            facefile:close()
            sendFile("face.mkv","video",username)
        else
            return send(msg_chat_id,msg_id,'⇜ لا استطيع تحميل اكثر من 50 ميغا',"md",true)
        end
    end

    -- تيك توك
    if text and (text:match("^تيك (.*)$") or text:match("^(.*) تيك$")) then
        local tiklink = text:match("^تيك (.*)$") or text:match("^(.*) تيك$")
        if isEnabled("soshle") then return false end
        if not msg.Distinguished and not isEnabled("sochal") then
            return send(msg_chat_id,msg_id,"⇜ عذراً التيك توك للمميزين ومافوق فقط","md",true)
        end
        local username = getUsername(msg.sender_id.user_id)
        os.execute("yt-dlp "..tiklink.." --max-filesize 50M -o 'tik.mp4'")
        local tikfile = io.open("tik.mp4","r")
        if tikfile then
            tikfile:close()
            sendFile("tik.mp4","video",username)
        else
            return send(msg_chat_id,msg_id,'⇜ لا استطيع تحميل اكثر من 50 ميغا',"md",true)
        end
    end

    -- ساوند كلاود
    if text and (text:match("^رابط ساوند (.*)$")) then
        local soundlink = text:match("^رابط ساوند (.*)$")
        if isEnabled("soshle") then return false end
        if not msg.Distinguished and not isEnabled("sochal") then
            return send(msg_chat_id,msg_id,"⇜ عذراً الساوند للمميزين ومافوق فقط","md",true)
        end
        local username = getUsername(msg.sender_id.user_id)
        os.execute("yt-dlp "..soundlink.." --max-filesize 25M -o 'soundc.mp3'")
        local soufile = io.open("soundc.mp3","r")
        if soufile then
            soufile:close()
            sendFile("soundc.mp3","audio",username)
        else
            return send(msg_chat_id,msg_id,'⇜ لا استطيع تحميل اكثر من 25 ميغا',"md",true)
        end
    end

    -- بحث ساوند
    if text and (text:match("^ساوند (.*)$") or text:match("^(.*) [Ss]$")) then
        local search = text:match("^ساوند (.*)$") or text:match("^(.*) [Ss]$")
        if isEnabled("soshle") then return false end
        if not msg.Distinguished and not isEnabled("sochal") then
            return send(msg_chat_id,msg_id,"⇜ عذراً الساوند للمميزين ومافوق فقط","md",true)
        end
        local jsonson = JSON.decode(request("https://anubis.fun/api/sound_search.php?q="..URL.escape(search)))
        Redis:set(Zelzal.."soundidche"..msg_chat_id..msg.sender_id.user_id,search)
        local datar = {}
        for i = 1,5 do
            local titlee = jsonson.result[tostring(i)].title
            local link = tostring(jsonson.result[tostring(i)].url):gsub("https://soundcloud.com/",'')
            datar[i] = {{text = titlee , data = search..":socl:"..link}}
        end
        local reply_markup = bot.replyMarkup{type = 'inline', data = datar}
        bot.sendText(msg_chat_id,msg_id,'نتائج بحثك على الساوند ل ( *'..search..'* )',"md",false,false,false,false,reply_markup)
    end

    -- بحث يوتيوب
    if text and text:match("^بحث (.*)$") then
        local search = text:match("^بحث (.*)$")
        if isEnabled("youtubee") then return false end
        if not msg.Distinguished and not isEnabled("sochal") then
            return send(msg_chat_id,msg_id,"⇜ عذراً اليوتيوب للمميزين ومافوق فقط","md",true)
        end
        local jsonyou = JSON.decode(request("https://youtube-scrape.herokuapp.com/api/search?q="..URL.escape(search)))
        Redis:set(Zelzal.."youtidche"..msg_chat_id..msg.sender_id.user_id,search)
        local datar = {}
        for i = 1,5 do
            local titlee = jsonyou.results[i].video.title
            local link = tostring(jsonyou.results[i].video.url):gsub("https://youtu.be/",'')
            datar[i] = {{text = titlee , data = search..":yout:"..link}}
        end
        local reply_markup = bot.replyMarkup{type = 'inline', data = datar}
        bot.sendText(msg_chat_id,msg_id,'نتائج بحثك على اليوتيوب ل ( *'..search..'* )',"md",false,false,false,false,reply_markup)
    end
end
