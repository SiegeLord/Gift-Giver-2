module giftgiver2.nicehouse;

import giftgiver2.gameobject;
import giftgiver2.sprite;
import giftgiver2.level;
import giftgiver2.balloon;
import giftgiver2.damagetype;
import giftgiver2.particleemitter;
import giftgiver2.mathtypes;
import audio = giftgiver2.audio;

import allegro5.allegro_audio;

class CNiceHouse : CObject
{
	this(CLevel level)
	{
		super(level);
		Sprite = new CSprite("nicehouse");
		HappySprite = new CSprite("nicehouse_happy");
		Size = 15;
		CheckGroundCollisions = false;
		
		Smoke = new CParticleEmitter("white_smoke", 10);
		Smoke.SpeedJitter = 10;
		Smoke.InitialVelocity.Set(10, -60);
		Smoke.Active = false;
		
		PresentSound = audio.Load("present_hit.ogg");
	}
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		super.OnDamage(damage, type);
		if(Health < 0 && Score)
		{
			Dead = true;
			Level.AddScore(Score);
			Score = 0;
			Level.MakeExplosion(GetPos(), 40);
			
			Smoke.Active = false;
			Level.AddDyingEmitter(Smoke);
		}
		if(Health < MaxHealth)
			Health = MaxHealth;
		if(type == DamageType.Present && !LaunchedBalloon)
		{
			auto balloon = new CBalloon(Level);
			balloon.SetPosition(GetPos().X, GetPos().Y - 10, 0);
			Level.AddObject(balloon, false);
			LaunchedBalloon = true;
			Sprite = HappySprite;
			Level.AddScore(50);
			
			Level.PlaySound(PresentSound, GetPos());
			
			Smoke.Active = true;
			Smoke.SetPosition(GetPos() - SVector2D(20, 30));
		}
	}
	void Logic()
	{
		super.Logic();
		Smoke.Logic();
	}
	void Draw()
	{
		super.Draw();
		Smoke.Draw();
	}
protected:
	ALLEGRO_SAMPLE* PresentSound;
	CSprite HappySprite;
	bool LaunchedBalloon = false;
	int Score = -150;
	CParticleEmitter Smoke;
}
