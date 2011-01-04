module giftgiver2.player;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.bitmap;
import allegro5.allegro_audio;

import tango.io.Stdout;
import tango.math.Math;

import giftgiver2.sprite;
import giftgiver2.plane;
import giftgiver2.game;
import giftgiver2.mathtypes;
import giftgiver2.level;
import giftgiver2.bomb;
import giftgiver2.present;
import giftgiver2.gameobject;
import giftgiver2.damagetype;
import audio = giftgiver2.audio;


class CPlayer : CPlane
{
	this(CLevel level)
	{
		super(level);
		
		NormalSprite = new CSprite("santa");
		DamagedSprite = new CSprite("santa_dam");
		BurningSprite = new CSprite("santa_burn");
		Victory = new CSprite("victory");
		Sprite = NormalSprite;
		
		HeartSound = audio.Load("heart.ogg");
		
		Size = 4;
		
		AddWeapon(new CBombWeapon(Level));
		AddWeapon(new CPresentWeapon(Level));
	}
	void Input(ALLEGRO_EVENT* event)
	{
		if(Burning || VictoryParade)
			return;
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_DOWN:
					{
						FlipImage = !FlipImage;
						break;
					}
					case ALLEGRO_KEY_RIGHT:
					{
						FlapDown = true;
						break;
					}
					case ALLEGRO_KEY_LEFT:
					{
						FlapUp = true;
						break;
					}
					case ALLEGRO_KEY_X:
					{
						ThrottleUp();
						break;
					}
					case ALLEGRO_KEY_Z:
					{
						ThrottleDown();
						break;
					}
					case ALLEGRO_KEY_SPACE:
					{
						FiringWeapon[0] = true;
						break;
					}
					case ALLEGRO_KEY_B:
					{
						FiringWeapon[1] = true;
						break;
					}
					case ALLEGRO_KEY_C:
					{
						FiringWeapon[2] = true;
						break;
					}
					default:
					{
					}
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_UP:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_RIGHT:
					{
						FlapDown = false;
						break;
					}
					case ALLEGRO_KEY_LEFT:
					{
						FlapUp = false;
						break;
					}
					case ALLEGRO_KEY_SPACE:
					{
						FiringWeapon[0] = false;
						break;
					}
					case ALLEGRO_KEY_B:
					{
						FiringWeapon[1] = false;
						break;
					}
					case ALLEGRO_KEY_C:
					{
						FiringWeapon[2] = false;
						break;
					}
					default:
					{
					}
				}
				break;
			}
			default:
			{
			}
		}
	}
	void Logic()
	{
		if(VictoryParade)
		{
			Smoke.Active = false;
			Smoke.Logic();
			if(Sprite != Victory)
			{
				Sprite = Victory;
				Sprite.SetFrame(0);
			}
			return;
		}
		super.Logic();
	}
	void DoVictoryParade()
	{
		if(!Burning && !VictoryParade)
		{
			VictoryParade = true;
			Location.Theta = 0;
			OldLocation = Location;
		}
	}
	void OnDamage(float damage, DamageType type = DamageType.Normal)
	{
		if(VictoryParade)
			return;
		if(damage < 0 && !Burning)
		{
			super.OnDamage(damage, type);
			Level.OnPlayerHealed();
			Level.PlaySound(HeartSound, GetPos());
		}
		else if(damage > 0 && damage < 50)
		{
			super.OnDamage(damage, type);
			Level.OnPlayerHit();
		}
		else if(damage > 0)
			super.OnDamage(damage, type);
	}
protected:
	ALLEGRO_SAMPLE* HeartSound;
	CSprite Victory;
	void OnCollide()
	{
		super.OnCollide();
		Level.OnPlayerDied();
	}
	bool VictoryParade = false;
}
