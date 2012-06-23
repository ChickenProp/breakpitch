package hxop;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Compiler 
{
	static public function overload(paths:Array<String>, opsClass:String)
	{
		for (path in paths)
			traverse(path, "", opsClass);
	}
	
	static function traverse(cp:String, pack:String, opsClass:String)
	{
		for (file in neko.FileSystem.readDirectory(cp))
		{
			if (StringTools.endsWith(file, ".hx"))
			{
				var cl = (pack == "" ? "" : pack + ".") + file.substr(0, file.length - 3);
				try
				{
					haxe.macro.Compiler.addMetadata("@:build(hxop.engine.OverloadTransformer.build('" +opsClass+ "'))", cl);
				} catch (e:Dynamic)
				{
				}
			}
			else if(neko.FileSystem.isDirectory(cp + "/" + file))
				traverse(cp + "/" + file, pack == "" ? file : pack + "." +file, opsClass);
		}
	}
}

#end