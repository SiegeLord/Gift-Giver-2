module giftgiver2.level;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;
import allegro5.allegro_audio;

import tango.math.random.Random;
import array = tango.core.Array;
import tango.io.Stdout;
import tango.math.Math;

import giftgiver2.mathtypes;
import giftgiver2.camera;
import giftgiver2.gfx;
import audio = giftgiver2.audio;
import giftgiver2.game;
import giftgiver2.player;
import giftgiver2.gameobject;
import giftgiver2.options;
import giftgiver2.enemyplane;
import giftgiver2.nicehouse;
import giftgiver2.badhouse;
import giftgiver2.gamemode;
import giftgiver2.explosion;
import giftgiver2.particleemitter;
import font = giftgiver2.font;
import bitmap = giftgiver2.bitmap;

const int NumBitmaps = 6;
const int Width = NumBitmaps * 512;
const int Height = 2 * 512;

class CLevel
{
	this(CGameMode mode)
	{
		Clouds[0] = bitmap.Load("cloud1.png");
		Clouds[1] = bitmap.Load("cloud2.png");
		
		Mode = mode;
		NumBadHouses = 4 + Difficulty;
		Camera = new CCamera(SRect(0, 0, Width, Height), SVector2D(ViewX / 8, ViewY / 8), 200);
		Camera.SetPos(SVector2D(0, 512));
		
		CreatePlayer();
		
		ClearTransform();
		
		auto old_target = al_get_target_bitmap();
		
		for(int ii = 0; ii < NumBitmaps; ii++)
		{
			VideoBitmaps[ii] = al_create_bitmap(512, 512);
			if(!VideoBitmaps[ii])
				throw new Exception("Failed to create the level bitmaps... :(");
			al_set_target_bitmap(VideoBitmaps[ii]);
			al_clear_to_color(ColorFixer(ALLEGRO_COLOR(0, 0, 0, 0)));
		}
		al_set_target_bitmap(old_target);
		
		al_set_new_bitmap_flags(ALLEGRO_MEMORY_BITMAP);
		for(int ii = 0; ii < NumBitmaps; ii++)
		{
			MemoryBitmaps[ii] = al_create_bitmap(512, 512);
			if(!MemoryBitmaps[ii])
				throw new Exception("Failed to create the level bitmaps... :(");
			
			al_set_target_bitmap(MemoryBitmaps[ii]);
			al_clear_to_color(ColorFixer(ALLEGRO_COLOR(0, 0, 0, 0)));
		}
		al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP);
		
		float ground[Width / 64 + 1];
		{
			auto y1 = rand.uniformR2(0.0f, 512.0f);
			for(int ii = 0; ii < ground.length; ii++)
			{
				auto y2 = rand.uniformR2(y1 - GroundJagg, y1 + GroundJagg);
				
				if(y2 < 0)
					y2 = 0;
				if(y2 > 450)
					y2 = 450;
				
				ground[ii] = y2;
				
				y1 = y2;
			}
		}
		
		int spacing = cast(int)(Width / (NumBadHouses + 1));
		for(int ii = 0; ii < NumBadHouses; ii++)
		{
			int x = (ii + 1) * spacing;
			int xidx = x / 64;
			ground[xidx] = ground[xidx + 1];
			int y = 512 + cast(int)ground[xidx];
			
			auto house = new CBadHouse(this);
			house.SetPosition(x, y, 0);
			AddObject(house);
			Houses ~= house;
		}
		
		int[] used_xs;
		for(int ii = 0; ii < 4; ii++)
		{
			int x = 0;
			do
			{
				x = rand.uniformR2(0, Width / spacing) * spacing + spacing / 2;
			}
			while(array.contains(used_xs, x));
			used_xs ~= x;
			
			int xidx = x / 64;
			ground[xidx] = ground[xidx + 1];
			int y = 512 + cast(int)ground[xidx];
			
			auto house = new CNiceHouse(this);
			house.SetPosition(x, y, 0);
			AddObject(house);
			Houses ~= house;
		}
		
		for(int ii = 0; ii < NumBadHouses; ii++)
		{
			int x = (ii + 1) * Width / 64 / (NumBadHouses + 1);
			ground[x] = ground[x + 1];
		}
		
		float layer_height = 100;
		for(int pass = 0; pass < 3; pass++)
		{
			auto col1 = ALLEGRO_COLOR(1, 1, 1,1);
			auto col2 = ALLEGRO_COLOR(0.5, 0.5, 0.5,1);

			if(pass != 0)
			{
				for(int ii = 0; ii < ground.length; ii++)
				{
					ground[ii] = ground[ii] + layer_height;
				}
			}
			if(pass == 1)
			{
				//col1 = al_map_rgb_f(0.3, 0.1, 0.05);
				//col2 = al_map_rgb_f(0.4, 0.2, 0.1);
				col1 = ALLEGRO_COLOR(0.2, 0.2, 0.2,1);
				col2 = ALLEGRO_COLOR(0.3, 0.3, 0.3,1);
				layer_height = 50;
			}
			else if(pass == 2)
			{
				col1 = ALLEGRO_COLOR(0.2, 0.07, 0.03,1);
				col2 = ALLEGRO_COLOR(0.35, 0.12, 0.07,1);
				layer_height = 400;
			}
			
			for(int ii = 0; ii < NumBitmaps; ii++)
			{		
				auto x1 = 0.0f;
				for(int jj = 0; jj < 512 / 64; jj++)
				{
					auto x2 = (jj + 1) * 64.0f;
					auto y1 = ground[ii * 512 / 64 + jj];
					auto y2 = ground[ii * 512 / 64 + jj + 1];
					
					void drawer(ALLEGRO_BITMAP* bmp)
					{
						al_set_target_bitmap(bmp);
						DrawQuad([[x1, y1 + layer_height],[x1, y1],[x2,y2],[x2, y2 + layer_height]], [col2, col1, col1, col2]);
					}
					
					DrawOnBitmaps(&drawer, ii);
					
					x1 = x2;
				}						
			}
		}
		
		al_set_target_bitmap(old_target);
		
		UseGameTransform();
		
		for(int ii = 0; ii < Stars.length; ii++)
		{
			Stars[ii].X = rand.uniformR2(0, Width);
			Stars[ii].Y = rand.uniformR2(0, 400);
		}
		for(int ii = 0; ii < CloudPositions.length; ii++)
		{
			CloudPositions[ii].X = rand.uniformR2(0, Width);
			CloudPositions[ii].Y = rand.uniformR2(350, 500);
		}
		
		ExplosionSound = audio.Load("explosion.ogg");
	}
	
	~this()
	{
		foreach(bmp; VideoBitmaps)
			al_destroy_bitmap(bmp);
		foreach(bmp; MemoryBitmaps)
			al_destroy_bitmap(bmp);
	}
	
	void Draw()
	{
		Camera.Draw();
		
		DrawGradient(0, 0, Width, Height, ALLEGRO_COLOR(0, 0.5, 1,1), ALLEGRO_COLOR(0, 0.05, 0.1,1));
		
		for(int ii = 0; ii < Stars.length; ii++)
		{
			al_draw_pixel(Stars[ii].X, Stars[ii].Y, ColorFixer(ALLEGRO_COLOR(1, 1, 1, 1)));
		}
		
		//al_hold_bitmap_drawing(true);
		for(int ii = 0; ii < CloudPositions.length / 2; ii++)
		{
			al_draw_bitmap(Clouds[ii % 2], CloudPositions[ii].X, CloudPositions[ii].Y, 0);
		}
		
		int x = 0;
		foreach(bmp; VideoBitmaps)
		{
			al_draw_bitmap(bmp, x, Height - 512, 0);
			x += 512;
		}

		foreach(obj; Objects)
			obj.Draw();
		
		foreach(emitter; DyingEmitters)
			emitter.Draw();
		
		for(int ii = CloudPositions.length / 2; ii < CloudPositions.length; ii++)
		{
			al_draw_bitmap(Clouds[ii % 2], CloudPositions[ii].X, CloudPositions[ii].Y, 0);
		}
		//al_hold_bitmap_drawing(false);
	}
	
	void Logic()
	{
		if(NumBadHouses == 0 && Player)
			Player.DoVictoryParade();
		if(NumBadHouses == 0 && Time - VictoryTime > 3)
			Mode.OnLevelComplete();
		if(!Player && !Defeat)
		{
			RespawnCountdown -= FixedDt;
			if(RespawnCountdown < 0)
			{
				if(Mode.UseALife())
					CreatePlayer();
				else
				{
					Mode.OnLevelFailed();
					Defeat = true;
				}
			}
		}
		
		Camera.Logic();
		
		foreach(obj; Objects)
			obj.Logic();
		
		foreach(emitter; DyingEmitters)
			emitter.Logic();
		
		bool is_dead(CObject obj)
		{
			return obj.IsDead();
		}
		
		auto old = CollidableObjects.length;
		CollidableObjects.length = array.removeIf(CollidableObjects, &is_dead);
		Objects.length = array.removeIf(Objects, &is_dead);
		Houses.length = array.removeIf(Houses, &is_dead);
		
		bool is_emitter_dead(CParticleEmitter emitter)
		{
			return emitter.GetNumActiveParticles() <= 0;
		}
		
		DyingEmitters.length = array.removeIf(DyingEmitters, &is_emitter_dead);
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		if(Player)
			Player.Input(event);
	}
	
	int GetGroundHeight(int x)
	{
		for(int y = 512; y < Height; y++)
		{
			if(PixelSolid(x, y))
				return y;
		}
		return Height;
	}
	
	bool PixelSolid(int x, int y)
	{
		if(x < 0 || x >= Width)
			return true;
		if(y < -512)
			return true;
		if(y < 512)
			return false;
		if(y > Height)
			return true;
		
		int bmp_n = x / 512;
		int real_x = x % 512;
		int real_y = y - 512;
		auto col = al_get_pixel(MemoryBitmaps[bmp_n], real_x, real_y);
		
		float r,g,b,a;
		al_unmap_rgba_f(col, &r, &g, &b, &a);
		
		return a > 0;
	}
	
	bool Collide(SVector2D pos, int size)
	{
		for(int y = cast(int)pos.Y - size; y < cast(int)pos.Y + size; y++)
		{
			for(int x = cast(int)pos.X - size; x < cast(int)pos.X + size; x++)
			{
				if(PixelSolid(x, y))
					return true;
			}			
		}
		return false;
	}
	
	CObject GetObjectAtPos(SVector2D pos, int size)
	{
		auto rect1 = SRect(pos - SVector2D(size, size), pos + SVector2D(size, size));
		foreach(obj; CollidableObjects)
		{
			auto sz = SVector2D(obj.GetSize(), obj.GetSize());
			auto rect2 = SRect(obj.GetPos() - sz, obj.GetPos() + sz);
			if(rect1.IntersectTest(rect2))
				return obj;
		}
		return null;
	}
	
	CObject GetObjectAtBullet(SVector2D pos1, SVector2D pos2, int n)
	{
		SVector2D inc = (pos2 - pos1) / n;
		foreach(obj; CollidableObjects)
		{
			SVector2D pos = pos1;
			
			auto sz = SVector2D(obj.GetSize(), obj.GetSize());
			auto rect = SRect(obj.GetPos() - sz, obj.GetPos() + sz);
						
			for(int ii = 0; ii < n; ii++)
			{
				if(rect.PointTest(pos))
					return obj;
				pos += inc;
			}
		}
		return null;
	}
	
	CObject GetHouseAtPos(SVector2D pos, int size)
	{
		auto rect1 = SRect(pos - SVector2D(size, size), pos + SVector2D(size, size));
		foreach(obj; Houses)
		{
			auto sz = SVector2D(obj.GetSize(), obj.GetSize());
			auto rect2 = SRect(obj.GetPos() - sz, obj.GetPos() + sz);
			if(rect1.IntersectTest(rect2))
				return obj;
		}
		return null;
	}
	
	void MakeExplosion(SVector2D pos, float size)
	{
		int x = cast(int)pos.X;
		int y = cast(int)pos.Y;
		int bmp_n = x / 512;
		int real_x = x % 512;
		int real_y = y - 512;
		
		PlaySound(ExplosionSound, pos);
		
		int num_explosions = cast(int)size / 10 + 1;
		for(int ii = 0; ii < num_explosions; ii++)
		{
			auto exp = new CExplosion(this);
			if(ii == 0)
				exp.SetPosition(pos.X, pos.Y, 0);
			else
				exp.SetPosition(rand.uniformR2(pos.X - size, pos.X + size), rand.uniformR2(pos.Y - size, pos.Y + size), 0);
			AddObject(exp, false);
		}
		
		if(y < 512 - cast(int)size)
			return;
		
		auto old_target = al_get_target_bitmap();
		
		void drawer(ALLEGRO_BITMAP* bmp)
		{
			al_set_target_bitmap(bmp);
			al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_BLEND_MODE.ALLEGRO_ONE, ALLEGRO_BLEND_MODE.ALLEGRO_ZERO, ALLEGRO_COLOR(1,1,1,1));
			al_draw_filled_circle(real_x, real_y, size, ColorFixer(ALLEGRO_COLOR(0,0,0,0)));
			al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_BLEND_MODE.ALLEGRO_ONE, ALLEGRO_BLEND_MODE.ALLEGRO_INVERSE_ALPHA, ALLEGRO_COLOR(1,1,1,1));
		}
		
		ClearTransform();
		DrawOnBitmaps(&drawer, bmp_n);
		if(real_x > 256)
		{
			bmp_n++;
			if(bmp_n < NumBitmaps)
			{
				real_x -= 512;
				DrawOnBitmaps(&drawer, bmp_n);
			}
		}
		else
		{
			bmp_n--;
			if(bmp_n >= 0)
			{
				real_x += 512;
				DrawOnBitmaps(&drawer, bmp_n);
			}
		}
		al_set_target_bitmap(old_target);
		UseGameTransform();
	}
	
	void OnPlayerDied()
	{
		Camera.SetFollowObject(null);
		Player = null;
		RespawnCountdown = RespawnDelay;
		AddScore(-200);
	}
	
	CObject GetPlayer()
	{
		return Player;
	}
	
	void AddObject(CObject obj, bool collidable = true)
	{
		Objects ~= obj;
		if(collidable)
			CollidableObjects ~= obj;
	}
	
	void AddScore(int ammount)
	{
		Mode.AddScore(ammount);
	}
	
	void OnBadHouseDestroyed()
	{
		NumBadHouses--;
		if(NumBadHouses == 0)
		{
			VictoryTime = Time;
			Mode.AddScore(500);
		}
	}
	
	float GetPlayerHealth()
	{
		if(!Player)
			return 0;
		return Player.GetHealth();
	}
	
	void OnPlayerHit()
	{
		Mode.OnPlayerHit();
	}
	
	void OnPlayerHealed()
	{
		Mode.OnPlayerHealed();
	}
	
	void AddDyingEmitter(CParticleEmitter emitter)
	{
		DyingEmitters ~= emitter;
	}
	
	void PlaySound(ALLEGRO_SAMPLE* sample, SVector2D pos, bool loop = false)
	{
		auto mode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE;
		if(loop)
			mode = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP;
			
		auto diff = pos - (SVector2D(ViewX, ViewY) / 2 + Camera.GetPos());
		
		float gain = (800 - diff.GetLength()) / 800;
		if(gain < 0)
			gain = 0;
		
		float pan = diff.X / 200;
		if(pan < -1)
			pan = -1;
		else if(pan > 1)
			pan = 1;
		
		al_play_sample(sample, gain, pan, 1, mode, null);
	}
private:
	void CreatePlayer()
	{
		Player = new CPlayer(this);
		Player.SetPosition(100, 300, 0);
		
		AddObject(Player);
		
		Camera.SetFollowObject(Player);
		Camera.CenterOnObject();
		OnPlayerHealed();
	}
	void DrawOnBitmaps(void delegate(ALLEGRO_BITMAP* bmp) fn, int idx)
	{
		fn(MemoryBitmaps[idx]);
		fn(VideoBitmaps[idx]);
	}
	
	ALLEGRO_SAMPLE* ExplosionSound;
	SVector2D[100] Stars;
	float RespawnCountdown = 0;
	CObject[] Objects;
	CObject[] CollidableObjects;
	CObject[] Houses;
	CParticleEmitter[] DyingEmitters;
	CCamera Camera;
	CPlayer Player;
	ALLEGRO_BITMAP* VideoBitmaps[NumBitmaps];
	ALLEGRO_BITMAP* MemoryBitmaps[NumBitmaps];
	
	ALLEGRO_BITMAP*[2] Clouds;
	SVector2D[20] CloudPositions;
	
	CGameMode Mode;
	int NumBadHouses = 4;
	float VictoryTime = 0;
	bool Defeat = false;
}
