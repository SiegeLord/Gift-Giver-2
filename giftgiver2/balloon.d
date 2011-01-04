module giftgiver2.balloon;

import giftgiver2.gameobject;
import giftgiver2.sprite;
import giftgiver2.level;
import giftgiver2.mathtypes;

class CBalloon : CObject
{
	this(CLevel level)
	{
		super(level);
		Sprite = new CSprite("balloon");
		Size = 10;
		Velocity.Y = -50;
		CheckGroundCollisions = false;
	}
	void Logic()
	{
		super.Logic();
		auto player = Level.GetPlayer();
		if(player)
		{
			auto sz1 = SVector2D(Size, Size);
			auto rect1 = SRect(GetPos() - sz1, GetPos() + sz1);
			auto sz2 = SVector2D(player.GetSize(), player.GetSize());
			auto rect2 = SRect(player.GetPos() - sz2, player.GetPos() + sz2);
			if(rect1.IntersectTest(rect2))
			{
				Dead = true;
				Level.AddScore(100);
				player.OnDamage(-50);
			}
		}
		if(GetPos().Y < -50)
			Dead = true;
	}
}
