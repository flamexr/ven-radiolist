local PlayerServerID = GetPlayerServerId(PlayerId())
local PlayersInRadio = {}
local firstTimeEventGetsTriggered = true
local RadioChannelsName = {}

RegisterNetEvent('ven-RadioList:Client:SyncRadioChannelPlayers')
AddEventHandler('ven-RadioList:Client:SyncRadioChannelPlayers', function(src, RadioChannelToJoin, PlayersInRadioChannel)
	if firstTimeEventGetsTriggered then
		for i, v in pairs(Config.RadioChannelsWithName) do
			local frequency = tonumber(i)
			local minFrequency, maxFrequency = frequency, frequency + 1
			for index = minFrequency, maxFrequency + 0.0, 0.01 do
				RadioChannelsName[tostring(index)] = tostring(v)
			end
			if frequency ~= 0 then
				RadioChannelsName[tostring(frequency)] = tostring(v)
			end
		end	
		firstTimeEventGetsTriggered = false
	end
	PlayersInRadio = PlayersInRadioChannel
	if src == PlayerServerID then
		if RadioChannelToJoin > 0 then
			local radioChannelToJoin = tostring(RadioChannelToJoin)
			if RadioChannelsName[radioChannelToJoin] then
				HideTheRadioList()
				for index, player in pairs(PlayersInRadio) do
					local playerId = player.Source
					local playerName = player.Name .. " (" .. playerId .. ")" -- Müşteri kimliğini parantez içinde ekle
					if playerId ~= src then
						SendNUIMessage({ radioId = playerId, radioName = playerName, channel = RadioChannelsName[radioChannelToJoin] })
					else
						SendNUIMessage({ radioId = src, radioName = playerName, channel = RadioChannelsName[radioChannelToJoin], self = true })
					end
				end
				ResetTheRadioList()
			else
				HideTheRadioList()
				for index, player in pairs(PlayersInRadio) do
					local playerId = player.Source
					local playerName = player.Name .. " (" .. playerId .. ")"
					if playerId ~= src then
						SendNUIMessage({ radioId = playerId, radioName = playerName, channel = radioChannelToJoin })
					else
						SendNUIMessage({ radioId = src, radioName = playerName, channel = radioChannelToJoin, self = true })
					end
				end
				ResetTheRadioList()
			end
		else
			ResetTheRadioList()
			HideTheRadioList()
		end
	elseif src ~= PlayerServerID then
		if RadioChannelToJoin > 0 then
			local radioChannelToJoin = tostring(RadioChannelToJoin)
			if RadioChannelsName[radioChannelToJoin] then
				local playerName = PlayersInRadio[src].Name .. " (" .. src .. ")"
				SendNUIMessage({ radioId = src, radioName = playerName, channel = RadioChannelsName[radioChannelToJoin] })
				ResetTheRadioList()
			else
				local playerName = PlayersInRadio[src].Name .. " (" .. src .. ")"
				SendNUIMessage({ radioId = src, radioName = playerName, channel = radioChannelToJoin })
			end
		else
			SendNUIMessage({ radioId = src })
		end
	end
end)

RegisterNetEvent('pma-voice:setTalkingOnRadio')
AddEventHandler('pma-voice:setTalkingOnRadio', function(src, talkingState)
	SendNUIMessage({ radioId = src, radioTalking = talkingState })
end)

RegisterNetEvent('pma-voice:radioActive')
AddEventHandler('pma-voice:radioActive', function(talkingState)
	SendNUIMessage({ radioId = PlayerServerID, radioTalking = talkingState })
end)

RegisterNetEvent('ven-RadioList:Client:DisconnectPlayerCurrentChannel')
AddEventHandler('ven-RadioList:Client:DisconnectPlayerCurrentChannel', function()
	ResetTheRadioList()
	HideTheRadioList()
end)

function ResetTheRadioList()
	PlayersInRadio = {}
end

function HideTheRadioList()
	SendNUIMessage({ clearRadioList = true })
end

if Config.LetPlayersChangeVisibilityOfRadioList then
	local visibility = true
	RegisterCommand(Config.RadioListVisibilityCommand, function()
		visibility = not visibility
		SendNUIMessage({ changeVisibility = true, visible = visibility })
	end)
	TriggerEvent("chat:addSuggestion", "/"..Config.RadioListVisibilityCommand, "Radyo Listesini Göster/Gizle")
end

if Config.LetPlayersSetTheirOwnNameInRadio then
	TriggerEvent("chat:addSuggestion", "/"..Config.RadioListChangeNameCommand, "Radyo listesinde gösterilecek isminizi özelleştirin", { { name = 'özelleştirilmiş isim', help = "Radyo listesinde gösterilecek isminizi girin" } })
end
