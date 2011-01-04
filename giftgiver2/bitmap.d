module giftgiver2.bitmap;

import allegro5.allegro;
import allegro5.allegro_image;

import tango.stdc.stringz;
import tango.io.Stdout;
import giftgiver2.options;


private
{
	ALLEGRO_BITMAP* [char[]] Bitmaps;
	ALLEGRO_BITMAP* Default;
}

void Init()
{
	al_init_image_addon();
	
	char[] default_path = BmpPath ~ "/" ~ "default.png";
	
	Default = al_load_bitmap(toStringz(default_path));

	if(!Default)
	{
		throw new Exception("Could not find default bitmap: " ~ default_path);
	}
}

void DeInit()
{
	foreach(bitmap; Bitmaps)
	{
		al_destroy_bitmap(bitmap);
	}
	
	al_destroy_bitmap(Default);
}

ALLEGRO_BITMAP* Load(char[] filename, bool memory = false)
{
	char[] path = BmpPath ~ "/" ~ filename;

	auto existing = (filename in Bitmaps);

	if(!existing)//can't find it, so load a new one
	{
		int old_flags = al_get_new_bitmap_flags();
		if(memory)
		{
			al_set_new_bitmap_flags(ALLEGRO_MEMORY_BITMAP);
		}
		else
		{
			al_set_new_bitmap_flags(0);
		}
		
		auto ret = al_load_bitmap(toStringz(path));
	
		al_set_new_bitmap_flags(old_flags);
	
		if(ret)
		{
			Bitmaps[filename] = ret;
		}
		else
		{
			Stderr.formatln("Couldn't load bitmap! File: {}", path);
			ret = Default;
		}
		return ret;
	}
	else//return the existing one
	{
		return *existing;
	}
}
