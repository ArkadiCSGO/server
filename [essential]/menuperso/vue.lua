--[[
local	vuedefault = 1

AddEventHandler('onClientMapStart', function()

	vuedefault = 1


end)

local keyPressed = false

local once = false

Citizen.CreateThread(function()

	while true do

		Wait(0)

		if once then

			once = false

			SetFollowPedCamViewMode(1)

		end


		while IsControlPressed(1, 47) and keyPressed do

			Wait(0)

		end

		if IsControlPressed(1, 47) and not keyPressed then

			keyPressed = true

			vuedefault = vuedefault + 1

			if vuedefault > 3 then

				vuedefault = 1

			end



			if vuedefault == 1 then

				SetFollowPedCamViewMode(1)
				SetFollowVehicleCamViewMode(1)

			elseif vuedefault == 2 then

				SetFollowPedCamViewMode(2)
				SetFollowVehicleCamViewMode(2)

			elseif vuedefault == 3 then

				SetFollowPedCamViewMode(4)
				SetFollowVehicleCamViewMode(4)

			end

			Wait(0)

		elseif not IsControlPressed(1, 47) and keyPressed then

			keyPressed = false

		end

	end

end)

]]--