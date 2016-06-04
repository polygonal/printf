import haxe.unit.TestRunner;

class UnitTest extends TestRunner
{
	static function main()
	{
		new UnitTest();
	}
	
	function new()
	{
		super();
		
		#if flash
			flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
			var output = "";
			var f = TestRunner.print;
			f("");
			cast(flash.Lib.current.getChildAt(0), flash.text.TextField).defaultTextFormat =
				new flash.text.TextFormat("Courier New", 11);
			TestRunner.print = function(v:Dynamic)
			{
				output += v;
				f(v);
			}
		#end
		
		var flags = [];
		
		#if debug
		flags.push("-debug");
		#end
		#if generic
		flags.push("-D generic");
		#end
		#if no_inline
		flags.push("--no-inline");
		#end
		
		TestRunner.print('compile flags: ${flags.join(" ")}\n');
		
		add(new TestPrintf());
		var success = run();
		
		#if (flash && !ide)
		if (success) flash.system.System.exit(2);
		#elseif js
		(untyped process).exit(success ? 0 : 1);
		#elseif sys
		Sys.exit(success ? 0 : 1);
		#end
	}
}