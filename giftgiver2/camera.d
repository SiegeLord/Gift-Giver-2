module giftgiver2.camera;

import tango.io.Stdout;

import giftgiver2.mathtypes;
import giftgiver2.gfx;
import giftgiver2.game;
import giftgiver2.gameobject;

import allegro5.allegro;


class CCamera
{
	this(SRect world_bbox, SVector2D max_dev, float speed)
	{
		MaxDev = max_dev;
		Speed = speed;
		WorldBBox = world_bbox;
		ScreenBox.Set(0, 0, ViewX, ViewY);
	}
	
	void Logic()
	{
		OldPos = Pos;
		if(FollowObject)
		{		
			auto dev = FollowObject.GetPos() - (Pos + SVector2D(ViewX, ViewY) / 2);
			
			if(dev.X > MaxDev.X)
			{
				if(dev.X - MaxDev.X < Speed)
					Pos.X += dev.X - MaxDev.X;
				else
					Pos.X += Speed;
			}
			if(dev.X < -MaxDev.X)
			{
				if(dev.X + MaxDev.X > -Speed)
					Pos.X -= -(dev.X + MaxDev.X);
				else
					Pos.X -= Speed;
			}
			if(dev.Y > MaxDev.Y)
			{
				if(dev.Y - MaxDev.Y < Speed)
					Pos.Y += dev.Y - MaxDev.Y;
				else
					Pos.Y += Speed;
			}
			if(dev.Y < -MaxDev.Y)
			{
				if(dev.Y + MaxDev.Y > -Speed)
					Pos.Y -= -(dev.Y + MaxDev.Y);
				else
					Pos.Y -= Speed;
			}
		}

		SnapToBBox();
	}
	
	void CenterOnObject()
	{
		if(!FollowObject)
			return;
		Pos = FollowObject.GetPos() - SVector2D(ViewX, ViewY) / 2;
		SnapToBBox();
	}

	void SnapToBBox()
	{
		SRect box = WorldBBox;
		box.Min -= ScreenBox.Min;
		box.Max -= ScreenBox.Max;
		
		if(Pos.X < box.Min.X)
			Pos.X = box.Min.X;
		if(Pos.X > box.Max.X)
			Pos.X = box.Max.X;
		if(Pos.Y < box.Min.Y)
			Pos.Y = box.Min.Y;
		if(Pos.Y > box.Max.Y)
			Pos.Y = box.Max.Y;
	}
	
	void SetPos(SVector2D pos)
	{
		OldPos = Pos = pos;
	}
	
	SVector2D GetPos()
	{
		return Pos;
	}

	void Draw()
	{
		DrawPos = OldPos + (Pos - OldPos) * PhysicsAlpha;
		ALLEGRO_TRANSFORM trans = GetTransform();
		al_translate_transform(&trans, -DrawPos.X * GetScale(), -DrawPos.Y * GetScale()); 
		al_use_transform(&trans);
	}
	
	void SetFollowObject(CObject obj)
	{
		FollowObject = obj;
	}
private:
	SVector2D Pos;
	SVector2D OldPos;
	SVector2D DrawPos;
	
	CObject FollowObject;
	SVector2D MaxDev;
	float Speed = 1;
	SRect WorldBBox;
	SRect ScreenBox;
}
