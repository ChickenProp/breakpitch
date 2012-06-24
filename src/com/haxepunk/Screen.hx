package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import com.haxepunk.graphics.Image;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 */
class Screen
{
	/**
	 * Constructor.
	 */
	public function new()
	{
		init();

		// create screen buffers
		HXP.engine.addChild(_sprite);

		//Added this so that the tilesheet can use a graphics object which is in front of the ones used by software rendering
#if cpp
		HXP.engine.addChild(HXP.sprite);
#end
	}

	public function init()
	{
		_sprite = new Sprite();
		_bitmap = new Array<Bitmap>();
		x = y = originX = originY = 0;
		_angle = _current = 0;
		scale = scaleX = scaleY = 1;
		_color = 0x202020;
		_matrix = new Matrix();
		update();
	}

	/**
	 * Resizes the screen by recreating the bitmap buffer
	 * @param width the width of the screen
	 * @param height the height of the screen
	 */
	public function resize()
	{
		if (_bitmap[0] != null)
		{
			_sprite.removeChild(_bitmap[0]);
			_sprite.removeChild(_bitmap[1]);

			_bitmap[0].bitmapData.dispose();
			_bitmap[1].bitmapData.dispose();
		}

		width = HXP.width;
		height = HXP.height;

		_bitmap[0] = new Bitmap(HXP.createBitmap(width, height), PixelSnapping.NEVER);
		_bitmap[1] = new Bitmap(HXP.createBitmap(width, height), PixelSnapping.NEVER);

		_sprite.addChild(_bitmap[0]).visible = true;
		_sprite.addChild(_bitmap[1]).visible = false;
		HXP.buffer = _bitmap[0].bitmapData;

		_current = 0;
	}

	/**
	 * Swaps screen buffers.
	 */
	public function swap()
	{
		_current = 1 - _current;
		HXP.buffer = _bitmap[_current].bitmapData;
	}

	public function addFilter(filter:Array<BitmapFilter>)
	{
		_sprite.filters = filter;
	}

	/**
	 * Refreshes the screen.
	 */
	public function refresh()
	{
		// refreshes the screen
#if neko
		HXP.buffer.fillRect(HXP.bounds, { rgb: _color, a: 1 });
#else
		HXP.buffer.fillRect(HXP.bounds, _color);
#end
	}

	/**
	 * Redraws the screen.
	 */
	public function redraw()
	{
		// refresh the buffers
		_bitmap[_current].visible = true;
		_bitmap[1 - _current].visible = false;
	}

	/** @private Re-applies transformation matrix. */
	public function update()
	{
		if (_matrix == null) return; // prevent update on init
		_matrix.b = _matrix.c = 0;
		_matrix.a = scaleX * scale;
		_matrix.d = scaleY * scale;
		_matrix.tx = -originX * _matrix.a;
		_matrix.ty = -originY * _matrix.d;
		if (_angle != 0) _matrix.rotate(_angle);
		_matrix.tx += originX * scaleX * scale + x;
		_matrix.ty += originY * scaleX * scale + y;
		_sprite.transform.matrix = _matrix;
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color(getColor, setColor):Int;
	private function getColor():Int { return _color; }
	private function setColor(value:Int):Int { _color = 0xFF000000 | value; return _color; }

	/**
	 * X offset of the screen.
	 */
	public var x(default, setX):Int;
	private function setX(value:Int):Int
	{
		if (x == value) return value;
		x = value;
		update();
		return x;
	}

	/**
	 * Y offset of the screen.
	 */
	public var y(default, setY):Int;
	private function setY(value:Int):Int
	{
		if (y == value) return value;
		y = value;
		update();
		return y;
	}

	/**
	 * X origin of transformations.
	 */
	public var originX(default, setOriginX):Int;
	private function setOriginX(value:Int):Int
	{
		if (originX == value) return value;
		originX = value;
		update();
		return originX;
	}

	/**
	 * Y origin of transformations.
	 */
	public var originY(default, setOriginY):Int;
	private function setOriginY(value:Int):Int
	{
		if (originY == value) return value;
		originY = value;
		update();
		return originY;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, setScaleX):Float;
	private function setScaleX(value:Float):Float
	{
		if (scaleX == value) return value;
		scaleX = value;
		update();
		return scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, setScaleY):Float;
	private function setScaleY(value:Float):Float
	{
		if (scaleY == value) return value;
		scaleY = value;
		update();
		return scaleY;
	}

	/**
	 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
	 * you can use this factor to scale the screen both horizontally and vertically.
	 */
	public var scale(default, setScale):Float;
	private function setScale(value:Float):Float
	{
		if (scale == value) return value;
		scale = value;
		update();
		return scale;
	}

	/**
	 * Rotation of the screen, in degrees.
	 */
	public var angle(getAngle, setAngle):Float;
	private function getAngle():Float { return _angle * HXP.DEG; }
	private function setAngle(value:Float):Float
	{
		if (_angle == value * HXP.RAD) return value;
		_angle = value * HXP.RAD;
		update();
		return _angle;
	}

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(getSmoothing, setSmoothing):Bool;
	private function getSmoothing():Bool { return _bitmap[0].smoothing; }
	private function setSmoothing(value:Bool):Bool { _bitmap[0].smoothing = _bitmap[1].smoothing = value; return value; }

	/**
	 * Width of the screen.
	 */
	public var width(default, null):Int;

	/**
	 * Height of the screen.
	 */
	public var height(default, null):Int;

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(getMouseX, null):Int;
	private function getMouseX():Int { return Std.int((HXP.stage.mouseX - x) / (scaleX * scale)); }

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(getMouseY, null):Int;
	private function getMouseY():Int { return Std.int((HXP.stage.mouseY - y) / (scaleY * scale)); }

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		return new Image(_bitmap[_current].bitmapData.clone());
	}

	// Screen infromation.
	private var _sprite:Sprite;
	private var _bitmap:Array<Bitmap>;
	private var _current:Int;
	private var _matrix:Matrix;
	private var _angle:Float;
	private var _color:Int;
}