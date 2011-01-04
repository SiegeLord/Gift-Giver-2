module giftgiver2.font;

import tango.util.container.HashMap;
import tango.io.Stdout;
import tango.stdc.stringz;

import giftgiver2.options;

import allegro5.allegro;
import allegro5.allegro_ttf;
import allegro5.allegro_font;

struct SFontSig
{
	char[] Name;
	int Size;
}

private
{
	HashMap!(SFontSig, ALLEGRO_FONT*) Fonts;
	ALLEGRO_FONT* Default;
}

ALLEGRO_FONT* Load(char[] filename, int size)
{
	ALLEGRO_FONT* ret;
	auto exists = Fonts.get(SFontSig(filename, size), ret);

	if(!exists)//can't find it, so load a new one
	{
		auto path = FontPath ~ "/" ~ filename;
		ret = al_load_font(toStringz(path), size, 0);

		if(ret)
		{
			Fonts.add(SFontSig(filename, size), ret);
		}
		else
		{
			Stderr.formatln("Couldn't load font! " ~ filename);
			ret = Default;
		}
		return ret;
	}
	else//return the existing one
	{
		return ret;
	}
}

void Init()
{
	al_init_font_addon();
	al_init_ttf_addon();
	
	Fonts = new HashMap!(SFontSig, ALLEGRO_FONT*);
	auto path = FontPath ~ "/" ~ "AldotheApache.ttf";
	Default = al_load_font(toStringz(path), 12, 0);
	if(!Default)
		throw new Exception("Failed to load default font at: " ~ path);
}

void DeInit()
{
	foreach(font; Fonts)
		al_destroy_font(font);
	Fonts.reset();
	al_destroy_font(Default);
}
