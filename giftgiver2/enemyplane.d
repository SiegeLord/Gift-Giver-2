module giftgiver2.enemyplane;

import tango.math.Math;
import tango.math.random.Random;

import giftgiver2.plane;
import giftgiver2.sprite;
import giftgiver2.level;
import giftgiver2.mathtypes;
import giftgiver2.gameobject;
import giftgiver2.damagetype;
import giftgiver2.game;

class CEnemyPlane : CPlane
{
	this(CLevel level)
	{
		super(level);
		
		NormalSprite = new CSprite("badplane");
		DamagedSprite = new CSprite("badplane_dam");
		BurningSprite = new CSprite("badplane_burn");
		
		Size = 6;
	}
	void Logic()
	{
		super.Logic();
		
		if(rand.uniformR(30) == 4)
			ThrottleUp();
		
		if(Freefall)
			return;
			
		auto dir_vec = SVector2D(1, 0);
		dir_vec.Rotate(Location.Theta);
		
		if(dir_vec.X < 0)
			FlipImage = true;
		else
			FlipImage = false;
		
		FlapDown = FlapUp = false;
		
		if(GetPos().Y > Level.GetGroundHeight(cast(int)GetPos().X) - 80)
		{
			FiringWeapon[0] = false;
			if(dir_vec.X < 0)
				FlapDown = true;
			else
				FlapUp = true;
		}
		else
		{
			auto player = Level.GetPlayer();
			if(player)
			{
				auto target = BaseLocation;
				auto target_is_player = false;
				if((player.GetPos() - BaseLocation).GetLengthSq() < PatrolDistance * PatrolDistance)
				{
					target = player.GetPos();
					target_is_player = true;
				}
				auto target_vec = target - GetPos();
				auto len = target_vec.GetLength();
				
				auto cross = dir_vec.CrossProduct(target_vec) / len;
				auto dot = dir_vec.DotProduct(target_vec) / len;
				
				bool flip = false;
				if(len < 100 && dot > 0)
				{
					flip = true;
				}
				
				bool want_to_fire = false;
				
				if(dot > 0 && abs(cross) < 0.05f)
				{
					if(target_is_player)
						want_to_fire = true;
					else
						want_to_fire = false;
					FlapDown = FlapDown = false;
				}
				else if(cross < 0)
				{
					want_to_fire = false;
					FlapUp = !flip;
					FlapDown = flip;
				}
				else
				{
					want_to_fire = false;
					FlapUp = flip;
					FlapDown = !flip;
				}
				
				if(want_to_fire && ShotsLeft > 0)
				{
					FiringWeapon[0] = true;
					ShotsLeft -= FixedDt;
				}
				else
					FiringWeapon[0] = false;
				
				if(ShotsLeft <= 0)
				{
					if(Cooldown <= 0)
					{
						Cooldown = 1.0 - 0.15 * Difficulty;
					}
					Cooldown -= FixedDt;
					if(Cooldown < 0)
					{
						Cooldown = 0;
						ShotsLeft = 0.5;
					}
				}
			}
		}
	}
	
	void SetBaseLocation(SVector2D base_loc)
	{
		BaseLocation = base_loc;
	}
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		super.OnDamage(damage, type);
		if(Health <= 0)
		{
			Level.AddScore(Score);
			Score = 0;
		}
	}
	void OnBaseDead()
	{
		PatrolDistance = 9999;
	}
protected:
	void OnCollide()
	{
		super.OnCollide();
		Level.AddScore(Score);
		Score = 0;
	}
	SVector2D BaseLocation;
	float PatrolDistance = 1024;
	int Score = 100;
	float Cooldown = 0;
	float ShotsLeft = 0.5;
}
