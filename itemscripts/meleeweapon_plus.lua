require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/itemscripts/weapon_plus.lua"

function init()

  self.weapon = Weapon:new()

  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", config.getParameter("directives", ""))
  animator.setGlobalTag("bladeDirectives", config.getParameter("bladeDirectives", ""))
  self.weapon:addTransformationGroup("weapon", {0,0}, math.rad(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

  local primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(primaryAbility)

  local secondaryAttack = getAltAbility()
  if secondaryAttack then
    self.weapon:addAbility(secondaryAttack)
  end

  self.weapon:init()

end

function update(dt, fireMode, shiftHeld)
  self.weapon:update(dt, fireMode, shiftHeld)
end

function uninit()
  self.weapon:uninit()
end
