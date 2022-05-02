
local Keybinds = require(script.Parent.Parent.Input.Keybinds)
--local Gameplay = require(script.Parent.Parent:WaitForChild("gameplayer"))
local Utilities = require(game:GetService("ReplicatedStorage").Utilities)
local Input = require(script.Parent.Parent:WaitForChild("Input"))
local KeyBinds = require(script.Parent.Parent:WaitForChild("Input"):WaitForChild("Keybinds"))
local keyBindImages = require(script.Parent.Parent:WaitForChild("Input"):WaitForChild("Images"))
local Crystals = {}
local player = game:GetService("Players")


local pets = require(game:GetService("ReplicatedStorage").comms.resubales.pets.Pets.Pets)
local Rariety = require(game:GetService("ReplicatedStorage").comms.resubales.pets.Pets.Rarities)
local shake = Utilities.CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shake_cf)
	workspace.Camera.CFrame = workspace.Camera.CFrame * shake_cf
end)


function CrystalsAnimate(crystal_model)


	workspace.Camera.CameraType = Enum.CameraType.Scriptable
	local new_cf = CFrame.new(workspace.Camera.CFrame:PointToWorldSpace(Vector3.new(0,0,-3)), crystal_model.Main.CFrame.p)
	Utilities.Tween.TweenProperties(workspace.Camera, {CFrame = new_cf;FieldOfView=45;}, .5, "Quint", "Out", true)


	shake:Shake(Utilities.CameraShaker.Presets.Vibration)
	shake:Start()

	local cloned_crystal = crystal_model.Main:Clone()
	cloned_crystal.Parent = workspace
	crystal_model.Main.Transparency = 1;

	Utilities.Tween.TweenProperties(cloned_crystal, {Transparency = 0.5;}, 2, "Quint", "Out", true)

	shake:Stop()

	spawn(function()
		if crystal_model:FindFirstChild("DisplayPet") then
			Crystals.latest_display_pet = crystal_model.DisplayPet
			crystal_model.DisplayPet.Parent = nil
		end
		if Utilities.Performance:IsBetter("B") then
			Utilities.Physics.BreakPartPieces(cloned_crystal, 4, 5, 1, true, Utilities.Tween.TweenProperties)
			shake:Shake(Utilities.CameraShaker.Presets.Explosion)
			shake:Start()
		else
			cloned_crystal:Destroy()
		end
	end)


end


function Opened(pet_name, crystal_model)
	--Gameplay:ToggleControls(false)
	local pet_data = pets[pet_name]
	local pet_rarity = pet_data.Rarity
	local rarity_data = Rariety[pet_rarity]

	

	pcall(function()
		crystal_model.Display.Enabled = false
	end)

	local original_cf = workspace.Camera.CFrame

	print(pet_name)

	local cloned_pet = game:GetService("ReplicatedStorage").Cloneables.Pets:WaitForChild(pet_name):Clone()

	CrystalsAnimate(crystal_model)

	cloned_pet:SetPrimaryPartCFrame(CFrame.new(crystal_model.Main.CFrame.p, workspace.Camera.CFrame.p))
	cloned_pet.PrimaryPart.Anchored = true 
	cloned_pet.Parent = workspace

	--Crystals.UI.Enabled = true

	shake:Stop()

	local unit = (workspace.Camera.CFrame.p-cloned_pet.PrimaryPart.CFrame.p).Unit
	local new_cf = CFrame.new((cloned_pet.PrimaryPart.CFrame.p + (Vector3.new(5,5,5) * unit)), cloned_pet.PrimaryPart.CFrame.p)
	Utilities.Tween.TweenProperties(workspace.Camera, {CFrame=new_cf}, .3, "Quint", "Out", true)

	Crystals.hb = {
		game:GetService("RunService").Heartbeat:Connect(function()
			workspace.Camera.CFrame = workspace.Camera.CFrame:Lerp(CFrame.new(workspace.Camera.CFrame.p,cloned_pet.PrimaryPart.CFrame.p),.01)
		end)
	}
	
	local shockAnimation = Instance.new("Animation")
	shockAnimation.AnimationId = "rbxassetid://9519777118"
	local Animator = cloned_pet.AnimationController.Animator

	local shockAnimationTrack = Animator:LoadAnimation(shockAnimation)
	shockAnimationTrack.Priority = Enum.AnimationPriority.Action
	shockAnimationTrack.Looped = false
	
	shockAnimationTrack:Play()
	local bindable = Instance.new("BindableEvent")

	Keybinds.Confirm.Enabled = true
	

	bindable.Event:Wait()
	bindable:Destroy()

	--Crystals.Cleanup(crystal_model, cloned_pet, original_cf)
end


function CrystalsTrigger(name,  instance)

	if Crystals.can_open then
		Crystals.can_open = false

		local can_unlock = true
		if can_unlock then
			local crystal_data = game:GetService("ReplicatedStorage").comms.resubales.pets.Pets.Crystals.Crystals[name]
			if crystal_data then
				local prices = crystal_data.Prices

				if prices.Robux~=nil then
					game:GetService("MarketplaceService"):PromptProductPurchase(player.LocalPlayer, prices.Robux) -- prices.Robux == ProductId
					local _,_,purchased = game:GetService("MarketplaceService").PromptProductPurchaseFinished:Wait()
					if not purchased then
						Crystals.can_open = true
					end
					return false; -- server will handle the rest
				else
					for currency,amt in pairs(prices) do
						local c_val = 8000
						if not c_val or c_val.Value < amt then


							
							Crystals.can_open = true
							return false; -- cannot afford.
						end
					end
				end
			Opened("Kitten", game.Workspace.Areas.Plains.Common)
			end
			
		end
	end
end


local plainChest  = workspace:WaitForChild("Areas").Plains.Common
wait(8)

CrystalsAnimate(plainChest)
