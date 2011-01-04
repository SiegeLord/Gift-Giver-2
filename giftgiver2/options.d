module giftgiver2.options;

import giftgiver2.config;

char[] BmpPath;
char[] SpritePath;
char[] FontPath;
char[] SoundPath;
int ScreenX;
int ScreenY;
bool Fullscreen;
float Gravity;
float RespawnDelay;
int LifeBonusRate;
float GroundJagg;
bool PlayMusic;

private CConfiguration Config;

void Init()
{
	Config = new CConfiguration("configuration.ini");
	
	BmpPath = Config.GetString("paths", "bmp_path", "bitmaps");
	SpritePath = Config.GetString("paths", "sprite_path", "bitmaps");
	SoundPath = Config.GetString("paths", "sounds_path", "sounds");
	FontPath = Config.GetString("paths", "font_path", "fonts");
	ScreenX = Config.GetInt("gfx", "screen_x", 640);
	ScreenY = Config.GetInt("gfx", "screen_y", 480);
	Fullscreen = Config.GetBool("gfx", "fullscreen", false);
	Gravity = Config.GetFloat("game", "gravity", 100);
	RespawnDelay = Config.GetFloat("game", "respawn_delay", 1);
	GroundJagg = Config.GetFloat("game", "ground_jagg", 100);
	LifeBonusRate = Config.GetInt("game", "life_bonus_rate", 5000);
	PlayMusic = Config.GetBool("sfx", "play_music", true);
}

void DeInit()
{
	
}
