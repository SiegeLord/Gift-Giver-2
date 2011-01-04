module giftgiver2.base;

import giftgiver2.enemyplane;
import giftgiver2.mathtypes;
import giftgiver2.level;
import giftgiver2.game;

import tango.core.Array;
import tango.io.Stdout;
import tango.math.Math;

class CBase
{
	this(CLevel level, SVector2D loc, int num_planes = 1)
	{
		Location = loc;
		Level = level;
		NumPlanes = num_planes;
	}
	void Logic()
	{
		bool is_dead(CEnemyPlane obj)
		{
			return obj.IsDead();
		}
		
		Planes.length = removeIf(Planes, &is_dead);
		
		WantAPlane = Planes.length < NumPlanes;
		if(WantAPlane && Spawn)
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
		
		/*for(int ii = Planes.length; ii < NumPlanes; ii++)
		{
			CreatePlane();
		}*/
	}
	void OnLevelComplete()
	{
		Spawn = false;
		foreach(plane; Planes)
			plane.OnDamage(1000);
	}
protected:
	void CreatePlane()
	{
		auto plane = new CEnemyPlane(Level);
		plane.SetBaseLocation(SVector2D(Location.X, 256));
		plane.SetPosition(Location.X, Location.Y, -PI / 2);
		Level.AddObject(plane);
		Planes ~= plane;
	}
	SVector2D Location;
	CLevel Level;
	int NumPlanes = 1;
	CEnemyPlane[] Planes;
	bool WantAPlane = false;
	float RespawnDelay = 5;
	float RespawnTime = 0;
	bool Spawn = true;
}
