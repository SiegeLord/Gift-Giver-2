module giftgiver2.mathtypes;

import tango.math.Math;
import tango.math.IEEE;
import tango.io.Stdout;

struct SVector2D
{
	float X = 0;
	float Y = 0;
	
	void Set(float x, float y)
	{
		X = x;
		Y = y;
	}

	void Rotate(float cosine, float sine)
	{
		float t = X * cosine - Y * sine;
		Y = X * sine + Y * cosine;
		X = t;
	}
	
	void Rotate(float theta)
	{
		Rotate(cos(theta), sin(theta));
	}
	
	//rotates this vector by pi/2
	void MakeNormal()
	{
		float t = Y;
		Y = X;
		X = -t;
	}
	
	float DotProduct(SVector2D other)
	{
		return X * other.X + Y * other.Y;
	}
	
	float CrossProduct(SVector2D other)
	{
		return X * other.Y - Y * other.X;
	}
	
	float GetLength()
	{
		return hypot(X, Y);
	}
	
	float GetLengthSq()
	{
		return X * X + Y * Y;
	}
	
	SVector2D opAdd(SVector2D other)
	{
		return SVector2D(X + other.X, Y + other.Y);
	}
	
	SVector2D opSub(SVector2D other)
	{
		return SVector2D(X - other.X, Y - other.Y);
	}
	
	SVector2D opMul(float n)
	{
		return SVector2D(X * n, Y * n);
	}
	
	SVector2D opDiv(float n)
	{
		return SVector2D(X / n, Y / n);
	}
	
	void opAddAssign(SVector2D other)
	{
		X += other.X;
		Y += other.Y;
	}
	
	void opSubAssign(SVector2D other)
	{
		X -= other.X;
		Y -= other.Y;
	}
	
	void opMulAssign(float n)
	{
		X *= n;
		Y *= n;
	}
	
	void opDivAssign(float n)
	{
		X /= n;
		Y /= n;
	}
	
	bool opEquals(SVector2D other)
	{
		return feqrel(X, other.X) && feqrel(Y, other.Y);
	}

	SVector2D opNeg()
	{
		return SVector2D(-X, -Y);
	}

	void Normalize()
	{
		*this /= GetLength();
	}
	
	float opIndex(size_t i)
	{
		if(i == 0)
			return X;
		else
			return Y;	
	}
	
	float opIndexAssign(float val, size_t i)
	{
		if(i == 0)
		{
			X = val;
			return X;
		}
		else
		{
			Y = val;
			return Y;
		}
	}
}

const SVector2D g_v2dZero = SVector2D(0, 0);
const SVector2D g_v2dI = SVector2D(1, 0);
const SVector2D g_v2dJ = SVector2D(0, 1);

struct SRect
{
	SVector2D Min;
	SVector2D Max;

	static SRect opCall(SVector2D min, SVector2D max)
	{
		SRect rect;
		rect.Min = min;
		rect.Max = max;
		return rect;
	}
	
	static SRect opCall(float min_x, float min_y, float max_x, float max_y)
	{
		return SRect(SVector2D(min_x, min_y), SVector2D(max_x, max_y));
	}
	
	void Set(float min_x, float min_y, float max_x, float max_y)
	{
		Min.Set(min_x, min_y);
		Max.Set(max_x, max_y);
	}
	
	void Set(SVector2D min, SVector2D max)
	{
		Min = min;
		Max = max;
	}

	void Fix()
	{
		float t;
		if(Max.X < Min.X)
		{
			t = Max.X;
			Max.X = Min.X;
			Min.X = t;
		}
		if(Max.Y < Min.Y)
		{
			t = Max.Y;
			Max.Y = Min.Y;
			Min.Y = t;
		}
	}
	/*
	Clips this rectangle against the other rectangle, such that at the end this rectangle is wholly contained inside the other one
	*/
	void Clip(SRect other)
	{
		if(Max.Y > other.Max.Y)
			Max.Y = other.Max.Y;
			
		if(Max.X > other.Max.X)
			Max.X = other.Max.X;
			
		if(Min.Y < other.Min.Y)
			Min.Y = other.Min.Y;
			
		if(Min.X < other.Min.X)
			Min.X = other.Min.X;
	}
	
	/*
	Enlarges the rectangle to hold the passed point
	*/
	void AddPoint(SVector2D point)
	{
		if(point.X > Max.X)
			Max.X = point.X;
			
		if(point.Y > Max.Y)
			Max.Y = point.Y;
			
		if(point.X < Min.X)
			Min.X = point.X;
			
		if(point.Y < Min.Y)
			Min.Y = point.Y;
	}
	/*
	Enlarges the rectangle to hold the passed rectangle
	*/
	void AddRect(SRect rect)
	{
		AddPoint(rect.Min);
		AddPoint(rect.Max);
	}
	/*
	Sees if the two rectangles intersect
	*/
	bool IntersectTest(SRect other)
	{
		return Max.X > other.Min.X && Max.Y > other.Min.Y && Min.X < other.Max.X && Min.Y < other.Max.Y;
	}
	/*
	Sees if the passed rectangle is entirely inside this rectangle
	*/
	bool InsideTest(SRect other)
	{
		return Min.X < other.Min.X && Min.Y < other.Min.Y && Max.X > other.Max.X && Max.Y > other.Max.Y;
	}
	/*
	Sees if the passed point is inside the rectangle
	*/
	bool PointTest(SVector2D vec)
	{
		return vec.X > Min.X && vec.X < Max.X && vec.Y > Min.Y && vec.Y < Max.Y;
	}
	/*
	Resets it to 0
	*/
	void Reset()
	{
		Min = g_v2dZero;
		Max = g_v2dZero;
	}
	
	float Width()
	{
		return Max.X - Min.X;	
	}
	
	float Height()
	{
		return Max.X - Min.Y;	
	}
	/*
	Make sure to fix both rectangles first!
	*/
	bool opEquals(SRect other)
	{
		return other.Min == Min && other.Max == Max;
	}
	
	void opAddAssign(SRect other)
	{
		AddRect(other);	
	}
	
	void opAddAssign(SVector2D other)
	{
		AddPoint(other);	
	}
	
	void Translate(SVector2D other)
	{
		Min += other;
		Max += other;
	}
}

/*
Forces the angle to be between 0 and 2 PI
*/
float FixAngle(float angle)
{
	if(angle < 0 || angle > 2 * PI)
	{
		return angle - floor(angle / (2 * PI)) * 2 * PI;
	}
	return angle;
}

/*
Subtracts angle2 from angle1 and returns the real distance between them
*/
float SubtractAngles(float angle1, float angle2)
{
	return FixAngle(angle1 + PI - angle2) - PI;
}
