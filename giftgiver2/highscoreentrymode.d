module giftgiver2.highscoreentrymode;

import giftgiver2.mode;
import giftgiver2.game;
import giftgiver2.bitmap;
import giftgiver2.gfx;
import giftgiver2.font;
import giftgiver2.scores;
import audio = giftgiver2.audio;

import tango.stdc.stringz;
import tango.text.Util;
import Integer = tango.text.convert.Integer;
import tango.text.convert.Utf;
import tango.io.Stdout;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_audio;

class CHighScoreEntryMode : CMode
{
	this()
	{
		GUIFont = font.Load("AldotheApache.ttf", 36);
		
		//al_draw_textf(GUIFont, ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
		
		LetterSound = audio.Load("select.ogg");
		
		Name = CandidateName;
	}
	
	void Draw()
	{
		UseGameTransform();
		
		DrawGradient(0, 0, ViewX, ViewY, ALLEGRO_COLOR(0, 0.5, 1,1), ALLEGRO_COLOR(0, 0.05, 0.1,1));
		
		al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, "You Got a High Score!");
		al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, 70, ALLEGRO_ALIGN_CENTRE, "Enter your name:");
		al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, ViewY / 2, ALLEGRO_ALIGN_CENTRE, toStringz(Name));
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
			case ALLEGRO_EVENT_KEY_CHAR:
			{
				if(event.keyboard.keycode == ALLEGRO_KEY_ENTER)
				{
					al_play_sample(ExitModeSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
					CandidateName = Name;
					UpdateHighScores();
					SetNextMode(EGameMode.HighScore);
				}
				else if(event.keyboard.keycode == ALLEGRO_KEY_BACKSPACE)
				{
					if(Name.length > 0)
					{
						al_play_sample(LetterSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
						Name.length = Name.length - 1;
					}
				}
				else
				{
					char[6] buff;
					if(isValid(event.keyboard.unichar) && event.keyboard.unichar > 32)
					{
						al_play_sample(LetterSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
						Name ~= encode(buff, event.keyboard.unichar);
					}
				}
				break;
			}
			default:
			{
			}
		}
	}
private:
	ALLEGRO_FONT* GUIFont;
	char[] Name;
	ALLEGRO_SAMPLE* LetterSound;
}
