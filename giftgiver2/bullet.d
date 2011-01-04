module giftgiver2.bullet;

import giftgiver2.gameobject;
import giftgiver2.level;
import giftgiver2.game;
import giftgiver2.mathtypes;
import giftgiver2.weapon;
import giftgiver2.gfx;
import audio = giftgiver2.audio;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_audio;

class CBulletWeapon : CWeapon
{
	this(CLevel level)
	{
		super(level);
		Sound = audio.Load("shoot.ogg");
		Cooldown = 0.18;
	}
	void Fire(SVector2D pos, float theta, SVector2D vel = SVector2D(0,0))
	{
		if(CanFire())
		{
			LastShotTime = Time;
			
			Level.PlaySound(Sound, pos);
			
			auto bullet = new CBullet(Level);
			bullet.SetPosition(pos.X, pos.Y, theta);
			Level.AddObject(bullet, false);
		}
	}
protected:
	ALLEGRO_SAMPLE* Sound;
}

class CBullet : CObject
{
	this(CLevel level)
	{
		super(level);
		CreationTime = Time;
	}
	
	void Logic()
	{
		super.Logic();
		auto dir_vec = SVector2D(1, 0);
		dir_vec.Rotate(Location.Theta);
		
		Velocity = dir_vec * Speed;
		
		auto obj = Level.GetObjectAtBullet(OldLocation.Pos, Location.Pos, 10);
		if(obj)
		{
			OnCollide();
			obj.OnDamage(25);
		}
		
		if(Time - CreationTime > Lifetime)
			OnCollide();
	}
	void Draw()
	{
		super.Draw();
		auto dir_vec = SVector2D(15, 0);
		dir_vec.Rotate(DrawLocation.Theta);
		
		auto start = DrawLocation.Pos;
		auto end = start + dir_vec;
		DrawGradientLine(end, start, ALLEGRO_COLOR(1, 1, 0, 1), ALLEGRO_COLOR(0, 0, 0, 0));
		al_draw_filled_circle(end.X - 0.5, end.Y - 0.5, 1.5, ColorFixer(ALLEGRO_COLOR(1, 1, 0, 1)));
	}
protected:
	void OnCollide()
	{
		Dead = true;
	}
	
	float Speed = 400;
	float Lifetime = 1.5;
	float CreationTime = 0;
}
