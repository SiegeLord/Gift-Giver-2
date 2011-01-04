module giftgiver2.badhouse;

import giftgiver2.enemyplane;
import giftgiver2.gameobject;
import giftgiver2.sprite;
import giftgiver2.level;
import giftgiver2.damagetype;
import giftgiver2.game;
import giftgiver2.mathtypes;

import tango.core.Array;
import tango.io.Stdout;
import tango.math.Math;

class CBadHouse : CObject
{
	this(CLevel level, int num_planes = 1)
	{
		super(level);
		Sprite = new CSprite("badhouse");
		Size = 15;
		CheckGroundCollisions = false;
		NumPlanes = num_planes;
	}
	
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		super.OnDamage(damage, type);
		if(Health < 0)
		{
			Dead = true;
			if(Score)
			{
				Level.AddScore(Score);
				Score = 0;
				Level.OnBadHouseDestroyed();
				Level.MakeExplosion(GetPos(), 40);
				foreach(plane; Planes)
					plane.OnBaseDead();
			}
		}
		if(Health < MaxHealth)
			Health = MaxHealth;
	}
	
	void Logic()
	{
		super.Logic();
		
		bool is_dead(CEnemyPlane obj)
		{
			return obj.IsDead();
		}
		
		Planes.length = removeIf(Planes, &is_dead);
		
		WantAPlane = Planes.length < NumPlanes;
		if(WantAPlane)
		{
			if(RespawnTime < 0)
			{
				RespawnTime = Time + RespawnDelay;
			}
			else if(Time > RespawnTime)
			{
				CreatePlane();
				RespawnTime = -1;
			}
		}
	}
protected:
	void CreatePlane()
	{
		auto plane = new CEnemyPlane(Level);
		plane.SetBaseLocation(SVector2D(GetPos().X, 256));
		plane.SetPosition(GetPos().X, GetPos().Y - 24, -PI / 2);
		Level.AddObject(plane);
		Planes ~= plane;
	}
	
	int NumPlanes = 1;
	CEnemyPlane[] Planes;
	bool WantAPlane = false;
	float RespawnDelay = 5;
	float RespawnTime = 0;
	
	int Score = 200;
}
