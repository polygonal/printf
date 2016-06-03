/*
Copyright (c) 2016 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package de.polygonal;

import haxe.EnumFlags;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
	C printf implementation
	
	@see https://github.com/polygonal/printf
 */
class Printf
{
	inline static var DEFAULT_PRECISION = 6;
	
	#if macro
	static var formatIntFuncNameHash: haxe.ds.IntMap<String>;
	static var formatFloatFuncNameHash: haxe.ds.IntMap<String>;
	static var formatStringFuncNameHash: haxe.ds.IntMap<String>;
	
	static function makeNameHashes()
	{
		formatIntFuncNameHash = new  haxe.ds.IntMap();
		formatIntFuncNameHash.set(std.Type.enumIndex(ISignedDecimal), "formatSignedDecimal");
		formatIntFuncNameHash.set(std.Type.enumIndex(IUnsignedDecimal), "formatUnsignedDecimal");
		formatIntFuncNameHash.set(std.Type.enumIndex(ICharacter), "formatCharacter");
		formatIntFuncNameHash.set(std.Type.enumIndex(IHex), "formatHex");
		formatIntFuncNameHash.set(std.Type.enumIndex(IOctal), "formatOctal");
		formatIntFuncNameHash.set(std.Type.enumIndex(IBin), "formatBin");
		
		formatFloatFuncNameHash = new  haxe.ds.IntMap();
		formatFloatFuncNameHash.set(std.Type.enumIndex(FNormal), "formatNormalFloat");
		formatFloatFuncNameHash.set(std.Type.enumIndex(FScientific), "formatScientific");
		formatFloatFuncNameHash.set(std.Type.enumIndex(FNatural), "formatNaturalFloat");
		
		formatStringFuncNameHash = new  haxe.ds.IntMap();
		formatStringFuncNameHash.set(std.Type.enumIndex(FmtString), "formatString");
	}
	#end
	
	static var _initialized = false;
	static var _tokenList:Array<FormatToken>;
	
	static function init()
	{
		#if macro
		makeNameHashes();
		#end
		
		_tokenList = [];
	}
	
	/**
	 * Writes formatted data to a string.
	 * Compile time, advanced features.
	 * @param fmt the string that contains the formatted text.<br/>
	 * It can optionally contain embedded format tags that are substituted by the values specified in subsequent argument(s) and formatted as requested.<br/>
	 * The number of arguments following the format parameters should at least be as much as the number of format tags.<br/>
	 * The format tags follow this prototype: '%[flags][width][.precision][length]specifier'.
	 * @param arg depending on the format string, the function may expect a sequence of additional arguments, each containing one value to be inserted instead of each %-tag specified in the format parameter, if any.<br/>
	 * The argument array length should match the number of %-tags that expect a value.
	 * @return the formatted string.
	 */
	macro public static function eformat(_fmt:ExprOf<String>, _passedArgs:Array<Expr>):ExprOf<String>
	{
		var error = false;
		switch (Context.typeof(_fmt))
		{
			case TInst(t, _):
				error = t.get().name != "String";
			
			case _:
				error = true;
		}
		
		if (error)
			Context.error("format should be a string", _fmt.pos);
		
		var _args:ExprOf<Array<Dynamic>>;
		if (_passedArgs == null || _passedArgs.length == 0)
			_args = Context.makeExpr([], Context.currentPos());
		else
		{
			var makeArray = true;
			if (_passedArgs.length == 1)
				switch(Context.typeof({expr:ECheckType(_passedArgs[0],(macro : Array<Dynamic>)), pos:_passedArgs[0].pos}))
				{
					case TInst(t, _):
						if (t.get().name == "Array")
							makeArray = false;
					
					case _:
						makeArray = true;
				};
			
			if (makeArray)
			{
				var min = Context.getPosInfos(_passedArgs[0].pos).min;
				var max = Context.getPosInfos(_passedArgs[_passedArgs.length - 1].pos).max;
				var file = Context.getPosInfos(Context.currentPos()).file;
				var pos = Context.makePosition( { min:min, max:max, file:file } );
				_args = { expr:EArrayDecl(_passedArgs), pos:pos };
			}
			else
				_args = _passedArgs[0];
		}
		
		// Force _args array to be typed as Array<Dynamic>
		var dynArrayType:ComplexType = macro : Array<Dynamic>;
		_args = { expr:ECheckType(_args, dynArrayType), pos:_args.pos };
		
		switch(Context.typeof(_args))
		{
			case TInst(t, _):
				error = t.get().name != "Array";
			
			case _:
				error = true;
		}
		
		if (error)
			Context.error("arguments should be an array", _args.pos);
		
		var fmt:String = null;
		var fmtArgs:Array<Expr> = null;
		
		switch(_fmt.expr) 
		{
			case EConst(const):
				switch(const)
				{
					case CString(valStr):
						fmt = valStr;
					case _:
				}
			
			case _:
		}
		
		switch(_args.expr)
		{
			case EArrayDecl(values):
				fmtArgs = values;
			
			case _:
		}
		
		
		if (!_initialized)
		{
			_initialized = true;
			init();
		}
		
		
		if (fmt == null)
			return macro de.polygonal.Printf.format($_fmt, $_args);
		
		var fmtTokens:Array<FormatToken> = null;
		
		try
		{
			fmtTokens = tokenize(fmt);
		}
		catch (e:Dynamic)
		{
			Context.error(Std.string(e), _fmt.pos);
		}
		
		var instanceExpr = { expr:EConst(CIdent("Printf")), pos:Context.currentPos() };
		var outputArr:Array<Expr> = new Array();
		
		var knownArgs = fmtArgs != null;
		var argsIndex = 0;
		var usedArgs:Array<Bool> = new Array();
		if (knownArgs)
			for (i in 0...fmtArgs.length)
				usedArgs.push(false);
		
		if (!_initialized)
		{
			_initialized = true;
			init();
		}
		
		for (token in fmtTokens)
		{
			switch(token)
			{
				case Unknown(_, pos):
					
					var min = Context.getPosInfos(_fmt.pos).min + pos;
					var max = min + 1;
					var file = Context.getPosInfos(Context.currentPos()).file;
					Context.error("invalid format specifier", Context.makePosition( { min:min, max:max, file:file } ));
				
				case Raw(string):
					outputArr.push(Context.makeExpr(string, Context.currentPos()));
				
				case Property(name):
					var objExpr = (knownArgs)?
						fmtArgs[0]:
						{ expr:EArray(_args, Context.makeExpr(0, _args.pos)), pos:_args.pos };
						
					usedArgs[0] = true;
					
					var valueExpr:Expr = null;
					switch(objExpr.expr)
					{
						case EObjectDecl(fields):
							for (field in fields)
							{
								if (field.field == name)
								{
									valueExpr = field.expr;
									break;
								}
							}
						
						case _:
					}
					if (valueExpr == null)
						valueExpr = { expr:EField(objExpr, name), pos:objExpr.pos };
					
					var outputExpr = macro Std.string($valueExpr);
					outputArr.push(outputExpr);
				
				case Tag(type, args):
					var widthExpr = Context.makeExpr(args.width, Context.currentPos());
					if (args.width == null)
					{
						usedArgs[argsIndex] = true;
						
						widthExpr = (knownArgs)?
							fmtArgs[argsIndex++]:
							{ expr:ECheckType( { expr:EArray(_args, Context.makeExpr(argsIndex++, _args.pos)), pos:_args.pos }, TPath( { sub:null, params:[], pack:[], name:"Int" } )), pos:Context.currentPos() };
						if (widthExpr == null)
							Context.error("not enough arguments", _args.pos);
						var error = false;
						switch(widthExpr.expr)
						{
							case EConst(c):
								switch(c)
								{
									case CInt(value):
										args.width = Std.parseInt(value);
									
									case CIdent(_):
										switch(Context.typeof(widthExpr))
										{
											case TInst(type, _):
												error = type.get().name != "Int";
											
											case _:
												error = true;
										}
									
									case _:
										error = true;
								}
							
							case _:
								switch(Context.typeof(widthExpr))
								{
									case TInst(type, _):
										error = type.get().name != "Int";
									
									case _:
										error = true;
								}
						}
						if (error)
							Context.error("width must be an integer", widthExpr.pos);
					}
					
					var precisionExpr = Context.makeExpr(args.precision, Context.currentPos());
					if (args.precision == null)
					{
						usedArgs[argsIndex] = true;
						
						precisionExpr = (knownArgs)?
							fmtArgs[argsIndex++]:
							{ expr:ECheckType( { expr:EArray(_args, Context.makeExpr(argsIndex++, _args.pos)), pos:_args.pos }, TPath( { sub:null, params:[], pack:[], name:"Int" } )), pos:Context.currentPos() };
						if (precisionExpr == null)
							Context.error("not enough arguments", _args.pos);
						var error = false;
						switch(precisionExpr.expr)
						{
							case EConst(c):
								switch(c)
								{
									case CInt(value):
										args.precision = Std.parseInt(value);
									
									case CIdent(_):
										switch(Context.typeof(precisionExpr))
										{
											case TInst(type, _):
												error = type.get().name != "Int";
											
											case _:
												error = true;
										}
									
									case _:
										error = true;
								}
							
							case _:
								switch(Context.typeof(precisionExpr))
								{
									case TInst(type, _):
										error = type.get().name != "Int";
									
									case _:
										error = true;
								}
						}
						if (error)
							Context.error("precision must be an integer", precisionExpr.pos);
					}
					
					var flagsIntExpr = Context.makeExpr(args.flags.toInt(), Context.currentPos());
					
					var argsExpr = { expr:EObjectDecl(
							[
								{field:"width", expr:widthExpr },
								{field:"precision", expr:precisionExpr },
								{field:"flags", expr:macro EnumFlags.ofInt($flagsIntExpr) },
								{field:"pos", expr:Context.makeExpr(args.pos, Context.currentPos()) }
							]), pos:Context.currentPos() };
					
					var valuePos = (args.pos > -1)?args.pos:argsIndex++;
					var valueExpr = (knownArgs)?
						fmtArgs[valuePos]:
						{ expr:EArray(_args, Context.makeExpr(valuePos, _args.pos)), pos:_args.pos };
					if (valueExpr == null)
						Context.error("not enough arguments", _args.pos);
						
					usedArgs[valuePos] = true;
					
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
								
								case _:
									value = null;
							}
						
						case _:
							value = null;
					}
					
					var preComputable = args.precision != null && args.width != null && value != null;
					
					var outputExpr:Expr;
					
					var typeName = function(e:Expr):String
					{
						switch(Context.typeof(e))
						{
							case TInst(t, _):
								return (t.get().name);
							
							case _:
								return null;
						}
					};
					
					var formatFunction:Dynamic->FormatArgs->String;
					var formatFunctionName:String;
					
					switch (type)
					{
						case FmtFloat(floatType):
							if (preComputable && !Std.is(value, Float) && !Std.is(value, Int))
								Context.error("the value must be a number", valueExpr.pos);
							formatFunction = formatFloatFuncHash.get(std.Type.enumIndex(floatType));
							formatFunctionName = formatFloatFuncNameHash.get(std.Type.enumIndex(floatType));
						
						case FmtInt(integerType):
							if (preComputable && !Std.is(value, Int))
								Context.error("the value must be an integer", valueExpr.pos);
							formatFunction = formatIntFuncHash.get(std.Type.enumIndex(integerType));
							formatFunctionName = formatIntFuncNameHash.get(std.Type.enumIndex(integerType));
						
						case FmtString:
							formatFunction = formatStringFuncHash.get(std.Type.enumIndex(FmtString));
							formatFunctionName = formatStringFuncNameHash.get(std.Type.enumIndex(FmtString));
							
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
						outputExpr = { expr:ECall( { expr:EField(instanceExpr, formatFunctionName), pos:Context.currentPos() }, [valueExpr, argsExpr]), pos:Context.currentPos() };
					
					outputArr.push(outputExpr);
			}
		}
		
		if (Context.defined("verbose") && knownArgs)
		{
			var lastUnused = false;
			var unusedIntervals:Array<{min:Int, max:Int, file:String}> = new Array();
			for (i in 0...usedArgs.length)
			{
				if (usedArgs[i] == false)
				{
					if (lastUnused)
						unusedIntervals[unusedIntervals.length - 1].max = Context.getPosInfos(fmtArgs[i].pos).max;
					else
						unusedIntervals.push(Context.getPosInfos(fmtArgs[i].pos));
					
					lastUnused = true;
				}
				else
					lastUnused = false;
			}
			
			for (interval in unusedIntervals)
				Context.warning("unused parameters", Context.makePosition(interval));
		}
		
		var returnStrExpr:Expr = outputArr[outputArr.length - 1];
		
		for (_i in 1...outputArr.length)
		{
			var i = outputArr.length -1 - _i;
			returnStrExpr = { expr:EBinop(OpAdd, outputArr[i], returnStrExpr), pos:Context.currentPos() };
		}
		
		var returnBlock:Expr = macro
		{
			$returnStrExpr;
		};
		
		return returnBlock;
	}
	
	/**
		Writes formatted data to a string.
		
		Evaluation is done at run-time.
	 */
	public static function format(fmt:String, args:Array<Dynamic>):String
	{
		if (!_initialized)
		{
			_initialized = true;
			init();
		}
		
		var output = new StringBuf();
		var argIndex = 0;
		var tokens = _tokenList;
		for (i in 0...tokenize(fmt, tokens))
		{
			switch (tokens[i])
			{
				case Unknown(_, _):
					throw new PrintfError("invalid format specifier");
				
				case Raw(string):
					trace('raw string=[$string]');
					output.add(string);
				
				case Property(name):
					if (!Reflect.hasField(args[0], name))
						throw new PrintfError("no field named " + name);
					output.add(Std.string(Reflect.field(args[0], name)));
				
				case Tag(type, tagArgs):
					if (tagArgs.width == null)
					{
						if (!Std.is(args[argIndex], Int))
							throw new PrintfError("invalid 'width' argument");
						tagArgs.width = args[argIndex++];
					}
					
					if (tagArgs.precision == null)
					{
						if (!Std.is(args[argIndex], Int))
							throw new PrintfError("invalid 'precision' argument");
						tagArgs.precision = args[argIndex++];
					}
					
					var f:Dynamic->FormatArgs->String =
					switch (type)
					{
						case FmtFloat(floatType):
							switch (floatType)
							{
								case FNormal: formatNormalFloat;
								case FScientific: formatScientific;
								case FNatural: formatNaturalFloat;
							}
						
						case FmtInt(intType):
							switch (intType)
							{
								case ICharacter: formatCharacter;
								case ISignedDecimal: formatSignedDecimal;
								case IUnsignedDecimal: formatUnsignedDecimal;
								case IOctal: formatOctal;
								case IHex: formatHexadecimal;
								case IBin: formatBinary;
							}
						
						case FmtString:
							formatString;
						
						case FmtPointer:
							throw new PrintfError("specifier 'p' is not supported");
						
						case FmtNothing:
							throw new PrintfError("specifier 'n' is not supported");
					};
					
					var value;
					if (tagArgs.pos > -1)
					{
						if (tagArgs.pos > args.length - 1)
							throw new PrintfError("argument index out of range");
						value = args[tagArgs.pos];
					}
					else
						value = args[argIndex++];
					
					if (value == null) value = "null";
					output.add(f(value, tagArgs));
			}
		}
		
		return output.toString();
	}
	
	static function tokenize(fmt:String, output:Array<FormatToken>):Int
	{
		var i = 0, c = 0, n = 0;
		
		inline function isDigit(x) return x >= 48 && x <= 57;
		inline function next() c = StringTools.fastCodeAt(fmt, i++);
		
		var buf = new StringBuf();
		var k = fmt.length;
		while (i < k)
		{
			next();
			if (c == "%".code)
			{
				next();
				if (c == "%".code)
				{
					buf.addChar(c);
					continue;
				}
				
				//flush last string
				if (buf.length > 0)
				{
					output[n++] = Raw(buf.toString());
					buf = new StringBuf();
				}
				
				var token:FormatToken;
				
				//{named parameter
				if (c == "(".code)
				{
					var endPos = fmt.indexOf(")", i);
					if (endPos == -1)
						token = Unknown("named param", i);
					else
					{
						var paramName = fmt.substr(i, endPos - i);
						i = endPos + 1;
						token = Property(paramName);
					}
				}
				//}
				else
				{
					var params:FormatArgs = { flags:EnumFlags.ofInt(0), pos: -1, width: -1, precision: -1 };
					
					//read flags: -+(space)#0
					while (c >= " ".code && c <= "0".code)
					{
						switch (c)
						{
							case "-".code: next(); params.flags.set(Minus);
							case "+".code: next(); params.flags.set(Plus);
							case "#".code: next(); params.flags.set(Sharp);
							case "0".code: next(); params.flags.set(Zero);
							case " ".code: next(); params.flags.set(Space);
							case _: break;
						}
					}
					
					//check for conflicting flags
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
					
					//read width: (number) or "*"
					if (c == "*".code)
					{
						params.width = null;
						next();
					}
					else
					if (isDigit(c))
					{
						var w = 0;
						while (isDigit(c))
						{
							w = c - "0".code + w * 10;
							next();
						}
						params.width = w;
						
						//check if number was a position, not a width
						if (c == "$".code)
						{
							params.pos = w - 1;
							params.width = -1;
							next();
							
							//re-check for width
							if (c == "*".code)
							{
								params.width = null;
								next();
							}
							else
							if (isDigit(c))
							{
								var w = 0;
								while (isDigit(c))
								{
									w = c - "0".code + w * 10;
									next();
								}
								params.width = w;
							}
						}
					}
					
					//read .precision: .(number) or ".*"
					if (c == ".".code)
					{
						next();
						if (c == "*".code)
						{
							params.precision = null;
							next();
						}
						else
						{
							var p = 0;
							if (isDigit(c))
							{
								while (isDigit(c))
								{
									p = c - "0".code + p * 10;
									next();
								}
							}
							params.precision = p;
						}
					}
					
					//read length: hlL
					while (c >= "L".code && c <= "l".code)
					{
						switch (c)
						{
							case "h".code: next(); params.flags.set(LengthH);
							case "l".code: next(); params.flags.set(LengthLowerCaseL);
							case "L".code: next(); params.flags.set(LengthUpperCaseL);
							case _: break;
						}
					}
					
					//read specifier: cdieEfgGosuxX
					if (c >= "E".code && c <= "x".code)
					{
						var type =
						switch (c)
						{
							case "i".code: FmtInt(ISignedDecimal);
							case "d".code: FmtInt(ISignedDecimal);
							case "u".code: FmtInt(IUnsignedDecimal);
							case "c".code: FmtInt(ICharacter);
							case "x".code: FmtInt(IHex);
							case "X".code: params.flags.set(UpperCase); FmtInt(IHex);
							case "o".code: FmtInt(IOctal);
							case "b".code: FmtInt(IBin);
							case "f".code: FmtFloat(FNormal);
							case "e".code: FmtFloat(FScientific);
							case "E".code: params.flags.set(UpperCase); FmtFloat(FScientific);
							case "g".code: FmtFloat(FNatural);
							case "G".code: params.flags.set(UpperCase); FmtFloat(FNatural);
							case "s".code: FmtString;
							case "p".code: FmtPointer;
							case "n".code: FmtNothing;
							case _: null;
						}
						
						token =
						if (type == null)
							Unknown(String.fromCharCode(c), i);
						else
							Tag(type, params);
					}
					else
						token = Unknown(String.fromCharCode(c), i);
				}
				output[n++] = token;
			}
			else
				buf.addChar(c);
		}
		
		if (buf.length > 0) output[n++] = Raw(buf.toString());
		return n;
	}
	
	static function formatBinary(value:Int, args:FormatArgs):String
	{
		var output = "";
		var flags = args.flags;
		var precision = args.precision;
		var width = args.width;
		
		if (precision == -1) precision = 1;
		
		if (value != 0)
		{
			if (flags.has(LengthH))
				value &= 0xffff;
			
			//toBin()
			var i = value;
			do
			{
				output = ((i & 1) > 0 ? "1" : "0") + output;
				i >>>= 1;
			}
			while (i > 0);
			
			if (precision > 1)
			{
				if (precision > output.length)
					output = lpad(output, "0", precision);
				
				if (flags.has(Sharp)) output = "b" + output;
			}
		}
		
		return
		if (flags.has(Minus))
			(width > output.length) ? rpad(output, " ", width) : output;
		else
			(width > output.length) ? lpad(output, (flags.has(Zero) ? "0" :" ") , width) : output;
	}
	
	static function formatOctal(value:Int, args:FormatArgs):String
	{
		var output  = "";
		var flags = args.flags;
		var precision = args.precision;
		var width = args.width;
		
		if (precision == -1) precision = 1;
		
		if (value != 0)
		{
			if (flags.has(LengthH)) value &= 0xffff;
			
			output = toOct(value);
			
			if (flags.has(Sharp)) output = "0" + output;
			
			if (precision > 1 && output.length < precision)
				output = lpad(output, "0", precision);
		}
		
		return
		if (flags.has(Minus))
			(width > output.length) ? rpad(output, " ", width) : output;
		else
			(width > output.length) ? lpad(output, (flags.has(Zero)?"0":" ") , width) : output;
	}
	
	static function formatHexadecimal(value:Int, args:FormatArgs):String
	{
		var output = "";
		var flags = args.flags;
		var precision = args.precision;
		var width = args.width;
		
		if (precision == -1) precision = 1;
		
		if (value != 0)
		{
			if (flags.has(LengthH))
				value &= 0xffff;
			
			output = toHex(value);
			
			if (precision > 1 && output.length < precision)
				output = lpad(output, "0", precision);
			
			if (flags.has(Sharp) && value != 0)
				output = "0x" + output;
			
			output = (flags.has(UpperCase)) ? output.toUpperCase() : output.toLowerCase();
		}
		
		return
		if (flags.has(Minus))
			(width > output.length) ? rpad(output, " ", width) : output;
		else
			(width > output.length) ? lpad(output, (flags.has(Zero)) ? "0" : " " , width) : output;
	}
	
	static function formatUnsignedDecimal(value:Int, args:FormatArgs):String
	{
		var output:String;
		var precision = args.precision;
		
		if (value >= 0)
			output = formatSignedDecimal(value, args);
		else
		{
			var x = haxe.Int64.make(0, value);
			output = haxe.Int64.toStr(x);
			if (precision > 1 && output.length < precision)
				output = lpad(output, "0", precision);
			output = padNumber(output, value, args.flags, args.width);
		}
		
		return output;
	}
	
	static function formatNaturalFloat(value:Float, args:FormatArgs):String
	{
		//TODO: precompute lengths
		args.precision = 0;
		
		var formatedFloat = formatNormalFloat(value, args);
		var formatedScientific = formatScientific(value, args);
		
		if (args.flags.has(Sharp))
		{
			if (formatedFloat.indexOf(".") != -1)
			{
				var pos = formatedFloat.length -1;
				while (formatedFloat.charCodeAt(pos) == "0".code) pos--;
				formatedFloat = formatedFloat.substr(0, pos);
			}
		}
		
		return (formatedFloat.length <= formatedScientific.length) ? formatedFloat : formatedScientific;
	}
	
	static function formatScientific(value:Float, args:FormatArgs):String
	{
		var output = "";
		var flags = args.flags;
		var precision = args.precision;
		if (precision == -1) precision = DEFAULT_PRECISION;
		
		var sign:Int, exponent:Int;
		
		if (value == 0)
		{
			sign = 0;
			exponent = 0;
			output += "0";
			if (precision > 0)
			{
				output += ".";
				for (i in 0...precision) output += "0";
			}
		}
		else
		{
			sign = (value > 0.) ? 1 : (value < 0. ? -1 : 0);
			value = Math.abs(value);
			exponent = Math.floor(Math.log(value) / 2.302585092994046); //LN10
			value = value / Math.pow(10, exponent);
			var p = Math.pow(0.1, precision);
			value = roundTo(value, p);
		}
		
		output += (sign < 0 ? "-" : flags.has(Plus) ? "+" : "");
		
		if (value != 0)
		{
			output += rpad(Std.string(value).substr(0, precision + 2), "0", precision + 2);
			
			
			
		}
		output += flags.has(UpperCase) ? "E" : "e";
		output += exponent >= 0 ? "+" : "-";
		
		if (exponent < 10)
			output += "00";
		else
		if (exponent < 100)
			output += "0";
		
		output += Std.string(exponent < 0 ? -exponent : exponent);
		return output;
	}
	
	static function formatSignedDecimal(value:Int, args:FormatArgs):String
	{
		var output:String;
		
		var flags = args.flags;
		var precision = args.precision;
		var width = args.width;
		
		if (precision == 0 && value == 0)
			output = "";
		else
		{
			if (flags.has(LengthH)) value &= 0xffff;
			
			output = Std.string(value < 0 ? -value : value);
			
			if (precision > 1 && output.length < precision)
				output = lpad(output, "0", precision);
			
			if (flags.has(Zero))
				output = lpad(output, "0", value < 0 ? width - 1 : width);
			
			if (value < 0) output = "-" + output;
		}
		
		if (value >= 0)
		{
			if (flags.has(Plus))
				output = "+" + output;
			else
			if (flags.has(Space))
				output = " " + output;
		}
		
		if (flags.has(Minus))
			output = rpad(output, " ", args.width);
		else
			output = lpad(output, " ", args.width);
		
		return output;
	}
	
	static function formatString(value:String, args:FormatArgs):String
	{
		var output = value;
		var precision = args.precision;
		var width = args.width;
		
		if (precision > 0)
			output = value.substr(0, precision);
		
		var k = output.length;
		if (width > 0 && k < width)
		{
			if (args.flags.has(Minus))
				output = rpad(output, " ", width);
			else
				output = lpad(output, " ", width);
		}
		
		return output;
	}
	
	static function formatNormalFloat(value:Float, args:FormatArgs):String
	{
		var output:String;
		
		var flags = args.flags;
		var precision = args.precision;
		var width = args.width;
		
		//set default precision if not specified
		if (precision == -1) precision = DEFAULT_PRECISION;
		
		if (precision == 0)
		{
			var tmp = Std.int(Math.round(value));
			output = Std.string(tmp < 0 ? -tmp : tmp);
			
			//force decimal point?
			if (flags.has(Sharp)) output += ".";
		}
		else
		{
			//toFixed()
			value = roundTo(value, Math.pow(.1, precision));
			var decimalPlaces = precision;
			if (Math.isNaN(value))
				output = "NaN";
			else
			{
				var t = Std.int(Math.pow(10, decimalPlaces));
				
				output = Std.string(Std.int(value * t) / t);
				
				
				
				
				var i = output.indexOf(".");
				if (i != -1)
				{
					for (i in output.substr(i + 1).length...decimalPlaces)
						output += "0";
				}
				else
				{
					output += ".";
					for (i in 0...decimalPlaces)
						output += "0";
				}
			}
		}
		
		if (flags.has(Plus) && value >= 0)
			output = "+" + output;
		else
		if (flags.has(Space) && value >= 0)
			output = " " + output;
		
		if (flags.has(Zero))
			output = lpad(output, "0", (value < 0) ? width - 1 : width);
		
		if (flags.has(Minus))
			output = rpad(output, " ", width);
		else
			output = lpad(output, " ", width);
		
		return output;
	}
	
	static function formatCharacter(x:Int, args:FormatArgs):String
	{
		var output = String.fromCharCode(x);
		if (args.width > 1)
		{
			//left-justify (right justification is the default)
			if (args.flags.has(Minus))
				output = rpad(output, " ", args.width);
			else
				output = lpad(output, " ", args.width);
		}
		
		return output;
	}

	static function padNumber(x:String, n:Float, flags:EnumFlags<FormatFlag>, width:Int):String
	{
		var k = x.length;
		if (width > 0 && k < width)
		{
			//left-justify (right justification is the default)
			if (flags.has(Minus))
				x = rpad(x, " ", width);
			else
			{
				if (n >= 0)
					x = lpad(x, flags.has(Zero) ? "0" : " ", width);
				else
				{
					if (flags.has(Zero))
					{
						//shift minus sign to left-most position
						x = "-" + lpad(x.substr(1), "0", width);
					}
					else
						x = lpad(x, " ", width);
				}
			}
		}
		
		return x;
	}
	
	static function lpad(s:String, c:String, l:Int):String
	{
		if (c.length <= 0) throw 'c.length <= 0';
		while (s.length < l) s = c + s;
		return s;
	}
	
	static function rpad(s:String, c:String, l:Int):String
	{
		if (c.length <= 0) throw "c.length <= 0";
		while (s.length < l) s = s + c;
		return s;
	}
	
	inline static function toHex(x:Int):String
	{
		#if flash9
		var n:UInt = x;
		var s:String = untyped x.toString(16);
		s = s.toUpperCase();
		#else
		var s = "";
		var hexChars = "0123456789ABCDEF";
		do
		{
			s = hexChars.charAt(x&15) + s;
			x >>>= 4;
		}
		while( x > 0 );
		#end
		return s;
	}
	
	//TODO optimize
	static function toOct(x:Int):String
	{
		var s = "";
		var t = x;
		do
		{
			s = (t & 7) + s;
			t >>>= 3;
		}
		while (t > 0);
		return s;
	}
	
	inline static function roundTo(x:Float, y:Float):Float
	{
		//rounds x to interval y
		#if (js || flash)
		return Math.round(x / y) * y;
		#else
		//warning: this decimal constant is unsigned only in ISO C90
		var min = -0x7fffffff;
		var t = x / y;
		if (t < 0x7fffffff && t > min)
			return Math.round(t) * y;
		else
		{
			t = (t > 0 ? t + .5 : (t < 0 ? t - .5 : t));
			return (t - t % 1) * y;
		}
		#end
	}
}

class PrintfError
{
	public var message:String;
	
	public function new(message:String) 
	{
		this.message = message;
	}
	
	public function toString():String
	{
		return message;
	}
}

@:publicFields
@:structInit
private class FormatArgs
{
	var flags:EnumFlags<FormatFlag>;
	var pos:Int;
	var width:Null<Int>;
	var precision:Null<Int>;
}

private enum FormatFlag
{
	Minus;
	Plus;
	Space;
	Sharp;
	Zero;
	LengthH;
	LengthUpperCaseL;
	LengthLowerCaseL;
	UpperCase;
}

private enum FormatToken
{
	Raw(string:String);
	Tag(type:FormatDataType, args:FormatArgs);
	Property(name:String);
	Unknown(string:String, pos:Int);
}

private enum FormatDataType
{
	FmtInt(type:IntType);
	FmtFloat(floatType:FloatType);
	FmtString;
	FmtPointer;
	FmtNothing;
}

private enum IntType
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