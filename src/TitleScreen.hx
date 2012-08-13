import com.haxepunk.World;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
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
					a { text-decoration: none; color: #000000; }';
		
		var credits1:TextField = makeHTMLText(
			'Created by <a href="http://www.draknek.org/" target="_blank">Alan</a> and <a href="http://philh.net/" target="_blank">Phil</a> Hazelden',
			16, 0x404040, css1
		);
		var credits2:TextField = makeHTMLText(
			'Music: <a href="http://www.jamendo.com/en/track/727910/synthesis" target="_blank">Synthesis</a> by <a href="http://www.jamendo.com/en/artist/2740/celestial-aeon-project" target="_blank">Celestial Aeon Project</a>',
			16, 0x404040, css1
		);
		
		var credits3:TextField = makeHTMLText(
			'Logo: <a href="https://twitter.com/BraveWorksScott" target="_blank">Scott Roberts</a>',
			16, 0x404040, css1
		);
		
		credits1.y = 200;
		credits2.y = 220;
		credits3.y = 240;
		
		sprite.addChild(credits1);
		sprite.addChild(credits2);
		sprite.addChild(credits3);
		
		var score = G.score;
		
		if (score > 0) {
			var scoreText = new Text(Std.format("Score: $score"), HXP.width*0.5, 300);
			scoreText.resizable = true;
			scoreText.color = 0x0;
			scoreText.size = 24;
			
			scoreText.centerOO();
			
			addGraphic(scoreText);
			
			scoreText = new Text(Std.format("High score: ${G.hiscore}"), HXP.width*0.5, 330);
			scoreText.resizable = true;
			scoreText.color = 0x0;
			scoreText.size = 24;
			
			scoreText.centerOO();
			
			addGraphic(scoreText);
		}
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
		var ss:StyleSheet = new StyleSheet();
		ss.parseCSS(css);
		
		var textField:TextField = new TextField();
		
		textField.selectable = false;
		textField.mouseEnabled = true;
		
		textField.embedFonts = true;
		
		textField.autoSize = flash.text.TextFieldAutoSize.CENTER;
		
		textField.textColor = color;
		
		var fontObj = nme.Assets.getFont(HXP.defaultFont);
		
		textField.defaultTextFormat = new TextFormat(fontObj.fontName, size);
		
		textField.htmlText = html;
		
		textField.styleSheet = ss;
		
		textField.x = (HXP.width - textField.width) * 0.5;
		
		return textField;
	}
}
