module giftgiver2.weapon;

import giftgiver2.game;
import giftgiver2.level;
import giftgiver2.mathtypes;

class CWeapon
{
	this(CLevel level)
	{
		Level = level;
	}
	void Fire(SVector2D pos, float theta, SVector2D vel = SVector2D(0,0))
	{
		
	}
protected:
	CLevel Level;
	bool CanFire()
	{
		return (Time - LastShotTime) > Cooldown;
	}
	float Cooldown = 0.25;
	float LastShotTime = -1;
}
