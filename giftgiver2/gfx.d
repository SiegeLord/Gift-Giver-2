module giftgiver2.gfx;

import allegro5.allegro;
import allegro5.allegro_primitives;
import giftgiver2.options;

import giftgiver2.game;
import giftgiver2.mathtypes;

import tango.math.Math;

private
{
	ALLEGRO_DISPLAY* Display;
	ALLEGRO_TRANSFORM Transform;
	ALLEGRO_TRANSFORM Identity;
	int ClipX;
	int ClipY;
	int Scale;
}

ALLEGRO_DISPLAY* GetDisplay()
{
	return Display;
}

void UseGameTransform()
{
	al_use_transform(&Transform);
	al_set_clipping_rectangle(ClipX, ClipY, ScreenX - 2 * ClipX, ScreenX - 2 * ClipY);
}

ALLEGRO_TRANSFORM GetTransform()
{
	return Transform;
}

int GetScale()
{
	return Scale;
}

void ClearTransform()
{
	al_use_transform(&Identity);
	al_set_clipping_rectangle(0, 0, ScreenX, ScreenX);
}

void Init()
{
	/*
	 * Determine what if any scaling we can do... we letterbox the 'incompabile scales'
	 */
	if(ScreenX < ViewX || ScreenY < ViewY)
		throw new Exception("Screen resolution must be at least 640 by 480");
	
	int flags = 0;
    flags |= Fullscreen ? ALLEGRO_FULLSCREEN : ALLEGRO_WINDOWED;
    al_set_new_display_flags(flags);
	
	Display = al_create_display(ScreenX, ScreenY);
	if(!Display)
		throw new Exception("Could not create display. Try different screen resolutions and/or windowed mode...");
	
	al_init_primitives_addon();
	
	int scale_x = ScreenX / ViewX;
	int scale_y = ScreenY / ViewY;
	Scale = min(scale_x, scale_y);
	ClipX = (ScreenX - Scale * ViewX) / 2;
	ClipY = (ScreenY - Scale * ViewY) / 2;
	al_build_transform(&Transform, ClipX, ClipY, Scale, Scale, 0);
	al_identity_transform(&Identity);
	
	UseGameTransform();
}

void DeInit()
{
	al_destroy_display(Display);
}

void DrawGradient(float min_x, float min_y, float max_x, float max_y, ALLEGRO_COLOR bottom, ALLEGRO_COLOR top)
{
	ALLEGRO_VERTEX vtx[4];
	vtx[0].x = min_x;
	vtx[0].y = min_y;
	vtx[0].z = 0;
	vtx[0].color = top;
	
	vtx[1].x = max_x;
	vtx[1].y = min_y;
	vtx[1].z = 0;
	vtx[1].color = top;
	
	vtx[2].x = max_x;
	vtx[2].y = max_y;
	vtx[2].z = 0;
	vtx[2].color = bottom;
	
	vtx[3].x = min_x;
	vtx[3].y = max_y;
	vtx[3].z = 0;
	vtx[3].color = bottom;
	
	al_draw_prim(cast(void*)(vtx.ptr), null, null, 0, 4, ALLEGRO_PRIM_TYPE.ALLEGRO_PRIM_TRIANGLE_FAN);
}

void DrawQuad(float pts[4][2], ALLEGRO_COLOR colors[4])
{
	ALLEGRO_VERTEX vtx[4];
	vtx[0].x = pts[0][0];
	vtx[0].y = pts[0][1];
	vtx[0].z = 0;
	vtx[0].color = colors[0];
	
	vtx[1].x = pts[1][0];
	vtx[1].y = pts[1][1];
	vtx[1].z = 0;
	vtx[1].color = colors[1];
	
	vtx[2].x = pts[2][0];
	vtx[2].y = pts[2][1];
	vtx[2].z = 0;
	vtx[2].color = colors[2];
	
	vtx[3].x = pts[3][0];
	vtx[3].y = pts[3][1];
	vtx[3].z = 0;
	vtx[3].color = colors[3];
	
	al_draw_prim(cast(void*)(vtx.ptr), null, null, 0, 4, ALLEGRO_PRIM_TYPE.ALLEGRO_PRIM_TRIANGLE_FAN);	
}

void DrawGradientLine(SVector2D start, SVector2D end, ALLEGRO_COLOR color_start, ALLEGRO_COLOR color_end)
{
	ALLEGRO_VERTEX vtx[2];
	vtx[0].x = start.X;
	vtx[0].y = start.Y;
	vtx[0].z = 0;
	vtx[0].color = color_start;
	
	vtx[1].x = end.X;
	vtx[1].y = end.Y;
	vtx[1].z = 0;
	vtx[1].color = color_end;
	
	al_draw_prim(cast(void*)(vtx.ptr), null, null, 0, 2, ALLEGRO_PRIM_TYPE.ALLEGRO_PRIM_LINE_LIST);	
}
