import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

class ScoreDisplay extends Entity {
	var score:Text;
	var hiscore:Text;
	var dispScore:Int;
	var dispHiscore:Int;
	public function new () {
		super();
		score = new Text("", 300, 7, HXP.width, 30);
		hiscore = new Text("", 470, 7, HXP.width, 30);
		addGraphic(score);
		addGraphic(hiscore);
		dispScore = 0;
		dispHiscore = G.hiscore;
	}

	override public function update () : Void {
		if (dispScore < G.score)
			dispScore += Math.ceil((G.score - dispScore) / 10);
		if (dispHiscore < dispScore)
			dispHiscore = dispScore;

		score.text = Std.format("Score: $dispScore");
		hiscore.text = Std.format("HiScore: $dispHiscore");
		super.update();
	}
}
