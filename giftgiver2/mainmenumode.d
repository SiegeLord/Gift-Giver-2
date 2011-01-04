module giftgiver2.mainmenumode;

import giftgiver2.mode;
import giftgiver2.game;
import giftgiver2.bitmap;
import giftgiver2.gfx;
import giftgiver2.font;
import giftgiver2.sprite;
import audio = giftgiver2.audio;

import tango.stdc.stringz;
import tango.text.Util;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_audio;

class CMainMenuMode : CMode
{
	this()
	{
		Clouds[0] = bitmap.Load("cloud1.png");
		Clouds[1] = bitmap.Load("cloud2.png");
		
		Logo = bitmap.Load("logo.png");
		
		Santa = new CSprite("santa");
		GUIFont = font.Load("AldotheApache.ttf", 36);
		//al_draw_textf(GUIFont, ViewX / 2, 20, ALLEGRO_ALIGN_CENTRE, toStringz(join(Entries)));
		for(int ii = 0; ii < Entries.length; ii++)
		{
			Widths[ii] = al_get_text_width(GUIFont, toStringz(Entries[ii]));
		}
		
		ChangeSelectionSound = audio.Load("select.ogg");
	}
	
	void Logic()
	{
		
	}
	
	void Draw()
	{
		UseGameTransform();
		
		DrawGradient(0, 0, ViewX, ViewY, ALLEGRO_COLOR(0, 0.5, 1,1), ALLEGRO_COLOR(0, 0.05, 0.1,1));
		
		const int spacing = 50;
		
		auto bmp = Santa.GetFrame();
		auto width = al_get_bitmap_width(bmp);
		
		al_draw_bitmap(bmp, ViewX / 2 - 10 - Widths[Selection] / 2 - width, ViewY / 2 + Selection * spacing, 0);
		al_draw_bitmap(bmp, ViewX / 2 + 10 + Widths[Selection] / 2, ViewY / 2 + Selection * spacing, ALLEGRO_FLIP_HORIZONTAL);
		
		al_draw_bitmap(Clouds[0], -30, 100, 0);
		al_draw_bitmap(Clouds[1], ViewX - 200, 300, 0);
		
		al_draw_bitmap(Logo, (ViewX - al_get_bitmap_width(Logo)) / 2, 50, 0);
		
		for(int ii = 0; ii < Entries.length; ii++)
		{
			al_draw_textf(GUIFont, ColorFixer(ALLEGRO_COLOR(1,1,0,1)), ViewX / 2, ViewY / 2 + ii * spacing, ALLEGRO_ALIGN_CENTRE, toStringz(Entries[ii]));
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
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
					{
						SetExit();
						break;
					}
					case ALLEGRO_KEY_ENTER:
					{
						al_play_sample(ExitModeSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
						switch(Selection)
						{
							case 0:
							{
								SetNextMode(EGameMode.Game);
								break;
							}
							case 1:
							{
								SetNextMode(EGameMode.HighScore);
								break;
							}
							case 2:
							{
								SetNextMode(EGameMode.Controls);
								break;
							}
							case 3:
							{
								SetExit();
								break;
							}
						}
						
						break;
					}
					case ALLEGRO_KEY_DOWN:
					{
						al_play_sample(ChangeSelectionSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
						Selection++;
						Selection %= 4;
						break;
					}
					case ALLEGRO_KEY_UP:
					{
						al_play_sample(ChangeSelectionSound, 1, 0, 1, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE, null);
						Selection--;
						if(Selection < 0)
							Selection += 4;
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
private:
	char[][4] Entries = ["New Game", "High Scores", "Controls", "Quit"];
	float[4] Widths;
	ALLEGRO_FONT* GUIFont;
	CSprite Santa;
	int Selection = 0;
	
	ALLEGRO_BITMAP*[2] Clouds;
	ALLEGRO_BITMAP* Logo;
	
	ALLEGRO_SAMPLE* ChangeSelectionSound;
}
