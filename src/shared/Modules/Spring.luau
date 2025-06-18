local Spring = {}

function Spring.new(start, target, speed, damping)
	local isVector = typeof(start) == "Vector3"
	local data = {
		pPos = start,
		pVel = isVector and Vector3.new() or 0,
		equilibriumPos = damping and target or (isVector and Vector3.new() or 0),
		angularFrequency = damping and speed or target,
		dampingRatio = damping or speed,
	} :: SpringType

	setmetatable(data, { __index = Spring })

	return data
end

function Spring:SetPosition(p)
	self.pPos = p
end

function Spring:IncrementPosition(p)
	self.pPos = self.pPos + p
end

function Spring:SetSpeed(s)
	self.angularFrequency = s
end

function Spring:SetDamping(d)
	self.dampingRatio = d
end

function Spring:SetTarget(t)
	self.equilibriumPos = t
end

function Spring:Accelerate(v)
	self.pVel = self.pVel + v
end

function Spring:Solve(deltaTime)
	local pPos = self.pPos
	local pVel = self.pVel
	local equilibriumPos = self.equilibriumPos
	local angularFrequency = self.angularFrequency
	local dampingRatio = self.dampingRatio
	local initialPos = pPos - equilibriumPos
	local initialVel = pVel

	local epsilon = 0.0001

	if dampingRatio > 1 + epsilon then
		local za = -angularFrequency * dampingRatio
		local zb = angularFrequency * ((dampingRatio * dampingRatio - 1) ^ 0.5)
		local z1 = za - zb
		local z2 = za + zb
		local expTerm1 = math.exp(z1 * deltaTime)
		local expTerm2 = math.exp(z2 * deltaTime)

		local c1 = (initialVel - initialPos * z2) / (-2 * zb)
		local c2 = initialPos - c1
		pPos = equilibriumPos + c1 * expTerm1 + c2 * expTerm2
		pVel = c1 * z1 * expTerm1 + c2 * z2 * expTerm2

		self.pPos = pPos
		self.pVel = pVel
		return pPos, pVel
	elseif dampingRatio > 1 - epsilon then
		local expTerm = math.exp(-angularFrequency * deltaTime)

		local c1 = initialVel + angularFrequency * initialPos
		local c2 = initialPos
		local c3 = (c1 * deltaTime + c2) * expTerm
		pPos = equilibriumPos + c3
		pVel = (c1 * expTerm) - (c3 * angularFrequency)

		self.pPos = pPos
		self.pVel = pVel
		return pPos, pVel
	else
		local omegaZeta = angularFrequency * dampingRatio
		local alpha = angularFrequency * ((1 - dampingRatio * dampingRatio) ^ 0.5)
		local expTerm = math.exp(-omegaZeta * deltaTime)
		local cosTerm = math.cos(alpha * deltaTime)
		local sinTerm = math.sin(alpha * deltaTime)

		local c1 = initialPos
		local c2 = (initialVel + omegaZeta * initialPos) / alpha
		pPos = equilibriumPos + expTerm * (c1 * cosTerm + c2 * sinTerm)
		pVel = -expTerm
			* (
				(c1 * omegaZeta - c2 * alpha) * cosTerm
				+ (c1 * alpha + c2 * omegaZeta) * sinTerm
			)

		self.pPos = pPos
		self.pVel = pVel
		return pPos, pVel
	end
end

export type SpringType = {
	pPos: Vector3 | number,
	pVel: Vector3 | number,
	equilibriumPos: Vector3 | number,
	angularFrequency: number,
	dampingRatio: number,

	SetPosition: (self: SpringType, p: Vector3 | number) -> (),
	IncrementPosition: (self: SpringType, p: Vector3 | number) -> (),
	SetSpeed: (self: SpringType, s: number) -> (),
	SetDamping: (self: SpringType, d: number) -> (),
	SetTarget: (self: SpringType, t: Vector3 | number) -> (),
	Accelerate: (self: SpringType, v: Vector3 | number) -> (),
	Solve: (self: SpringType, deltaTime: number) -> (number),
}

return Spring
