module giftgiver2.controlsmode;

import giftgiver2.mode;
import giftgiver2.game;
import giftgiver2.bitmap;
import giftgiver2.gfx;
import giftgiver2.font;
import giftgiver2.sprite;

import tango.stdc.stringz;
import tango.text.Util;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_audio;

class CControlsMode : CMode
{
	this()
	{
		GUIFont = font.Load("AldotheApache.ttf", 36);
		//al_draw_textf(GUIFont, ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, toStringz(join(Entries)));
	}
	
	void Draw()
	{
		UseGameTransform();
		
		DrawGradient(0, 0, ViewX, ViewY, ALLEGRO_COLOR(0, 0.5, 1, 1), ALLEGRO_COLOR(0, 0.05, 0.1, 1));
		
		const int spacing = 50;		
		foreach(ii, entry; Entries)
			al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), 100, 20 + ii * spacing, ALLEGRO_ALIGN_LEFT, toStringz(entry));
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
	
	char[][] Entries = ["Left/Right - Pivot up/down",
	                     "Down - Flip upside down",
	                 	 "X - Throttle up/Restart engine",
	                 	 "Z - Throttle down",
	                 	 "C - Throw a present",
	                 	 "B - Throw a bomb",
	                 	 "P - Pause",
	                 	 "Space - Fire the chaingun",
	                 	 "Esc - Exit"];
}
