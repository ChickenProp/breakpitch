import com.haxepunk.World;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Image;
import com.haxepunk.Tween;
import nme.display.BitmapData;
import nme.geom.ColorTransform;
import nme.geom.Point;
import flash.display.Sprite;
import flash.text.StyleSheet;
import flash.text.TextFormat;
import flash.text.TextField;
using Lambda;

class TitleScreen extends World {
	public var width:Int;
	public var height:Int;
	
	public var sprite:Sprite;

	public function new () {
		super();
		width = 550;
		height = 450;
		
		var title = new Image("gfx/title.png");
		
		title.x = HXP.width * 0.5;
		title.y = title.height;
		title.centerOO();
		
		addGraphic(title);
		
		sprite = new Sprite();
		
		var css1:String = 'a:hover { text-decoration: underline; } 
					a { text-decoration: none; color: #FFFF00; }';
		
		var credits1:TextField = makeHTMLText(
			//'Created by <a href="http://www.draknek.org/" target="_blank">Alan</a> and <a href="http://philh.net/" target="_blank">Phil</a> Hazelden',
			'Created by Alan and Phil Hazelden',
			16, 0x404040, css1
		);
		var credits2:TextField = makeHTMLText(
			'Music: Synthesis by Celestial Aeon Project',
			16, 0x404040, css1
		);
		
		var credits3:TextField = makeHTMLText(
			'Logo: Scott Roberts',
			16, 0x404040, css1
		);
		
		credits1.y = 200;
		credits2.y = 220;
		credits3.y = 240;
		
		sprite.addChild(credits1);
		sprite.addChild(credits2);
		sprite.addChild(credits3);
	}

	override public function update () : Void {
		super.update();

		if (! G.paddle.needsCalibration) {
			HXP.world = new BreakoutWorld(0);
		}
	}

	override public function render () : Void {
		Draw.rect(Std.int( (HXP.width - width)/2 ),
		          HXP.height - height,
		          width, height,
		          0xCCCCFF);

		super.render();
	}
	
	private var audioTween:Tween;
	
	override public function begin () : Void {
		G.paddle = new Paddle();
		add(G.paddle);
		G.paddle.recenter();
		
		audioTween = HXP.tween(Audio, {musicVolume: 0.0}, 3.0);
		
		HXP.engine.addChild(sprite);
	}
	
	override public function end () : Void {
		Audio.music.loop();
		Audio.musicVolume = 1.0;
		HXP.tweener.removeTween(audioTween);
		
		HXP.engine.removeChild(sprite);
	}
	
	
	public static function makeHTMLText (html:String, size:Float, color:UInt, css:String): TextField
	{
		//var ss:StyleSheet = new StyleSheet();
		//ss.parseCSS(css);
		
		var textField:TextField = new TextField();
		
		textField.selectable = false;
		textField.mouseEnabled = true;
		
		textField.embedFonts = true;
		
		textField.autoSize = flash.text.TextFieldAutoSize.CENTER;
		
		textField.textColor = color;
		
		var fontObj = nme.Assets.getFont(HXP.defaultFont);
		
		textField.defaultTextFormat = new TextFormat(fontObj.fontName, size);
		
		//textField.htmlText = html;
		textField.text = html;
		
		//textField.styleSheet = ss;
		
		textField.x = (HXP.width - textField.width) * 0.5;
		
		return textField;
	}
}
