module giftgiver2.mode;

import audio = giftgiver2.audio;

import allegro5.allegro;
import allegro5.allegro_audio;

class CMode
{
	this()
	{
		ExitModeSound = audio.Load("exit.ogg");
	}
	
	void Logic()
	{
		
	}
	
	void Draw()
	{
		
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		
	}
protected:
	ALLEGRO_SAMPLE* ExitModeSound;
}
