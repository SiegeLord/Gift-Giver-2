module giftgiver2.game;

import gfx = giftgiver2.gfx;
import giftgiver2.gamemode;
import giftgiver2.mainmenumode;
import giftgiver2.controlsmode;
import giftgiver2.highscoremode;
import giftgiver2.highscoreentrymode;
import giftgiver2.mode;
import scores = giftgiver2.scores;
import config = giftgiver2.config;
import options = giftgiver2.options;
import spritesheet = giftgiver2.spritesheet;
import bitmap = giftgiver2.bitmap;
import font = giftgiver2.font;
import audio = giftgiver2.audio;

import tango.io.Stdout;
import tango.stdc.stringz;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_ttf;
import allegro5.allegro_primitives;
import allegro5.allegro_audio;

enum EGameMode
{
	MainMenu,
	Controls,
	HighScore,
	HighScoreEntry,
	Game,
	Exit
};

bool Paused = false;
float Time = 0;
float PhysicsAlpha = 0;
EGameMode NextMode = EGameMode.Game;
const int ViewX = 640;
const int ViewY = 480;
int Difficulty = 0;

ALLEGRO_AUDIO_STREAM* Music;

const int LPS = 60;
const float FixedDt = 1.0f / LPS;

private
{
	ALLEGRO_EVENT_QUEUE* Queue;
	bool Exit = false;
	bool SwitchMode = false;
}
	
private void GameLoop(CMode mode)
{
	ALLEGRO_EVENT event;
	Time = 0;
	
	float cur_time = al_get_time();
	float accumulator = 0;
	
	while(1)
	{
		float new_time = al_get_time();
		float delta_time = new_time - cur_time;
		al_rest(FixedDt - delta_time);
		
		delta_time = new_time - cur_time;
		cur_time = new_time;

		accumulator += delta_time;

		while (accumulator >= FixedDt)
		{
			while(al_get_next_event(Queue, &event))
			{
				mode.Input(&event);
			}
			
			mode.Logic();
			
			if(SwitchMode || Exit)
				return;			
			
			if(!Paused)
				Time += FixedDt;
			accumulator -= FixedDt;
		}

		if(Paused)
			PhysicsAlpha = 0;
		else
			PhysicsAlpha = accumulator / FixedDt;
		mode.Draw();
		
		al_flip_display();
	}
}

void Init()
{
	al_init();
	
	options.Init();
	gfx.Init();
	bitmap.Init();
	spritesheet.Init();
	font.Init();
	scores.Init();
	audio.Init();

	al_install_keyboard();
	al_install_mouse();
	
	al_set_window_title("Gift Giver 2");

	Queue = al_create_event_queue();
	al_register_event_source(Queue, al_get_keyboard_event_source());
	al_register_event_source(Queue, al_get_mouse_event_source());
	al_register_event_source(Queue, al_get_display_event_source(gfx.GetDisplay()));
	
	if(options.PlayMusic)
	{
		Music = al_load_audio_stream(toStringz(options.SoundPath ~ "/music.ogg"), 4, 2048);
		al_attach_audio_stream_to_mixer(Music, al_get_default_mixer());
		al_set_audio_stream_playmode(Music, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP);
	}
}

public void Run()
{
	CMode mode = new CMainMenuMode();
	while(!Exit)
	{
		GameLoop(mode);
		
		delete mode;
		if(SwitchMode)
		{
			SwitchMode = false;
			switch(NextMode)
			{
				case EGameMode.Game:
				{
					mode = new CGameMode();
					break;
				}
				case EGameMode.MainMenu:
				{
					mode = new CMainMenuMode();
					break;
				}
				case EGameMode.HighScore:
				{
					mode = new CHighScoreMode();
					break;
				}
				case EGameMode.HighScoreEntry:
				{
					mode = new CHighScoreEntryMode();
					break;
				}
				case EGameMode.Controls:
				{
					mode = new CControlsMode();
					break;
				}
				case EGameMode.Exit:
				{
					Exit = true;
					break;
				}
			}
		}
	}
}

void DeInit()
{
	if(options.PlayMusic)
		al_destroy_audio_stream(Music);
	audio.DeInit();
	scores.DeInit();
	font.DeInit();
	spritesheet.DeInit();
	bitmap.DeInit();
	gfx.DeInit();
	options.DeInit();
}

void SetExit()
{
	Exit = true;
}

void SetNextMode(EGameMode mode)
{
	SwitchMode = true;
	NextMode = mode;
}

/*
 * FIXME:
 * Needed to fix an LDC bug where stuff like al_clear_to_color(al_map_rgb(255,255,255)) does not work
 * on 64 bit systems.
 */
ALLEGRO_COLOR ColorFixer(ALLEGRO_COLOR col)
{
	return col;
}
