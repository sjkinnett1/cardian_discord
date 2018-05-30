-- Copyright © 2018, Stephen Kinnett
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Cardian_Bot nor the
      -- names of its contributors may be used to endorse or promote products
      -- derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Stephen Kinnett BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- _addon.name = 'Cardian_Bot'
-- _addon.author = 'Stephen Kinnett'
-- _addon.version = '0.0.0.2'

local discordia = require('discordia')
local client = discordia.Client()
local discord_info = require('discord_info')
discordia.extensions()
local clock = discordia.Clock()

--Loads stored server info and default settings
_G["sh"] = discord_info.shout_channel_id()
_G["ls"] = discord_info.linkshell_channel_id()
_G["tl"] = discord_info.tell_channel_id()
discardian_path = discord_info.discardian_path()
admin = discord_info.admin()
token = discord_info.bot_token()
show_tells = discord_info.show_tells()
show_linkshell = discord_info.show_linkshell()
show_shouts = discord_info.show_linkshell()
spam_tolerance = discord_info.spam_tolerance()
message_request = {}

--Creates or empties files used for data transfer
local f=io.open(discardian_path .. "to_discord.txt","w+")
io.close(f)
local f=io.open(discardian_path .. "to_ffxi.txt","w+")
io.close(f)

--Initializes global variables
watch_words = {}
chat_log = {}
cardians = {}
cardian_number = 1
cardian_total = 1
cardian_check_times = {}

--Processed upon initial connection to Discord
client:on('ready', function()
	print('Logged in as '.. client.user.username)
	--Initializes clock for repeated action functions (file check)
	clock:start();
	--Populates initial cardian table and check times based upon single bot
	i = cardian_number
	j = 1
	while j < 60 do
		j = (cardian_number -1 )* 3 + cardian_total * 3 * (i - 1)
		table.insert(cardian_check_times, j)
		i = i + 1
	end
	table.insert(cardians, client.user.id)
	--Announces login, begins handshake with other cardians
	cardian_announce()
end)

--Runs when a Discord user's presence (available, idle, unavailable, offline)
client:on('presenceUpdate', function(member)
	--If the update was by a cardian and the update was to "offline", runs cardian_remove function
	for k, cardian in pairs(cardians) do
		if cardian == member.id and member[11] == "offline" then
			cardian_remove(member)
		end
	end
end)

--Runs every time the bot receives a message from any avenue in Discord
client:on('messageCreate', function(message)
	--Standardizes format to match that supplied by FFXI, for comparison
	message_modified = string.gsub(message.content, "\n", " ")
	--Removes Discord-specific content from strings going to FFXI
	message_modified = string.gsub(message_modified, "<(.-)>", function(content) content = discord_content_found(content) return(content) end) 
	--Inserts received string to chat_log for comparison and prevention of duplicate messages
	table.insert(chat_log, message_modified)
	--This begins the data analysis and acting upon result section.
----------------------------------------------------ADD BOT FUNCTIONS HERE----------------------------------------------------
	-- format:
	-- if (or elseif, if placed after initial if) message.content == <TRIGGER_WORD> then
		-- <resultant action>
	-- end (if no following elseif commands)
	
	if message.content == "killbot" then 
		os.exit()
	elseif message.content == "momo" then
		message.channel:send(":robot:")
	--IMPORTANT FUNCTION! Erases cardian bot-net and handshakes for new bot-net
	elseif message.content == "Cardians, assemble!" then
		cardians = {}
		cardian_number = 1
		cardian_total = 1
		message.channel:send("Cardian reporting for duty!")
	--IMPORTANT FUNCTION! Adds all bot-net handshakes to bot-net (including self from previous message.content)
	elseif message.content == "Cardian reporting for duty!" then
		table.insert(cardians, message.author.id)
		--Each time a new bot is added to cardians, every bot sorts list so they all have the same bots in the same order
		--This allows them to establish a priority list based upon their Discord-assigned IDs.
		table.sort(cardians)
		cardian_total = 0
		--Function to find this bot's specific position in the cardian list (used to establish start time) and total cardians (used to calculate repetition frequency)
		for k, v in pairs(cardians) do
			if v == client.user.id then cardian_number = k end
			if k > cardian_total then cardian_total = k end
		end
		--Sends cardian info to addon for position and frequency calculations
		local f=io.open(discardian_path .. "to_ffxi.txt","a")
		f:write(string.format("%03d:%03d", cardian_number, cardian_total) .. "=cardian_assign_order \n")
		f:close()
		--Calculates schedule for checking for new data. This takes into account cardian position and frequency
		cardian_check_times = {}
		i = cardian_number
		j = 1
		while j < 60 do
			j = (cardian_number - 1) * 3 + cardian_total * 3 * (i - 1)
			table.insert(cardian_check_times, j)
			i = i + 1
		end
	--Allows for sending non-Linkshell_channel messages by prefacing with "/l" in any cardian observed channel
	elseif message.content:sub(1,3) == "/l " and message.author.bot == false and show_linkshell == true then
		local f=io.open(discardian_path .. "to_ffxi.txt","a")
		f:write('/l <' .. message.author.name .. '> ' .. message_modified:sub(4) .. "\n")
		f:close()
	elseif message.content == "!screenshot" then
		message_request = message
		local f=io.open(discardian_path .. "to_ffxi.txt","a")
		f:write("SCREENSHOTREQUESTED\n")
		f:close()
		return
	--Sends all non-cardian messages from Linkshell_channel to FFXI
	elseif message.channel[4] == ls and message.author.bot == false and show_linkshell == true then
		local f=io.open(discardian_path .. "to_ffxi.txt","a")
		f:write('/l <' .. message.author.name .. '> ' .. message_modified .. "\n")
		f:close()
		table.insert(chat_log, '/l <' .. message.author.name .. '> ' .. message_modified .. "\n")
	--Toggles for activating/deactivating tell, shout, and linkshell messages
	elseif message.content == "!notells" and message.author.id == admin then
		show_tells = false
		print("Set show_tells to false!")
	elseif message.content == "!tells" and message.author.id == admin then
		show_tells = true
		print("Set show_tells to true!")
	elseif message.content == "!noshouts" and message.author.id == admin then
		show_shouts = false
		print("Set show_shouts to false!")
	elseif message.content == "!shouts" and message.author.id == admin then
		show_shouts = true
		print("Set show_shouts to true!")
	elseif message.content == "!nolinkshell" and message.author.id == admin then
		show_linkshell = false
		print("Set show_linkshell to false!")
	elseif message.content == "!linkshell" and message.author.id == admin then
		show_linkshell = true
		print("Set show_linkshell to true!")
	--Allows for watch words, things people would like to be pinged if a cardian sees in messages. Names, quests, content, items, etc.
	--Adds word and user to list for response if word is found
	elseif message.content:sub(1, 7) == "!watch " then
		message.channel:send("Added watch word " .. message.content:sub(8) .. "!")
		table.insert(watch_words, { user_id = message.author.id, word = message.content:sub(8) })
	--Removes watch word
	elseif message.content:sub(1, 9) == "!unwatch " then
		for k, word in pairs(watch_words) do
			if (word.user_id == message.author.id and word.word == message.content:sub(10)) then
				table.remove(watch_words, k)
				message.channel:send("Removed watch word " .. message.content:sub(10) .. "!")
			end
		end
	--Allows for users in the tell channel to send commands directly to FFXI for implementation
	elseif message.channel[4] == tl and message.author.bot == false and message.content:sub(1,1) == "/" and show_tells == true then
		local f=io.open(discardian_path .. "to_ffxi.txt","a")
		f:write(message_modified .. "\n")
		f:close()
	end
end)

--Every second, the cardian checks to see if it's time to take an action
clock:on('sec', function()
	tmp = os.date("*t")
	for key, value in pairs(cardian_check_times) do
		if tmp.sec == value then
			check_file()
		end
	end
end)

--Upon initilization, beings handshake to establish list of active cardians
function cardian_announce()
	local tmp_channel = client:getChannel(tl)
	if tmp_channel ~= nil then
		tmp_channel:send("Cardians, assemble!")
	end
end

--Called when a cardian is detected as offline. Removes from cardians and re-calculates start time and frequency
function cardian_remove(member)
	--Simply removes offline cardian
	for pos, cardian in pairs(cardians) do
		if cardian == member.id then
			table.remove(cardians, pos)
		end
	end
	--Re-sorts cardians based on removed member
	table.sort(cardians)
	cardian_total = 0
	for k, v in pairs(cardians) do
		if v == client.user.id then cardian_number = k end
		if k > cardian_total then cardian_total = k end
	end
	--Tells add-on new priority position and frequency
	local f=io.open(discardian_path .. "to_ffxi.txt","a")
	f:write(string.format("%03d:%03d", cardian_number, cardian_total) .. "=cardian_assign_order \n")
	f:close()
	--Re-calculates check times for this particular cardian
	cardian_check_times = {}
	i = cardian_number
	j = 1
	while j < 60 do
		j = (cardian_number - 1) * 3 + cardian_total * 3 * (i - 1)
		table.insert(cardian_check_times, j)
		i = i + 1
	end
end

--Addresses pinging someone in a channel showing as user_id in FFXI
function discord_content_found(content)
	if content:sub(1, 1) == "@" then
		if content:sub(2,2) == "!" then
			tmp_user_id = content:sub(3, content:len())
		else
			tmp_user_id = content:sub(2, content:len())
		end
		tmp_user = client:getUser(tmp_user_id)
		return(tmp_user.username)
	else
		return("<discord content>")
	end
end

function screenshot(screenshot_name)
	tmp = discardian_path:sub(1, discardian_path:len() - 15) .. "screenshots/" .. screenshot_name .. ".png"
	message_request.channel:send {file = tmp}
end

--Reads file populated by FFXI add-on
function check_file()
	--Opens and reads file for incoming data, adds found lines to new_chat
	local f=io.open(discardian_path .. "to_discord.txt","r")
	if f~=nil then
		local new_chat = {}
		for line in f:lines() do
			table.insert (new_chat, line);
		end
		io.close(f)
		--After loading data, clears file
		local f=io.open(discardian_path .. "to_discord.txt","w+")
		io.close(f)
		--Begins acting upon new data from new_chat
		for k, line in pairs(new_chat) do
			found = 0
			to_delete = 0
			if line:sub(1,20) == 'CARDIANADDONUNLOADED' then print("Exiting!") os.exit() end
			if line:sub(1,18) == 'SCREENSHOTRETURNED' then
				screenshot(line:sub(19, line:len() - 1))
				return
			end
			--Checks for an already processed message, trims log if it gets longer than spam_tolerance
			for pos, check in pairs(chat_log) do
				if (check == line:sub(3, line:sub(1):len() -1)) then found = 1 end
				if pos > spam_tolerance then to_delete = to_delete + 1 end
			end
			--Dumps if already processed message
			if found == 1 then
				table.remove(new_chat, k) 
			else
				--Acts upon non-repeated data
				tmp = line:sub(1,2) --First 2 characters are routing information
				tmp_channel_id = _G[tmp] --Finds target channel based on routing characters
				local tmp_channel = client:getChannel(tmp_channel_id) --Gets channel data struct based on channel_id
				tmp = (line:sub(3)) --Isolates the message part
				if tmp ~= nil and tmp_channel ~= nil then
					--Checks to make sure the target channel is accepting messages and sends
					if (tmp_channel_id == tl and show_tells == false) or (tmp_channel_id == ls and show_linkshell == false) or (tmp_channel_id == sh and show_shouts == false) then
						return
					else
						tmp_channel:send(tmp) 
					end
				end
				--Pings if watch word is found
				for z, word in pairs(watch_words) do
					if string.match(string.lower(line), string.lower(word.word)) then
						local tmp_user = word.user_id
						tmp_channel:send("<@" .. tmp_user .. "> " .. word.word)
					end
				end
			end
		end 
	end
end

client:run(token)
	