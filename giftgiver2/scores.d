module giftgiver2.scores;

import giftgiver2.config;

import tango.text.convert.Integer;
import tango.core.Array;
import tango.io.Stdout;

struct SScoreEntry
{
	char[] Name;
	int Score;
}

bool ScoreComp(SScoreEntry e1, SScoreEntry e2)
{
	return e1.Score > e2.Score;
}

SScoreEntry[10] Scores;
char[] CandidateName = "Santa";
int CandidateScore = 0;

/*
 * Returns true if its high enough
 */
bool SetHighScore(int score)
{
	if(score > Scores[$ - 1].Score)
	{
		CandidateScore = score;
		return true;
	}
	else
		return false;
}

void UpdateHighScores()
{
	//auto temp_scores = Scores ~ SScoreEntry(CandidateName.dup, CandidateScore);
	SScoreEntry[11] temp_scores;
	
	foreach(ii, ref entry; temp_scores)
	{
		if(ii < 10)
		{
			entry.Name = Scores[ii].Name.dup;
			entry.Score = Scores[ii].Score;
		}
		else
		{
			entry.Name = CandidateName.dup;
			entry.Score = CandidateScore;
		}
	}
	
	foreach(ref entry; temp_scores)
	{
		if(!entry.Name.ptr)
			entry.Name = "";
	}
	
	sort(temp_scores, &ScoreComp);
	Scores[] = temp_scores[0..10];
}

void Init()
{
	char[][] default_names = ["Bob",
	                      "Jeremy",
	                      "Alfred",
	                      "Hess",
	                      "Rudolph",
	                      "Blingie",
	                      "James",
	                      "Mary",
	                      "Margot",
	                      "Fizzie"];
	auto default_scores = [50000,
	                       40000,
	                       30000,
	                       25000,
	                       20000,
	                       15000,
	                       10000,
	                       5000,
	                       2000,
	                       1000];
	
	auto config = new CConfiguration("scores.ini");
	CandidateName = config.GetString("", "name", "Santa");
	for(int ii = 0; ii < 10; ii++)
	{
		auto key = toString(ii);
		Scores[ii].Name = config.GetString("", key, default_names[ii]);
		key ~= "s";
		Scores[ii].Score = config.GetInt("", key, default_scores[ii]);
	}
	sort(Scores, &ScoreComp);
}

void DeInit()
{
	auto config = new CConfiguration();
	config.PutString("", "name", CandidateName);
	
	for(int ii = 0; ii < 10; ii++)
	{
		auto key = toString(ii);
		config.PutString("", key, Scores[ii].Name);
		key ~= "s";
		config.PutInt("", key, Scores[ii].Score);
	}
	
	config.Save("scores.ini");
}
