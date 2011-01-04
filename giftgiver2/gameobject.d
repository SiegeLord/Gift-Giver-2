module giftgiver2.gameobject;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.math.Math;

import giftgiver2.mathtypes;
import giftgiver2.damagetype;
import giftgiver2.game;
import giftgiver2.options;
import giftgiver2.level;
import giftgiver2.sprite;

struct SLocation
{
	SVector2D Pos;
	float Theta;
	
	void Interpolate(SLocation start, SLocation end, float alpha)
	{
		Pos = start.Pos + (end.Pos - start.Pos) * alpha;
		Theta = start.Theta + SubtractAngles(end.Theta, start.Theta) * alpha;
	}
}

class CObject
{
	this(CLevel level)
	{
		Level = level;
	}
	void Logic()
	{
		OldLocation = Location;	
		
		/*Velocity *= Friction;
		Velocity.Y += Gravity * FixedDt;*/
		Location.Pos += Velocity * FixedDt;
		Location.Theta += Omega * FixedDt;
		
		if(CheckGroundCollisions && Level.Collide(Location.Pos, Size))
		{
			Location.Pos = OldLocation.Pos;
			Velocity.Set(0,0);
			OnCollide();
		}
	}
	void Input(ALLEGRO_EVENT* event)
	{
		
	}
	void Draw()
	{
		DrawLocation.Interpolate(OldLocation, Location, PhysicsAlpha);
		if(Sprite)
		{
			auto bmp = Sprite.GetFrame();
			auto flip_flags = FlipImage ? ALLEGRO_FLIP_VERTICAL : 0;
			al_draw_rotated_bitmap(bmp, al_get_bitmap_width(bmp) / 2, al_get_bitmap_height(bmp) / 2, DrawLocation.Pos.X, DrawLocation.Pos.Y, DrawLocation.Theta, flip_flags);
		}
	}
	
	SVector2D GetPos()
	{
		return Location.Pos;
	}
	
	float GetTheta()
	{
		return Location.Theta;
	}
	
	void SetPosition(float x, float y, float theta)
	{
		Location.Pos.X = x;
		Location.Pos.Y = y;
		Location.Theta = theta;
		OldLocation = Location;
	}
	
	void SetVelocity(SVector2D vel)
	{
		Velocity = vel;
	}
	
	void SetOmega(float omega)
	{
		Omega = omega;
	}
	
	bool IsDead()
	{
		return Dead;
	}
	
	int GetSize()
	{
		return Size;
	}
	
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		Health -= damage;
		if(Health > MaxHealth)
			Health = MaxHealth;
	}
	
	float GetHealth()
	{
		return Health / MaxHealth;
	}
protected:
	void OnCollide()
	{
		
	}
	
	SLocation Location;
	SLocation OldLocation;
	SLocation DrawLocation;
	
	CLevel Level;
	
	CSprite Sprite;
	
	SVector2D Velocity;
	float Omega = 0;
	
	bool FlipImage = false;
	float Friction = 0.99f;
	int Size = 1;
	bool Dead = false;
	bool Burning = false;
	float Health = 100;
	float MaxHealth = 100;
	bool CheckGroundCollisions = true;
}
