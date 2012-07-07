import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

class ScoreDisplay extends Entity {
	var score:Text;
	var hiscore:Text;
	var dispScore:Int;
	var dispHiscore:Int;
	public function new () {
		super();
		score = new Text("                  ", 350, 10);
		hiscore = new Text("                   ", 470, 10);
		addGraphic(score);
		addGraphic(hiscore);
		dispScore = 0;
		dispHiscore = G.hiscore;
	}

	override public function update () : Void {
		if (dispScore < G.score)
			dispScore++;
		if (dispHiscore < dispScore)
			dispHiscore = dispScore;

		score.text = Std.format("Score: $dispScore");
		hiscore.text = Std.format("HiScore: $dispHiscore");
		super.update();
	}
}
