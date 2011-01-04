module giftgiver2.highscoremode;

import giftgiver2.mode;
import giftgiver2.game;
import giftgiver2.bitmap;
import giftgiver2.gfx;
import giftgiver2.font;
import giftgiver2.sprite;
import giftgiver2.scores;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_audio;

import tango.stdc.stringz;
import tango.text.Util;
import tango.io.Stdout;
import Integer = tango.text.convert.Integer;

class CHighScoreMode : CMode
{
	this()
	{
		GUIFont = font.Load("AldotheApache.ttf", 36);
		ScoresFont = font.Load("AldotheApache.ttf", 30);
		
		foreach(ii, entry; Scores)
		{
			NameText[ii] = entry.Name;
			ScoreText[ii] = Integer.toString(entry.Score);
		}
		auto entries = NameText ~ ScoreText; 
		//al_draw_textf(GUIFont, ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, toStringz(join(entries) ~ "HighScores"));
	}
	
	void Draw()
	{
		UseGameTransform();
		
		DrawGradient(0, 0, ViewX, ViewY, ALLEGRO_COLOR(0, 0.5, 1, 1), ALLEGRO_COLOR(0, 0.05, 0.1, 1));
		
		const int spacing = 30;
		al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, "High Scores");
		
		for(int ii = 0; ii < NameText.length; ii++)
		{
			al_draw_textf(ScoresFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), 100, 70 + ii * spacing, ALLEGRO_ALIGN_LEFT, toStringz(NameText[ii]));
			al_draw_textf(ScoresFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX - 100, 70 + ii * spacing, ALLEGRO_ALIGN_RIGHT, toStringz(ScoreText[ii]));
		}
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				SetExit();
				break;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				al_play_sample(ExitModeSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
				SetNextMode(EGameMode.MainMenu);
				break;
			}
			default:
			{
			}
		}
	}
private:
	ALLEGRO_FONT* GUIFont;
	ALLEGRO_FONT* ScoresFont;
	
	char[][10] NameText;
	char[][10] ScoreText;
}
