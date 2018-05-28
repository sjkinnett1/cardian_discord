-- Copyright © 2018, Stephen Kinnett
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

    -- * Redistributions of source code must retain the above copyright
      -- notice, this list of conditions and the following disclaimer.
    -- * Redistributions in binary form must reproduce the above copyright
      -- notice, this list of conditions and the following disclaimer in the
      -- documentation and/or other materials provided with the distribution.
    -- * Neither the name of Cardian nor the
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

-- _addon.name = 'Cardian'
-- _addon.author = 'Stephen Kinnett'
-- _addon.version = '0.0.0.1'

--To get this data, turn on Developer Mode in Discord and right click these targets. Select "Copy ID" and paste here (between ' and ')
admin = 'PLACE YOUR DISCORD ID HERE'
shout = 'PLACE SHOUT CHANNEL ID HERE'
linkshell = 'PLACE LINKSHELL CHANNEL ID HERE'
tell = 'PLACE TELL CHANNEL ID HERE'
--Get this from the Discord developer page. (https://discordapp.com/developers/applications/me)
token = 'PLACE DISCORD BOT TOKEN HERE'
--Enter the path to your Cardian folder in Windower. Replace any "\" with "/". Do not include file.
--Ex: D:/Windower4/addons/cardian/
addon_path = 'PLACE CARDIAN WINDOWER ADDON FOLDER PATH HERE'
--Spam filter tolerance. This number indicates how many messages to keep in the log for comparison
spam = 5
--Default settings for displaying linkshell messages, tells, and shouts
sh_linkshell = true
sh_tells = true
sh_shouts = true

return {
	shout_channel_id = function() return shout end,
	linkshell_channel_id = function() return linkshell end,
	tell_channel_id = function() return tell end,
	bot_token = function() return 'Bot ' .. token end,
	discardian_path = function() return addon_path end,
	admin = function() return admin end, 
	spam_tolerance = function() return spam end,
	show_linkshell = function() return sh_linkshell end,
	show_tells = function() return sh_tells end,
	show_shouts = function() return sh_shouts end,
}