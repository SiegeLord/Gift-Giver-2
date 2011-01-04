module giftgiver2.sprite;

import giftgiver2.config;
import giftgiver2.spritesheet;
import giftgiver2.options;
import giftgiver2.game;

import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro;

class CSprite
{
	this(char[] name)
	{
		/*
		First try to load the config file
		*/
		auto cfg = new CConfiguration(SpritePath ~ "/" ~ name ~ ".spr");

		this(cfg);
	}

	this(CConfiguration config)
	{
		auto path = config.GetString("", "bitmap", "");
		FrameLength = config.GetFloat("", "framelen", 1);
		StartPos = config.GetInt("", "start", 0);
		NumFrames = config.GetInt("", "numframes", 1);
		int width = config.GetInt("", "width", 32);
		int height = config.GetInt("", "height", 32);

		CurFrame = 0;
		TimerOffset = 0;
		Sheet = Load(path, width, height);
	}

	this(ALLEGRO_BITMAP* bmp, int width, int height, int frames, int duration, int start)
	{
		FrameLength = duration;
		NumFrames = frames;
		StartPos = start;

		CurFrame = 0;
		TimerOffset = 0;

		Sheet = Load(bmp, width, height);
	}

	this(CSpriteSheet sheet, int width, int height, int frames, int duration, int start)
	{
		FrameLength = duration;
		NumFrames = frames;
		StartPos = start;

		CurFrame = 0;
		TimerOffset = 0;

		Sheet = sheet;
	}

	ALLEGRO_BITMAP* GetFrame()
	{
		if(Sheet)
		{
			CurFrame = (CurFrame + (Time - TimerOffset) / FrameLength) % NumFrames;
			TimerOffset = Time;
			return Sheet.GetTileAt(StartPos + cast(int)(CurFrame));
		}
		else
			return null;
	}
	
	ALLEGRO_BITMAP* GetFrame(int frame)
	{
		if(Sheet)
		{
			frame = frame % NumFrames;
			return Sheet.GetTileAt(StartPos + frame);
		}
		else
			return null;
	}

	void SetFrame(float frame)
	{
		CurFrame = frame;
		TimerOffset = Time;
	}
	
	int GetNumFrames()
	{
		return NumFrames;
	}
protected:
	CSpriteSheet Sheet;
	float CurFrame;
	float TimerOffset;
	float FrameLength;
	int StartPos;
	int NumFrames;
}
