module giftgiver2.bomb;

import giftgiver2.gameobject;
import giftgiver2.level;
import giftgiver2.game;
import giftgiver2.mathtypes;
import giftgiver2.weapon;
import giftgiver2.gfx;
import giftgiver2.options;
import giftgiver2.sprite;
import audio = giftgiver2.audio;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_audio;

import tango.math.Math;

class CBombWeapon : CWeapon
{
	this(CLevel level)
	{
		super(level);
		Sound = audio.Load("bomb.ogg");
		Cooldown = 0.5;
	}
	void Fire(SVector2D pos, float theta, SVector2D vel = SVector2D(0,0))
	{
		if(CanFire())
		{
			LastShotTime = Time;
			
			Level.PlaySound(Sound, pos);
			
			auto bomb = new CBomb(Level);
			bomb.SetPosition(pos.X, pos.Y, theta);
			bomb.SetVelocity(vel);
			Level.AddObject(bomb, false);
		}
	}
protected:
	ALLEGRO_SAMPLE* Sound;
}

class CBomb : CObject
{
	this(CLevel level)
	{
		super(level);
		Sprite = new CSprite("bomb");
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
			obj.OnDamage(110);
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
		Level.MakeExplosion(Location.Pos, 20);
	}
}
