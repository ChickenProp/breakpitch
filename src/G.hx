import flash.media.Microphone;
import com.haxepunk.utils.Data;

class G {
	public static var score(getScore, setScore):Int;
	public static var hiscore(getHiscore, null):Int;

	public static var mic:Microphone;

	public static function init () : Void {
		mic = Microphone.getMicrophone();

		Data.id = "philh-arkanoise";
		Data.load();
		_hiscore = Data.readInt("hiscore");
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
