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

	static var _score:Int = 0;
	static var _hiscore:Int = 0;
	static function getScore () { return _score; }
	static function setScore (s) {
		_score = s;
		if (s > _hiscore) {
			_hiscore = s;
			Data.write("hiscore", s);
			Data.save();
		}
		return s;
	}
	static function getHiscore () { return _hiscore; }
}
