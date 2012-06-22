import com.haxepunk.Engine;
import com.haxepunk.HXP;
import flash.system.Security;
import flash.system.SecurityPanel;
import flash.media.Microphone;

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

		Security.showSettings(SecurityPanel.PRIVACY);

		var mic = Microphone.getMicrophone();
		trace(mic);

		if (mic != null) {
			mic.setLoopBack(true);
		}
	}

	public static function main()
	{
		new Main();
	}

}
