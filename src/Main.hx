import com.haxepunk.Engine;
import com.haxepunk.HXP;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.media.Microphone;
import flash.events.ActivityEvent;
import flash.events.StatusEvent;
import flash.events.SampleDataEvent;

class Main extends Engine
{

	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 480;
	public static inline var kFrameRate:Int = 30;
	public static inline var kClearColor:Int = 0x333333;
	public static inline var kProjectName:String = "HaxePunk";

	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
	}

	override public function init()
	{
#if debug
	#if flash
		if (flash.system.Capabilities.isDebugger)
	#end
		{
			HXP.console.enable();
		}
#end
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;
//		HXP.world = new YourWorld();

		var mic = Microphone.getMicrophone();
		trace(mic);

		if (mic == null)
			return;

		if (mic.muted)
			Security.showSettings(SecurityPanel.PRIVACY);

		mic.setSilenceLevel(0);

		mic.setLoopBack(true);
		mic.addEventListener(ActivityEvent.ACTIVITY,
		                     activityHandler);
		mic.addEventListener(StatusEvent.STATUS,
		                     statusHandler);
		mic.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                     sampleHandler);
	}

	public static function main()
	{
		new Main();
	}

	public function activityHandler (ev) : Void {
		trace("activity!");
	}

	public function statusHandler (ev) : Void {
		trace("status!");
	}

	public function sampleHandler (ev) : Void {
		trace(ev.data.readFloat());
	}
}
