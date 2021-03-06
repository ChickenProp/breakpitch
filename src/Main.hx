import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.system.Security;
import flash.system.SecurityPanel;

class Main extends Engine
{

	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 480;
	public static inline var kFrameRate:Int = 30;
	public static inline var kClearColor:Int = 0x333333;
	public static inline var kProjectName:String = "HaxePunk";

	public static var debugMode:Bool = false;

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

		HXP.defaultFont = "font/orbitron-medium.ttf";

		G.init();
		Pitch.init();
		Audio.init();

		if (G.mic == null)
			return;

		if (G.mic.muted)
			Security.showSettings(SecurityPanel.PRIVACY);

		G.mic.setSilenceLevel(0);

		HXP.world = new TitleScreen();
	}

	override public function update () : Void {
		super.update();
		
		Audio.update();

		if (Input.check(Key.F1))
			debugMode = true;

		if (Input.check(Key.F5))
			HXP.console.enable();

		if (Input.pressed(Key.P))
			HXP.world.active = ! HXP.world.active;
	}

	public static function main()
	{
		new Main();
	}
}
