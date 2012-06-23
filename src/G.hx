import flash.media.Microphone;

class G {
	public static var mic:Microphone;

	public static function init () : Void {
		mic = Microphone.getMicrophone();
	}
}
