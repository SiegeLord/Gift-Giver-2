module giftgiver2.particleemitter;

import giftgiver2.sprite;
import giftgiver2.mathtypes;
import giftgiver2.game;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.math.random.Random;
import tango.io.Stdout;
import Array = tango.core.Array;

struct SParticle
{
	SVector2D Position;
	SVector2D Velocity;
	float Life;
	bool Alive()
	{
		return Life > 0;
	}
}

class CParticleEmitter
{
	this(char[] name, int num_particles)
	{
		Sprite = new CSprite(name);
		Particles.length = num_particles;
		foreach(ref particle; Particles)
		{
			particle.Life = -1;
		}
	}
	
	void Logic()
	{
		foreach(ref particle; Particles)
		{
			particle.Life -= FixedDt;
			particle.Position += particle.Velocity * FixedDt;
			SpawnTimer -= FixedDt;
			
			if(!particle.Alive() && Active && (SpawnTimer <= 0))
			{
				particle.Life = Life;
				particle.Position = Position;
				particle.Velocity = InitialVelocity + SVector2D(rand.uniformR2(-SpeedJitter, SpeedJitter), rand.uniformR2(-SpeedJitter, SpeedJitter));
				
				SpawnTimer = Life;// / cast(float)Particles.length;
			}
		}
	}
	
	void Draw()
	{
		foreach(particle; Particles)
		{
			if(particle.Alive())
			{
				auto bmp = Sprite.GetFrame(cast(int)((1 - particle.Life / Life) * Sprite.GetNumFrames()));
				auto hw = al_get_bitmap_width(bmp) / 2;
				auto hh = al_get_bitmap_height(bmp) / 2;
				al_draw_bitmap(bmp, particle.Position.X - hw, particle.Position.Y - hh, 0);
			}
		}
	}
	
	void SetPosition(SVector2D pos)
	{
		Position = pos;
	}
	
	int GetNumActiveParticles()
	{
		bool alive(SParticle part)
		{
			return part.Alive();
		}
		return Array.countIf(Particles, &alive);
	}
	
	SVector2D InitialVelocity;
	float SpeedJitter = 50;
	bool Active = true;
	float Life = 1;
private:
	float SpawnTimer = 0;
	SVector2D Position;
	SParticle[] Particles;
	CSprite Sprite;
}
