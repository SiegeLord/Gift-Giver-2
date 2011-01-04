module giftgiver2.present;

import giftgiver2.gameobject;
import giftgiver2.level;
import giftgiver2.game;
import giftgiver2.mathtypes;
import giftgiver2.weapon;
import giftgiver2.gfx;
import giftgiver2.options;
import giftgiver2.sprite;
import giftgiver2.damagetype;
import audio = giftgiver2.audio;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_audio;

import tango.math.Math;

class CPresentWeapon : CWeapon
{
	this(CLevel level)
	{
		super(level);
		Cooldown = 0.5;
		Sound = audio.Load("bomb.ogg");
	}
	void Fire(SVector2D pos, float theta, SVector2D vel = SVector2D(0,0))
	{
		if(CanFire())
		{
			LastShotTime = Time;
			
			Level.PlaySound(Sound, pos);
			
			auto present = new CPresent(Level);
			present.SetPosition(pos.X, pos.Y, theta);
			present.SetVelocity(vel);
			Level.AddObject(present, false);
		}
	}
protected:
	ALLEGRO_SAMPLE* Sound;
}

class CPresent : CObject
{
	this(CLevel level)
	{
		super(level);
		Sprite = new CSprite("present");
	}
	
	void Logic()
	{
		super.Logic();
		
		Velocity += FixedDt * SVector2D(0, Gravity);
		Velocity *= Friction;
		
		if(Velocity.GetLengthSq() > 0.01)
			Location.Theta = atan2(Velocity.Y, Velocity.X);
		
		auto obj = Level.GetObjectAtBullet(OldLocation.Pos, Location.Pos, 10);
		if(obj)
		{
			OnCollide();
			obj.OnDamage(0, DamageType.Present);
		}
	}
	void Draw()
	{
		super.Draw();
	}
protected:
	void OnCollide()
	{
		Dead = true;
	}
}

