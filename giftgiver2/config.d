module giftgiver2.config;

import allegro5.allegro;

import tango.stdc.stringz;
import Integer = tango.text.convert.Integer;
import Float = tango.text.convert.Float;
import tango.text.Ascii;
import tango.text.Util;
import tango.util.Convert;
import tango.io.Stdout;

class CConfiguration
{
	this(char[] filename)
	{
		Filename = filename;
		Config = al_load_config_file(toStringz(filename));
		if(!Config)
		{
			Config = al_create_config();
		}
	}
	
	this()
	{
		Filename = "";
		Config = al_create_config();
	}
	
	~this()
	{
		al_destroy_config(Config);
	}
	
	int GetInt(char[] section, char[] key, int def)
	{
		char[] ret = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		return to!(int)(ret, def);
	}

	float GetFloat(char[] section, char[] key, float def)
	{
		char[] ret = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		return to!(float)(ret, def);
	}

	char[] GetString(char[] section, char[] key, char[] def)
	{
		char[] ret = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		if(ret)
			return ret;
		else
			return def;
	}
	
	int[] GetMultiInt(char[] section, char[] key, int[] def)
	{
		char[] str = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		if(str)
		{
			auto numbers = split(str, ", \t");
			if(numbers.length < def.length)
				return def;
			
			auto ret = new int[def.length];
			
			for(int ii = 0; ii < def.length; ii++)
				ret[ii] = to!(int)(numbers[ii], def[ii]);
			
			return ret;
		}
		return def;
	}
	
	float[] GetMultiFloat(char[] section, char[] key, float[] def)
	{
		char[] str = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		if(str)
		{
			auto numbers = split(str, ", \t");
			if(numbers.length < def.length)
				return def;
			
			auto ret = new float[def.length];
			
			for(int ii = 0; ii < def.length; ii++)
				ret[ii] = to!(float)(numbers[ii], def[ii]);
			
			return ret;
		}
		return def;
	}
	
	bool GetBool(char[] section, char[] key, bool def)
	{
		char[] ret = fromStringz(al_get_config_value(Config, toStringz(section), toStringz(key)));
		return to!(bool)(ret, def);
	}
	
	void PutString(char[] section, char[] key, char[] value)
	{
		al_set_config_value(Config, toStringz(section), toStringz(key), toStringz(value));
	}
	
	void PutInt(char[] section, char[] key, int value)
	{
		al_set_config_value(Config, toStringz(section), toStringz(key), toStringz(Integer.toString(value)));
	}
	
	void Save(char[] path)
	{
		al_save_config_file(toStringz(path), Config);
	}
private:
	ALLEGRO_CONFIG* Config;
	char[] Filename;
}
