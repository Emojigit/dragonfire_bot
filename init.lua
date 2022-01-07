local channel = minetest.mod_channel_join("dragonfire_bot")
dragonfire_bot = {
    N = minetest.get_current_modname(),
    registered_commands = {},
    owner = "",
    bot = nil
}

minetest.after(3,function()
    dragonfire_bot.bot = minetest.localplayer:get_name()
end)

local function splitonce(s, p)
    local b, e = string.find(s, p, 1, true)
    if b then
        return string.sub(s, 1, b-1), string.sub(s, e+1, -1)
    else
        return s, ""
    end
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
    minetest.log("info",("[dragonfire_bot] modchannel '%s' '%s' '%s'"):format(channel_name,sender,message))
    if channel_name ~= "dragonfire_bot" then return end
    if owner ~= sender then return end
    local bot,msg = splitonce(message)
    if bot ~= dragonfire_bot.bot then return end
    local cmd,param = splitonce(msg)
    if dragonfire_bot.registered_commands[cmd] then
        local status,ret = dragonfire_bot.registered_commands[cmd].func(param)
        if ret then
            channel:send_all(ret)
        elseif status == false then
            channel:send_all("-!- Bot command failed.")
        end
    else
        channel:send_all("-!- Invalid bot command: " .. cmd)
    end
end)

function dragonfire_bot.register_command(name,def)
    dragonfire_bot.registered_commands[name] = def
end

dragonfire_bot.register_command("msg",{
    description = "Send a chatmessage as the bot",
    func = function(param)
        minetest.send_chat_message(param)
        return true, "Done."
    end
})

dragonfire_bot.register_command("cmd",{
    description = "Send a command as the bot",
    func = function(param)
        minetest.send_chat_message("/" .. param)
        return true, "Done."
    end
})

minetest.register_chatcommand("set_owner",{
    func = function(param)
        dragonfire_bot.owner = param
    end
})
