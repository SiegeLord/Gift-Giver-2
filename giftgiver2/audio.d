module giftgiver2.audio;

import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_acodec;

import tango.stdc.stringz;
import tango.io.Stdout;
import giftgiver2.options;


private
{
	ALLEGRO_SAMPLE* [char[]] Sounds;
	ALLEGRO_SAMPLE* Default;
}

void Init()
{
	al_install_audio();
	al_init_acodec_addon();
	al_reserve_samples(32);
	
	char[] default_path = SoundPath ~ "/" ~ "default.ogg";
	
	Default = al_load_sample(toStringz(default_path));

	if(!Default)
	{
		throw new Exception("Could not find default sound: " ~ default_path);
	}
}

void DeInit()
{
	foreach(bitmap; Sounds)
	{
		al_destroy_sample(bitmap);
	}
	
	al_destroy_sample(Default);
	
	al_uninstall_audio();
}

ALLEGRO_SAMPLE* Load(char[] filename)
{
	char[] path = SoundPath ~ "/" ~ filename;

	auto existing = (filename in Sounds);

	if(!existing)//can't find it, so load a new one
	{		
		auto ret = al_load_sample(toStringz(path));
	
		if(ret)
		{
			Sounds[filename] = ret;
		}
		else
		{
			Stderr.formatln("Couldn't load sound! File: {}", path);
			ret = Default;
		}
		return ret;
	}
	else//return the existing one
	{
		return *existing;
	}
}
