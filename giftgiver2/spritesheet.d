module giftgiver2.spritesheet;

import bitmap = giftgiver2.bitmap;

import tango.util.container.HashMap;
import tango.io.Stdout;

import allegro5.allegro;

class CSpriteSheet
{
	ALLEGRO_BITMAP* Bitmap;
	ALLEGRO_BITMAP*[] Tiles;
	int TileWidth;
	int TileHeight;
	
	int NumTilesX;
	int NumTilesY;
	
	ALLEGRO_BITMAP* GetTileAt(int index)
	{
		if(Tiles.length == 0)
			return null;
		return Tiles[index];
	}
}

struct CSpriteSheetSig
{
	ALLEGRO_BITMAP* Bitmap;
	int TileWidth;
	int TileHeight;
}

private
{
	HashMap!(CSpriteSheetSig, CSpriteSheet) SpriteSheets;
	CSpriteSheet Default;
}

CSpriteSheet Load(char[] filename, int tile_width, int tile_height)
{
	return Load(bitmap.Load(filename), tile_width, tile_height);
}

CSpriteSheet Load(ALLEGRO_BITMAP* bmp, int tile_width, int tile_height)
{
	CSpriteSheet ret;
	auto exists = SpriteSheets.get(CSpriteSheetSig(bmp, tile_width, tile_height), ret);

	if(!exists)//can't find it, so load a new one
	{
		ret = new CSpriteSheet;
		ret.TileHeight = tile_height;
		ret.TileWidth = tile_width;

		ret.Bitmap = bmp;
		
		ret.NumTilesX = al_get_bitmap_width(ret.Bitmap) / ret.TileWidth;
		ret.NumTilesY = al_get_bitmap_height(ret.Bitmap) / ret.TileHeight;
		if(ret.NumTilesX == 0 || ret.NumTilesY == 0)
		{
			Stderr.formatln("Spritesheet specified dimensions ({} x {}) larger than the dimensions of the bitmap ({} x {}).",
			    ret.TileWidth, ret.TileHeight, al_get_bitmap_width(ret.Bitmap), al_get_bitmap_height(ret.Bitmap));
			
		}
		ret.Tiles.length = ret.NumTilesX * ret.NumTilesY;

		int n = 0;
		for(int ii = 0; ii < ret.NumTilesY; ii++)
		{
			for(int jj = 0; jj < ret.NumTilesX; jj++)
			{
				ALLEGRO_BITMAP* sub_bmp = al_create_sub_bitmap(ret.Bitmap, ret.TileWidth * jj, ret.TileHeight * ii, ret.TileWidth, ret.TileHeight);
				ret.Tiles[n] = sub_bmp;
				n++;
			}
		}

		if(ret)
		{
			SpriteSheets.add(CSpriteSheetSig(bmp, tile_width, tile_height), ret);
		}
		else
		{
			Stderr.formatln("Couldn't load spritesheet!");
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
	SpriteSheets = new HashMap!(CSpriteSheetSig, CSpriteSheet);
	Default = new CSpriteSheet();
	Default.Bitmap = bitmap.Load("default.png");
	Default.Tiles ~= Default.Bitmap;
	Default.NumTilesX = 1;
	Default.NumTilesY = 1;
	Default.TileHeight = al_get_bitmap_height(Default.Bitmap);
	Default.TileWidth = al_get_bitmap_width(Default.Bitmap);
}

void DeInit()
{
	SpriteSheets.reset();
	delete Default;
}
