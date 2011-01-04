module giftgiver2.explosion;

import giftgiver2.gameobject;
import giftgiver2.sprite;
import giftgiver2.level;
import giftgiver2.game;

class CExplosion : CObject
{
	this(CLevel level)
	{
		super(level);
		Sprite = new CSprite("explosion");
		Size = 1;
		CheckGroundCollisions = false;
		CreationTime = Time;
		Sprite.SetFrame(0);
	}
	void Logic()
	{
		if(Time - CreationTime > 0.24)
			Dead = true;
	}
protected:
	float CreationTime = 0;
}
