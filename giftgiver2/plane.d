module giftgiver2.plane;

import giftgiver2.gameobject;
import giftgiver2.game;
import giftgiver2.mathtypes;
import giftgiver2.options;
import giftgiver2.level;
import giftgiver2.bullet;
import giftgiver2.weapon;
import giftgiver2.sprite;
import giftgiver2.damagetype;
import audio = giftgiver2.audio;
import giftgiver2.particleemitter;

import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro_audio;
import allegro5.allegro_primitives;
import allegro5.allegro;

class CPlane : CObject
{
	this(CLevel level)
	{
		super(level);
		AddWeapon(new CBulletWeapon(Level));
		Smoke = new CParticleEmitter("black_smoke", 20);
		Smoke.SpeedJitter = 10;
		HitSound = audio.Load("hit.ogg");
	}
	
	void Draw()
	{
		super.Draw();
		Smoke.Draw();
	}
	
	void Logic()
	{
		super.Logic();
		
		if(Dead)
			return;
		
		Smoke.Active = (GetHealth() <= 0.51);
		Smoke.SetPosition(GetPos());
		Smoke.Logic();
		
		auto house = Level.GetHouseAtPos(Location.Pos, Size);
		if(house)
		{
			OnDamage(110);
			house.OnDamage(110);
		}
		
		if(Burning)
		{
			Freefall = true;
			foreach(ref fire; FiringWeapon)
				fire = false;
		}
		
		if(Location.Pos.X < 100)
		{
			Location.Theta = PI - Location.Theta;
			Location.Pos.X = 100;
		}
		else if(Location.Pos.X > Width - 100)
		{
			Location.Theta = PI - Location.Theta;
			Location.Pos.X = Width - 100;
		}
		
		auto dir_vec = SVector2D(1, 0);
		dir_vec.Rotate(Location.Theta);
		
		if(Location.Pos.Y < 0)
			Freefall = true;
		
		if(!Burning)
		{
			foreach(ii, weapon; Weapons)
			{
				SVector2D fire_pos;
				if(ii == 0)
					fire_pos = GetPos() + dir_vec * 15;
				else
				{
					fire_pos = dir_vec * 15;
					fire_pos.MakeNormal();
					if(FlipImage)
						fire_pos = -fire_pos;
					fire_pos += GetPos();
				}
				if(FiringWeapon[ii])
				{
					weapon.Fire(fire_pos, GetTheta(), Velocity);
				}
			}
			
			float damage_factor = 1;
			if(GetHealth() <= 0.51)
				damage_factor = 0.75;
			
			if(!Freefall)
			{		
				Velocity = dir_vec * Throttle * damage_factor;
				
				Velocity += 10 * FixedDt * SVector2D(0, Gravity) * abs(dir_vec.CrossProduct(SVector2D(1, 0)));
				
				if(Throttle > 0)
				{
					if(FlapUp && !FlapDown)
					{
						Omega = -2 * damage_factor;
					}
					else if(FlapDown && !FlapUp)
					{
						Omega = 2 * damage_factor;
					}
					else
					{
						Omega = 0;
					}
				}				
			}
		}
		if(Freefall)
		{
			Throttle = 0;
			Velocity += FixedDt * SVector2D(0, Gravity);
			Velocity *= Friction;
			if(Omega == 0)
			{
				Omega = 2 * (rand.uniformR(2) * 2 - 1);
			}
		}
		
		if(Burning)
			Sprite = BurningSprite;
		else if(GetHealth() <= 0.5)
			Sprite = DamagedSprite;
		else
			Sprite = NormalSprite;
		
	}
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		super.OnDamage(damage, type);
		if(damage > 0)
		{
			Level.PlaySound(HitSound, GetPos());
		}
		if(Health <= 0)
			Burning = true;
	}
protected:
	void OnCollide()
	{
		super.OnCollide();
		Level.MakeExplosion(Location.Pos, 20);
		Dead = true;
		
		Smoke.Active = false;
		Level.AddDyingEmitter(Smoke);
	}
	void AddWeapon(CWeapon weap)
	{
		Weapons ~= weap;
		FiringWeapon ~= false;
	}
	
	void ThrottleUp()
	{
		if(Freefall)
		{
			if(rand.uniformR(100) > 80)
			{
				Freefall = false;
				Throttle += ThrottleStep;
			}
		}
		else
		{
			Throttle += ThrottleStep;
		}
		if(Throttle > ThrottleMax)
			Throttle = ThrottleMax;
	}
	void ThrottleDown()
	{
		Throttle -= ThrottleStep;
		if(Throttle < 0)
		{
			Freefall = true;
			Throttle = 0;
		}
	}

	CWeapon Weapons[];
	bool FiringWeapon[];
	
	bool Burning = false;
	float Throttle = 150;
	float ThrottleMax = 150;
	float ThrottleStep = 75;
	float LiftK = 1;
	bool FlapUp = false;
	bool FlapDown = false;
	bool Freefall = false;
	
	CSprite NormalSprite;
	CSprite DamagedSprite;
	CSprite BurningSprite;
	
	ALLEGRO_SAMPLE* HitSound;
	
	CParticleEmitter Smoke;
}

