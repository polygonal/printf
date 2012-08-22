
/*
 *                            _/                                                    _/   
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/    
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/     
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/      
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/       
 *   _/                            _/        _/                                          
 *  _/                        _/_/      _/_/                                             
 *                                                                                       
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.polygonal.core.fmt;

import haxe.EnumFlags;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

using de.polygonal.core.fmt.NumberFormat;
using de.polygonal.core.math.Mathematics;
using de.polygonal.core.fmt.ASCII;

/**
 * <p>A C sprintf implementation.</p>
 * <p>See <a href="http://www.cplusplus.com/reference/clibrary/cstdio/sprintf.html" target="_blank">http://www.cplusplus.com/reference/clibrary/cstdio/sprintf.html</a> for a complete reference.</p>
 */
class Sprintf
{
	var formatHash:IntHash< Dynamic >;
	
	static var dataTypeHash:IntHash<FormatDataType> = makeDataTypeHash();
	
	private static function makeDataTypeHash()
	{
		var hash:IntHash<FormatDataType> = new IntHash();
		hash.set("i".code, FmtInteger(ISignedDecimal));
		hash.set("d".code, FmtInteger(ISignedDecimal));
		hash.set("u".code, FmtInteger(IUnsignedDecimal));
		hash.set("c".code, FmtInteger(ICharacter));
		hash.set("x".code, FmtInteger(IHex));
		hash.set("X".code, FmtInteger(IHex));
		hash.set("o".code, FmtInteger(IOctal));
		hash.set("b".code, FmtInteger(IBin));
		
		hash.set("f".code, FmtFloat(FNormal));
		hash.set("e".code, FmtFloat(FScientific));
		hash.set("E".code, FmtFloat(FScientific));
		hash.set("g".code, FmtFloat(FNatural));
		hash.set("G".code, FmtFloat(FNatural));
		
		hash.set("s".code, FmtString);
		
		hash.set("p".code, FmtPointer);
		hash.set("n".code, FmtNothing);
		
		return hash;
	}
	
	static var _instance:Sprintf = null;
	
	var formatIntFuncHash:IntHash < Int->FormatArgs->String >;
	var formatFloatFuncHash:IntHash < Float->FormatArgs->String >;
	var formatStringFuncHash:IntHash < String->FormatArgs->String >;
	
	#if macro
	var formatIntFuncNameHash:IntHash < String>;
	var formatFloatFuncNameHash:IntHash < String >;
	var formatStringFuncNameHash:IntHash < String > ;
	
	function makeNameHashes()
	{
		formatIntFuncNameHash = new IntHash();
		formatFloatFuncNameHash = new IntHash();
		formatStringFuncNameHash = new IntHash();
		
		formatIntFuncNameHash.set(std.Type.enumIndex(ISignedDecimal), "formatSignedDecimal");
		formatIntFuncNameHash.set(std.Type.enumIndex(IUnsignedDecimal), "formatUnsignedDecimal");
		formatIntFuncNameHash.set(std.Type.enumIndex(ICharacter), "formatCharacter");
		formatIntFuncNameHash.set(std.Type.enumIndex(IHex), "formatHex");
		formatIntFuncNameHash.set(std.Type.enumIndex(IOctal), "formatOctal");
		formatIntFuncNameHash.set(std.Type.enumIndex(IBin), "formatBin");
		
		formatFloatFuncNameHash.set(std.Type.enumIndex(FNormal), "formatNormalFloat");
		formatFloatFuncNameHash.set(std.Type.enumIndex(FScientific), "formatScientific");
		formatFloatFuncNameHash.set(std.Type.enumIndex(FNatural), "formatNaturalFloat");
		
		formatStringFuncNameHash.set(std.Type.enumIndex(FmtString), "formatString");
	}
	#end
	
	function new()
	{
		formatIntFuncHash = new IntHash();
		formatFloatFuncHash = new IntHash();
		formatStringFuncHash = new IntHash();
		
		formatIntFuncHash.set(std.Type.enumIndex(ISignedDecimal), formatSignedDecimal);
		formatIntFuncHash.set(std.Type.enumIndex(IUnsignedDecimal), formatUnsignedDecimal);
		formatIntFuncHash.set(std.Type.enumIndex(ICharacter), formatCharacter);
		formatIntFuncHash.set(std.Type.enumIndex(IHex), formatHex);
		formatIntFuncHash.set(std.Type.enumIndex(IOctal), formatOctal);
		formatIntFuncHash.set(std.Type.enumIndex(IBin), formatBin);
		
		formatFloatFuncHash.set(std.Type.enumIndex(FNormal), formatNormalFloat);
		formatFloatFuncHash.set(std.Type.enumIndex(FScientific), formatScientific);
		formatFloatFuncHash.set(std.Type.enumIndex(FNatural), formatNaturalFloat);
		
		formatStringFuncHash.set(std.Type.enumIndex(FmtString), formatString);
		
		#if macro
		makeNameHashes();
		#end
	}
	
	/**
	 * Writes formatted data to a string.
	 * @param fmt the string that contains the formatted text.<br/>
	 * It can optionally contain embedded format tags that are substituted by the values specified in subsequent argument(s) and formatted as requested.<br/>
	 * The number of arguments following the format parameters should at least be as much as the number of format tags.<br/>
	 * The format tags follow this prototype: '%[flags][width][.precision][length]specifier'.
	 * @param arg depending on the format string, the function may expect a sequence of additional arguments, each containing one value to be inserted instead of each %-tag specified in the format parameter, if any.<br/>
	 * The argument array length should match the number of %-tags that expect a value.
	 * @return the formatted string.
	 */
	@:macro public static function format(_fmt:ExprOf<String>, _passedArgs:Array<Expr>):ExprOf<String>
	{
		var error = false;
		switch(Context.typeof(_fmt))
		{
		case TInst(t, _):
			error = t.get().name != "String";
		default:
			error = true;
		}
		
		if (error)
			Context.error("Format should be a string", _fmt.pos);
		
		var _args:ExprOf<Array<Dynamic>>;
		if (_passedArgs == null || _passedArgs.length == 0)
			_args = Context.makeExpr([], Context.currentPos());
		else
		{
			var makeArray = true;
			if(_passedArgs.length == 1)
				switch(Context.typeof(_passedArgs[0]))
				{
				case TInst(t, _):
					if (t.get().name == "Array")
						makeArray = false;
				default:
					makeArray = true;
				};
			if (makeArray)
			{
				var min = Context.getPosInfos(_passedArgs[0].pos).min;
				var max = Context.getPosInfos(_passedArgs[_passedArgs.length - 1].pos).max;
				var file = Context.getPosInfos(Context.currentPos()).file;
				_args = { expr:EArrayDecl(_passedArgs), pos:Context.makePosition( { min:min, max:max, file:file } ) };
			}
			else
				_args = _passedArgs[0];
		}
		
		switch(Context.typeof(_args))
		{
		case TInst(t, _):
			error = t.get().name != "Array";
		default:
			error = true;
		}
		
		if (error)
			Context.error("Arguments should be an array", _args.pos);
		
		var fmt:String = null;
		var fmtArgs:Array<Expr> = null;
		
		switch(_fmt.expr) 
		{
		case EConst(const):
			switch(const)
			{
			case CString(valStr):
				fmt = valStr;
			default:
			}
		default:
		}
		
		switch(_args.expr)
		{
		case EArrayDecl(values):
			fmtArgs = values;
		default:
		}
		
		if(fmt == null)
			return macro de.polygonal.core.fmt.Sprintf._full_runtime_format($_fmt, $_args);
		
		var fmtTokens:Array<FormatToken> = null;
		
		try {
			fmtTokens = tokenize(fmt);
		}
		catch (e:Dynamic) {
			Context.error(Std.string(e), _fmt.pos);
		}
		
		var instanceExpr = { expr:EConst(CIdent("__sprintFInstance")), pos:Context.currentPos() };
		var outputArr:Array<Expr> = new Array();
		
		var knownArgs = fmtArgs != null;
		var argsIndex = 0;
		
		if (_instance == null)
			_instance = new Sprintf();
		
		for (token in fmtTokens)
		{
			switch(token)
			{
			case Unknown(str, pos):
				var min = Context.getPosInfos(_fmt.pos).min + pos;
				var max = min + 1;
				var file = Context.getPosInfos(Context.currentPos()).file;
				Context.error("invalid format specifier", Context.makePosition( { min:min, max:max, file:file } ));
			case BareString(str):
				outputArr.push(Context.makeExpr(str, Context.currentPos()));
			case Tag(type, args):
				var widthExpr = Context.makeExpr(args.width, Context.currentPos());
				if (args.width == null)
				{
					widthExpr = (knownArgs)?
						fmtArgs[argsIndex++]:
						{ expr:ECheckType( { expr:EArray(_args, Context.makeExpr(argsIndex++, _args.pos)), pos:_args.pos }, TPath( { sub:null, params:[], pack:[], name:"Int" } )), pos:Context.currentPos() };
					if (widthExpr == null)
						Context.error("Not enough arguments", _args.pos);
					var error = false;
					switch(widthExpr.expr)
					{
					case EConst(c):
						switch(c)
						{
						case CInt(value):
							args.width = Std.parseInt(value);
						case CIdent(value):
							switch(Context.typeof(widthExpr))
							{
							case TInst(type, _):
								error = type.get().name != "Int";
							default:
								error = true;
							}
						default:
							error = true;
						}
					default:
						switch(Context.typeof(widthExpr))
						{
						case TInst(type, _):
							error = type.get().name != "Int";
						default:
							error = true;
						}
					}
					if (error)
						Context.error("width must be an integer", widthExpr.pos);
				}
				var precisionExpr = Context.makeExpr(args.precision, Context.currentPos());
				if (args.precision == null)
				{
					precisionExpr = (knownArgs)?
						fmtArgs[argsIndex++]:
						{ expr:ECheckType( { expr:EArray(_args, Context.makeExpr(argsIndex++, _args.pos)), pos:_args.pos }, TPath( { sub:null, params:[], pack:[], name:"Int" } )), pos:Context.currentPos() };
					if (precisionExpr == null)
						Context.error("Not enough arguments", _args.pos);
					var error = false;
					switch(precisionExpr.expr)
					{
					case EConst(c):
						switch(c)
						{
						case CInt(value):
							args.precision = Std.parseInt(value);
						case CIdent(value):
							switch(Context.typeof(precisionExpr))
							{
							case TInst(type, _):
								error = type.get().name != "Int";
							default:
								error = true;
							}
						default:
							error = true;
						}
					default:
						switch(Context.typeof(precisionExpr))
						{
						case TInst(type, _):
							error = type.get().name != "Int";
						default:
							error = true;
						}
					}
					if (error)
						Context.error("precision must be an integer", precisionExpr.pos);
				}
				
				var argsExpr = { expr:EObjectDecl(
						[
							{field:"width", expr:widthExpr },
							{field:"precision", expr:precisionExpr },
							{field:"flags", expr:Context.makeExpr(args.flags.toInt(), Context.currentPos()) }
						]), pos:Context.currentPos() };
				
				var valuePos = (args.pos > -1)?args.pos:argsIndex++;
				var valueExpr = (knownArgs)?
					fmtArgs[valuePos]:
					{ expr:EArray(_args, Context.makeExpr(valuePos, _args.pos)), pos:_args.pos };
				if (valueExpr == null)
					Context.error("Not enough arguments", _args.pos);
					
				var value:Dynamic;
				
				switch(valueExpr.expr)
				{
				case EConst(const):
					switch(const)
					{
					case CFloat(cValue):
						value = Std.parseFloat(cValue);
					case CInt(cValue):
						value = Std.parseInt(cValue);
					case CString(cValue):
						value = cValue;
					default:
						value = null;
					}
				default:
					value = null;
				}
				
				var preComputable = args.precision != null && args.width != null && value != null;
				
				var outputExpr:Expr;
				
				var typeName = function(e:Expr):String {
					switch(Context.typeof(e))
					{
					case TInst(t, _):
						return (t.get().name);
					default:
						return null;
					}
				};
				
				var formatFunction:Dynamic->FormatArgs->String;
				var formatFunctionName:String;
				
				switch(type)
				{
				case FmtFloat(floatType):
					if (preComputable && !Std.is(value, Float) && !Std.is(value, Int))
						Context.error("the value must be a number", valueExpr.pos);
					formatFunction = _instance.formatFloatFuncHash.get(std.Type.enumIndex(floatType));
					formatFunctionName = _instance.formatFloatFuncNameHash.get(std.Type.enumIndex(floatType));
				case FmtInteger(integerType):
					if (preComputable && !Std.is(value, Int))
						Context.error("the value must be an integer", valueExpr.pos);
					formatFunction = _instance.formatIntFuncHash.get(std.Type.enumIndex(integerType));
					formatFunctionName = _instance.formatIntFuncNameHash.get(std.Type.enumIndex(integerType));
				case FmtString:
					formatFunction = _instance.formatStringFuncHash.get(std.Type.enumIndex(FmtString));
					formatFunctionName = _instance.formatStringFuncNameHash.get(std.Type.enumIndex(FmtString));
					
					value = Std.string(value);
					valueExpr = macro Std.string($valueExpr);
				case FmtPointer:
					Context.error("specifier 'p' is not supported", _fmt.pos);
				case FmtNothing:
					Context.error("specifier 'n' is not supported", _fmt.pos);
				}
				
				if (preComputable)
				{
					var formatedValue = formatFunction(value, args);
					outputExpr = { expr:EConst(CString(formatedValue)), pos:valueExpr.pos };
				}
				else
				{
					outputExpr = { expr:ECall( { expr:EField(instanceExpr, formatFunctionName), pos:Context.currentPos() }, [valueExpr, argsExpr]), pos:Context.currentPos() };
				}
				
				outputArr.push(outputExpr);
			}
		}
		
		if (knownArgs && fmtArgs.length > argsIndex + 1)
		{
			var min = Context.getPosInfos(fmtArgs[argsIndex].pos).min;
			var max = Context.getPosInfos(fmtArgs[fmtArgs.length - 1].pos).max;
			var file = Context.getPosInfos(Context.currentPos()).file;
			var pos = Context.makePosition( { min:min, max:max, file:file } );
			Context.warning("Extra parameters", pos);
		}
		
		var returnStrExpr:Expr = outputArr[outputArr.length - 1];
		
		for (_i in 1...outputArr.length)
		{
			var i = outputArr.length -1 - _i;
			
			returnStrExpr = { expr:EBinop(OpAdd, outputArr[i], returnStrExpr), pos:Context.currentPos() };
		}
		
		var returnBlock:Expr = macro {
			if (untyped (de.polygonal.core.fmt.Sprintf._instance) == null)
				untyped de.polygonal.core.fmt.Sprintf._instance = new de.polygonal.core.fmt.Sprintf();
			var __sprintFInstance = untyped de.polygonal.core.fmt.Sprintf._instance;
			$returnStrExpr;
		};
		
		return returnBlock;
	}
	
	
	public static function tokenize(fmt:String):Array<FormatToken>
	{
		var length = fmt.length;
		var lastStr = new StringBuf();
		var i = 0;
		var c = 0;
		var tokens:Array<FormatToken> = new Array();
		while(i < length)
		{
			var c = StringTools.fastCodeAt(fmt, i++);
			if (c == "%".code)
			{
				c = StringTools.fastCodeAt(fmt, i++);
				if (c == "%".code)
					lastStr.addChar(c);
				else
				{
					//{flush last string
					if (lastStr.toString().length > 0)
					{
						tokens.push(BareString(lastStr.toString()));
						lastStr = new StringBuf();
					}
					//}
					
					var token:FormatToken;
					var params:FormatArgs = { flags:EnumFlags.ofInt(0), pos:-1, width:-1, precision:-1 };
					//{read flags: -+(space)#0
					while (c == "-".code || c == "+".code || c == "#".code
					              || c == "0".code || c == " ".code)
					{
						if (c == "-".code)
							params.flags.set(Minus);
						else if (c == "+".code)
							params.flags.set(Plus);
						else if (c == "#".code)
							params.flags.set(Sharp);
						else if (c == "0".code)
							params.flags.set(Zero);
						else if (c == " ".code)
							params.flags.set(Space);
							
						c = StringTools.fastCodeAt(fmt, i++);
					}
					//}
					
					//{Check for conflicting flags
					if (params.flags.has(Minus) && params.flags.has(Zero))
					{
						#if macro
						Context.warning("warning: `0' flag ignored with '-' flag in printf format", Context.currentPos());
						#end
						params.flags.unset(Zero);
					}
					if (params.flags.has(Space) && params.flags.has(Plus))
					{
						#if macro
						Context.warning("warning: ` ' flag ignored with '+' flag in printf format", Context.currentPos());
						#end
						params.flags.unset(Space);
					}
					//}
					
					//{read width: (number) or "*"
					if (c == "*".code)
					{
						params.width = null;
						c = StringTools.fastCodeAt(fmt, i++);
					}
					else if (c.isDigit())
					{
						params.width = 0;
						while (c.isDigit())
						{
							params.width = c - "0".code + params.width * 10;
							c = StringTools.fastCodeAt(fmt, i++);
						}
						// Check if number was a position, not a width
						if (c == "$".code)
						{
							params.pos = params.width - 1;
							params.width = -1;
							c = StringTools.fastCodeAt(fmt, i++);
							//re-check for width
							if (c == "*".code)
							{
								params.width = null;
								c = StringTools.fastCodeAt(fmt, i++);
							}
							else if (c.isDigit())
							{
								params.width = 0;
								while (c.isDigit())
								{
									params.width = c - "0".code + params.width * 10;
									c = StringTools.fastCodeAt(fmt, i++);
								}
							}
						}
					}
					//}
					
					//{read .precision: .(number) or ".*"
					if (c == ".".code)
					{
						c = StringTools.fastCodeAt(fmt, i++);
						if (c == "*".code)
						{
							params.precision = null;
							c = StringTools.fastCodeAt(fmt, i++);
						}
						else if (c.isDigit())
						{
							params.precision = 0;
							while (c.isDigit())
							{
								params.precision = c - "0".code + params.precision * 10;
								c = StringTools.fastCodeAt(fmt, i++);
							}
						}
						else
							params.precision = 0;
					}
					//}
					
					//{read length: hlL
					while (c == "h".code || c == "l".code || c == "L".code)
					{
						switch (c)
						{
						case "h".code:
							params.flags.set(LengthH);
						case "l".code:
							params.flags.set(Lengthl);
						case "L".code:
							params.flags.set(LengthL);
						}
						c = StringTools.fastCodeAt(fmt, i++);
					}
					//}
					
					//{read specifier: cdieEfgGosuxX
					if(c == "E".code || c == "G".code)
						params.flags.set(UpperCase);
					
					var type = dataTypeHash.get(c);
					
					if (type == null)
						token = Unknown(String.fromCharCode(c), i);
					else
						token = Tag(type, params);
					
					tokens.push(token);
				}
			}
			else
			{
				lastStr.addChar(c);
			}
		}
		if (lastStr.toString().length > 0)
		{
			tokens.push(BareString(lastStr.toString()));
		}
		return tokens;
	}
	
	#if (!display && !doc)
	public
	#end
	static inline function _full_runtime_format(fmt:String, args:Array<Dynamic>):String
	{
		if (_instance == null)
			_instance = new Sprintf();
		return _instance._format(fmt, args);
	}
	
	function _format(fmt:String, args:Array<Dynamic>):String
	{
		var output = "";
		var argIndex = 0;
		var tokens = tokenize(fmt);
		for (token in tokens)
		{
			switch(token)
			{
			case Unknown(str, pos):
				throw "invalid format specifier";
			case BareString(str):
				output += str;
			case Tag(type, tagArgs):
				tagArgs.width = (tagArgs.width != null)?tagArgs.width:cast(args[argIndex++], Int);
				tagArgs.precision = (tagArgs.precision != null)?tagArgs.precision:cast(args[argIndex++], Int);
				var value:Dynamic = args[argIndex++];
				
				var formatFunction:Dynamic->FormatArgs->String;
				
				switch(type)
				{
				case FmtFloat(floatType):
					formatFunction = formatFloatFuncHash.get(std.Type.enumIndex(floatType));
				case FmtInteger(integerType):
					formatFunction = formatIntFuncHash.get(std.Type.enumIndex(integerType));
				case FmtString:
					formatFunction = formatStringFuncHash.get(std.Type.enumIndex(FmtString));
				case FmtPointer:
					throw "specifier 'p' is not supported";
				case FmtNothing:
					throw "specifier 'n' is not supported";
				}
				
				output += formatFunction(value, tagArgs);
			}
		}
		return output;
	}
	
	public inline function formatBin(value:Int, args:FormatArgs):String
	{
		var output = "";
		if (args.precision == -1) args.precision = 1;
		
		if (args.precision == 0 && value == 0)
			output = "";
		else
		{
			if (args.flags.has(LengthH))
				value &= 0xffff;
			
			output = value.toBin();
			if (args.precision > 1)
			{
				if (args.precision > output.length)
				{
					output = StringTools.lpad(output, "0", args.precision);
				}
				if (args.flags.has(Sharp)) output = "b" + output;
			}
		}
		return
		if (args.flags.has(Minus))
			(args.width > output.length) ? StringTools.rpad(output, " ", args.width) : output;
		else
			(args.width > output.length) ? StringTools.lpad(output, (args.flags.has(Zero)?"0":" ") , args.width) : output;
	}
	
	public inline function formatOctal(value:Int, args:FormatArgs):String
	{
		var output = "";
		if (args.precision == -1) args.precision = 1;
		
		if (args.precision == 0 && value == 0)
			output = "";
		else
		{
			if (args.flags.has(LengthH))
				value &= 0xffff;
			
			output = value.toOct();
			
			if (args.flags.has(Sharp)) output = "0" + output;
			
			if (args.precision > 1 && output.length < args.precision)
			{
				output = StringTools.lpad(output, "0", args.precision);
			}
		}
		
		return
		if (args.flags.has(Minus))
			(args.width > output.length) ? StringTools.rpad(output, " ", args.width) : output;
		else
			(args.width > output.length) ? StringTools.lpad(output, (args.flags.has(Zero)?"0":" ") , args.width) : output;
	}
	
	public inline function formatHex(value:Int, args:FormatArgs):String
	{
		var output = "";
		if (args.precision == -1) args.precision = 1;
		
		if (args.precision == 0 && value == 0)
			output = "";
		else
		{
			if (args.flags.has(LengthH))
				value &= 0xffff;
			
			output = value.toHex();
			if (args.precision > 1 && output.length < args.precision)
			{
				output = StringTools.lpad(output, "0", args.precision);
			}
			
			if (args.flags.has(Sharp) && value != 0)
				output = "0x" + output;
			output = (args.flags.has(UpperCase)) ? output.toUpperCase() : output.toLowerCase();
		}
		
		return
		if (args.flags.has(Minus))
			(args.width > output.length) ? StringTools.rpad(output, " ", args.width) : output;
		else
			(args.width > output.length) ? StringTools.lpad(output, (args.flags.has(Zero))?"0":" " , args.width) : output;
	}
	
	public inline function formatUnsignedDecimal(value:Int, args:FormatArgs):String
	{
		var output = "";
		if (value >= 0)
			output = formatSignedDecimal(value, args);
		else
		{
			var x = haxe.Int64.make(haxe.Int32.ofInt(0), haxe.Int32.ofInt(value));
			output = haxe.Int64.toStr(x);
			
			if (args.precision > 1 && output.length < args.precision)
			{
				output = StringTools.lpad(output, "0", args.precision);
			}
			output = _padNumber(output, value, args.flags, args.width);
		}
		
		return output;
	}
	
	public inline function formatNaturalFloat(value:Float, args:FormatArgs):String
	{
		// TODO: precompute lengths
		args.precision = 0;
		
		var formatedFloat = formatNormalFloat(value, args);
		var formatedScientific = formatScientific(value, args);
		
		if (args.flags.has(Sharp))
		{
			if (formatedFloat.indexOf(".") != -1)
			{
				var pos = formatedFloat.length -1;
				while (StringTools.fastCodeAt(formatedFloat, pos) == "0".code) pos--;
				formatedFloat = formatedFloat.substr(0, pos);
			}
		}
		
		return (formatedFloat.length <= formatedScientific.length) ? formatedFloat : formatedScientific;
	}
	
	public inline function formatScientific(value:Float, args:FormatArgs):String
	{
		var output = "";
		if (args.precision == -1) args.precision = 6;
		
		var a = 4.21 / Math.pow(0.1, args.precision);
		
		
		var sign:Int;
		var exponent:Int;
		
		if (value == 0)
		{
			sign = 0;
			exponent = 0;
			output += '0';
			if (args.precision > 0)
			{
				output += ".";
				for (i in 0...args.precision) output += '0';
			}
		}
		else
		{
			sign = value.fsgn();
			value = value.fabs();
			exponent = (Math.log(value) / Mathematics.LN10).floor();
			value = value / Mathematics.exp(10, exponent);
			var p = Math.pow(0.1, args.precision);
			
			value = value.roundTo(p);
		}
		
		output += (sign < 0 ? "-" : args.flags.has(Plus) ? "+" : "");
		
		if (value != 0)
			output += Std.string(value).substr(0, args.precision + 2);
		output += args.flags.has(UpperCase) ? "E" : "e";
		output += exponent >= 0 ? "+" : "-";
		
		if (exponent < 10) output += "00";
		else
		if (exponent < 100) output += "0";
		
		output += Std.string(exponent.abs());
		return output;
	}
	
	public inline function formatSignedDecimal(value:Int, args:FormatArgs):String
	{
		var output:String = "";
		if (args.precision == 0 && value == 0)
			output = "";
		else
		{
			if (args.flags.has(LengthH))
				value &= 0xffff;
				
			output = Std.string(value);
				
			if (args.precision > 1 && output.length < args.precision)
			{
				//output = _lpad(output, "0", args.precision - output.length - 2);
				if (value > 0)
				{
					for (i in 0...args.precision - 1)
						output = "0" + output;
				}
				else
				{
					output = "0" + -value;
					for (i in 0...args.precision - 2)
						output = "0" + output;
					output = "-" + output;
				}
			}
		}
		if (value >= 0)
		{
			if (args.flags.has(Plus))
				output = "+" + output;
			else
			if (args.flags.has(Space))
				output = " " + output;
		}
		
		return _padNumber(output, value, args.flags, args.width);
	}
	
	public inline function formatString(x:String, args:FormatArgs):String
	{
		var output = x;
		if (args.precision > 0)
			output = x.substr(0, args.precision);
		var k = output.length;
		if (args.width > 0 && k < args.width)
		{
			if (args.flags.has(Minus))
				output = StringTools.rpad(output, " ", args.width);
			else
				output = StringTools.lpad(output, " ", args.width);
		}
		return output;
	}
	
	public inline function formatNormalFloat(x:Float, args:FormatArgs):String
	{
		var output:String;
		//set default precision if not specified
		if (args.precision == -1) args.precision = 6;
		
		if (args.precision == 0)
		{
			output = Std.string(x.round());
			//force decimal point?
			if (args.flags.has(Sharp)) output += ".";
		}
		else
		{
			x = x.roundTo(Math.pow(.1, args.precision));
			output = x.toFixed(args.precision);
		}
		
		if (args.flags.has(Plus) && x >= 0)
			output = "+" + output;
		else
		if (args.flags.has(Space) && x >= 0)
			output = " " + output;
		
		return _padNumber(output, x, args.flags, args.width);
	}
	
	public inline function formatCharacter(x:Int, args:FormatArgs):String
	{
		var output = String.fromCharCode(x);
		if (args.width > 1)
		{
			//left-justify (right justification is the default)
			if (args.flags.has(Minus))
				output = StringTools.rpad(output, " ", args.width);
			else
				output = StringTools.lpad(output, " ", args.width);
		}
		
		return output;
	}
	
	inline function _padNumber(x:String, n:Float, flags:EnumFlags<FormatFlags>, width:Int):String
	{
		var k = x.length;
		if (width > 0 && k < width)
		{
			//left-justify (right justification is the default)
			if (flags.has(Minus))
				x = StringTools.rpad(x, " ", width);
			else
			{
				if (n >= 0)
					x = StringTools.lpad(x, flags.has(Zero) ? "0" : " ", width);
				else
				{
					if (flags.has(Zero))
					{
						//shift minus sign to left-most position
						x = "-" + StringTools.lpad(x.substr(1), "0", width);
					}
					else
						x = StringTools.lpad(x, " ", width);
				}
			}
		}
		
		return x;
	}
}

typedef FormatArgs = 
{
	flags:haxe.EnumFlags<FormatFlags>,
	pos:Int,
	width:Null<Int>,
	precision:Null<Int>
}

enum FormatFlags
{
	Minus;
	Plus;
	Space;
	Sharp;
	Zero;
	LengthH;
	LengthL;
	Lengthl;
	UpperCase;
}

private enum FormatToken
{
	BareString(str:String);
	Tag(type:FormatDataType, args:FormatArgs);
	Unknown(str:String, pos:Int);
}

private enum FormatDataType
{
	FmtInteger(integerType:IntegerType);
	FmtFloat(floatType:FloatType);
	FmtString;
	FmtPointer;
	FmtNothing;
}
private enum IntegerType
{
	ICharacter;
	ISignedDecimal;
	IUnsignedDecimal;
	IOctal;
	IHex;
	IBin;
}
private enum FloatType
{
	FNormal;
	FScientific;
	FNatural;
}