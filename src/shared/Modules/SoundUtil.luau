local SoundUtil = {}

function SoundUtil.PlaySoundAtLocation(a,pos)
	local p = Instance.new("Part")
	p.CanCollide,p.CanTouch,p.CanQuery = 0,0,0
	p.Transparency,p.Anchored = 1,1
	p.Name = "AudioHolder"
	p.Size,p.Position = Vector3.new(0.1,0.1,0.1),pos
	local a_ = a:Clone()
	a_.Parent = p
	p.Parent = workspace
	a_:Play()
	game.Debris:AddItem(p,a.TimeLength)
end

return SoundUtil