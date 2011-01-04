module giftgiver2.gamemode;

import giftgiver2.mode;
import giftgiver2.game;
import bitmap = giftgiver2.bitmap;
import font = giftgiver2.font;
import giftgiver2.level;
import giftgiver2.gfx;
import giftgiver2.mathtypes;
import giftgiver2.options;
import giftgiver2.scores;
import audio = giftgiver2.audio;

import tango.io.Stdout;
import tango.math.Math;
import tango.math.random.Random;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;
import allegro5.allegro_audio;

class CGameMode : CMode
{
	this()
	{
		GUIFont = font.Load("AldotheApache.ttf", 36);
		//al_draw_textf(GUIFont, ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, "1234567890-PausedGame Over");
		LifeIcon = bitmap.Load("lifeicon.png");
		HealthIcon = bitmap.Load("healthicon.png");
		BulletHole = bitmap.Load("bullethole.png");
		LifeBonusScore = LifeBonusRate;
		
		NewLifeSound = audio.Load("heart.ogg");
	}
	
	void Logic()
	{
		if(Paused)
			return;
		if(abs(Score - TargetScore) < 5)
			Score = TargetScore;
		else if(Score < TargetScore)
			Score += 5;
		else if(Score > TargetScore)
			Score -= 5;
		
		if(Score >= LifeBonusScore)
		{
			al_play_sample(NewLifeSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
			Lives++;
			LifeBonusScore += LifeBonusRate;
		}
		
		if(NewLevel)
		{
			if(CurLevel)
				delete CurLevel;
			CurLevel = new CLevel(this);
			OnPlayerHealed();
			NewLevel = false;
		}
		
		if(CurLevel)
			CurLevel.Logic();
		
		if(Defeat && ((Time - DefeatTime) > 3))
		{
			if(SetHighScore(Score))
				SetNextMode(EGameMode.HighScoreEntry);
			else
				SetNextMode(EGameMode.HighScore);
			//UpdateHighScores();
		}
	}
	
	void Draw()
	{
		super.Draw();
		al_clear_to_color(ColorFixer(ALLEGRO_COLOR(0,0,0,1)));
		
		if(CurLevel)
			CurLevel.Draw();
		
		UseGameTransform();
		
		foreach(hole; BulletHoles)
		{
			al_draw_bitmap(BulletHole, hole.X, hole.Y, 0);
		}
		
		if(CurLevel)
		{
			int num_hearts = cast(int)(4 * CurLevel.GetPlayerHealth());
			
			for(int ii = 0; ii < num_hearts; ii++)
			{
				al_draw_bitmap(HealthIcon, ii * 20 + 32, 30, 0);
			}
		}
		
		for(int ii = 0; ii < Lives; ii++)
		{
			al_draw_bitmap(LifeIcon, ViewX - ii * 20 - 64, 30, 0);
		}

		al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, "%d", Score);
		if(!Paused)
		{
			if(Defeat)
			{
				al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, ViewY / 2, ALLEGRO_ALIGN_CENTRE, "Game Over");
			}
		}
		else
			al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, ViewY / 2, ALLEGRO_ALIGN_CENTRE, "Paused");
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		if(CurLevel)
			CurLevel.Input(event);
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				SetExit();
				break;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				if(Defeat)
				{
					if(SetHighScore(Score))
						SetNextMode(EGameMode.HighScoreEntry);
					else
						SetNextMode(EGameMode.HighScore);
				}
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
					{
						SetNextMode(EGameMode.MainMenu);
						break;
					}
					case ALLEGRO_KEY_P:
					case ALLEGRO_KEY_PAUSE:
					{
						Paused = !Paused;
						break;
					}
					default:
				}
				break;
			}
			default:
			{
			}
		}
	}
	
	void AddScore(int ammount)
	{
		if(!Defeat)
			TargetScore += ammount;
	}
	
	void OnLevelComplete()
	{
		NewLevel = true;
		Difficulty++;
	}
	void OnLevelFailed()
	{
		if(!Defeat)
		{
			DefeatTime = Time;
			Defeat = true;
		}
	}
	int GetNumLives()
	{
		return Lives;
	}
	
	bool UseALife()
	{
		if(Lives <= 0)
			return false;
		BulletHoles.length = 0;
		Lives--;
		return true;
	}
	
	void OnPlayerHit()
	{
		BulletHoles ~= SVector2D(rand.uniformR2(50, ViewX - 50), rand.uniformR2(50, ViewY - 50));
	}
	
	void OnPlayerHealed()
	{
		if(CurLevel)
		{
			if(BulletHoles.length)
				BulletHoles.length = cast(int)(4 - 4 * CurLevel.GetPlayerHealth());
		}
	}
private:
	SVector2D[] BulletHoles;
	ALLEGRO_BITMAP* LifeIcon;
	ALLEGRO_BITMAP* HealthIcon;
	ALLEGRO_BITMAP* BulletHole;
	ALLEGRO_FONT* GUIFont;
	int Score = 0;
	int TargetScore = 0;
	CLevel CurLevel;
	bool NewLevel = true;
	int Lives = 3;
	int LifeBonusScore = 1000;
	
	ALLEGRO_SAMPLE* NewLifeSound;
	
	bool Defeat = false;
	float DefeatTime = 0;
}
