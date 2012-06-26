import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

class ScoreDisplay extends Entity {
	var score:Text;
	var hiscore:Text;
	public function new () {
		super();
		score = new Text("                  ", 350, 10);
		hiscore = new Text("                   ", 470, 10);
		addGraphic(score);
		addGraphic(hiscore);
	}

	override public function update () : Void {
		score.text = Std.format("Score: ${G.score}");
		hiscore.text = Std.format("HiScore: ${G.hiscore}");
		super.update();
	}
}
