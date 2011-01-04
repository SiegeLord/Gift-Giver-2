module main;

import giftgiver2.game;

import tango.io.Stdout;

int main(char[][] args)
{
	try
	{
		Init();
		Run();
		DeInit();
	}
	catch(Exception e)
	{
		Stdout.formatln(e.msg);
	}
	return 0;
}
