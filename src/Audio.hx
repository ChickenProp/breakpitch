import com.haxepunk.Sfx;

class Audio
{
	private static var sounds = {};
	
	public static var music:Sfx;
	
	public static function init ():Void
	{
		music = new Sfx("music/music.mp3");
		
		music.loop();
		
		//FP.stage.addEventListener(Event.ACTIVATE, focusGain);
		//FP.stage.addEventListener(Event.DEACTIVATE, focusLost);
	}
	
	public static function play (sound:String):Void
	{
		if (! Reflect.field(sounds, sound)) {
			Reflect.setField(sounds, sound, new Sfx("sfx/" + sound + ".mp3"));
		}
		
		if (Reflect.field(sounds, sound)) {
			Reflect.field(sounds, sound).play();
		}
	}
	
	/*private static function focusGain (e:Event):void
	{
		if (! music.playing) music.resume();
	}
	
	private static function focusLost (e:Event):void
	{
		if (Main.touchscreen || FP.stage.displayState != StageDisplayState.FULL_SCREEN) {
			music.stop();
		}
	}*/
}
