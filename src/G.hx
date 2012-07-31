import flash.media.Microphone;
import com.haxepunk.utils.Data;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.Image;
import flash.display.BitmapData;

class G {
	public static var score(getScore, setScore):Int;
	public static var hiscore(getHiscore, null):Int;

	public static var mic:Microphone;

	public static var particleImage:BitmapData;
	public static var emitter:Emitter;

	public static var paddle:Paddle;

	public static function init () : Void {
		mic = Microphone.getMicrophone();

		Data.id = "philh-arkanoise";
		Data.load();
		_hiscore = Data.readInt("hiscore");

		particleImage = HXP.createBitmap(2, 2, false, 0xFFFFFF);
		emitter = new Emitter(particleImage);
		emitter.newType("block");
		emitter.setGravity("block", 1);
		emitter.setColor("block", 0x000000, 0x000000);
		emitter.setAlpha("block", 1, 0);
		emitter.setMotion("block", 0, 40, 1, 30, 10, 0.1);
	}

	public static function bounceEase (t:Float) : Float {
		var peak = 0.7;
		if (t < peak)
			return 1.2 * Math.sin(Math.PI*t / 1.6);
		else {
			var phase = (t - peak) / (1 - peak); // [0, 1]
			return 1.2 - 0.1 * (1 - Math.cos(Math.PI * phase));
		}
	}

	static var _score:Int = 0;
	static var _hiscore:Int = 0;
	static function getScore () { return _score; }
	static function setScore (s) {
		var newballs = extraLives(s) - extraLives(_score);
		for (i in 0...newballs) {
			cast(HXP.world, BreakoutWorld).gainLife();
			Audio.play("newlife");
		}

		_score = s;
		if (s > _hiscore) {
			_hiscore = s;
			Data.write("hiscore", s);
			Data.save();
		}
		return s;
	}
	static function getHiscore () { return _hiscore; }

	// How many extra lives do we get by the time we reach score s?
	static function extraLives (s:Int) {
		if (s < 500)
			return 0;
		else if (s < 1000)
			return 1;
		else
			return Std.int(s/1000)+1;
	}
}
