import Printf;
import Printf.format as f;

//http://www.cplusplus.com/reference/cstdio/printf/
class TestPrintf extends haxe.unit.TestCase
{
	function new()
	{
		super();
	}
	
	/**
		binary
	**/
	function test_b()
	{
		assertEquals("10"			, f("%b"		, [2]));
		assertEquals("0b1010"		, f("%#b"		, [10]));
		assertEquals("10000000000"	, f("%b"		, [1024]));
		assertEquals("0"			, f("%b"		, [0]));
		assertEquals("0"			, f("%#b"		, [0]));
		assertEquals(""				, f("%.0b"		, [0]));
		assertEquals(""				, f("%#.0b"		, [0]));
		assertEquals("111"			, f("%b"		, [7]));
		assertEquals("111"			, f("%+b"		, [7]));
		assertEquals("111"			, f("% b"		, [7]));
		assertEquals("  111"		, f("%5b"		, [7]));
		assertEquals("00111"		, f("%05b"		, [7]));
		assertEquals("111  "		, f("%-05b"		, [7]));
		assertEquals("  111"		, f("%+5b"		, [7]));
		assertEquals("111  "		, f("%+-5b"		, [7]));
		assertEquals("  111"		, f("%*b"		, [5, 7]));
		assertEquals("111"			, f("%1b"		, [7]));
		assertEquals("111"			, f("%2b"		, [7]));
		assertEquals("111"			, f("%3b"		, [7]));
		assertEquals("0b111"		, f("%#b"		, [7]));
		assertEquals("0b111"		, f("%#+b"		, [7]));
		assertEquals("0b111"		, f("%# b"		, [7]));
		assertEquals("0b111"		, f("%#5b"		, [7]));
		assertEquals("0b111"		, f("%#05b"		, [7]));
		assertEquals("0b111"		, f("%#-05b"	, [7]));
		assertEquals("0b111"		, f("%#+5b"		, [7]));
		assertEquals("0b111"		, f("%#+-5b"	, [7]));
		assertEquals("0b111"		, f("%#*b"		, [5, 7]));
		assertEquals("0b111"		, f("%#1b"		, [7]));
		assertEquals("0b111"		, f("%#2b"		, [7]));
		assertEquals("0b111"		, f("%#3b"		, [7]));
		assertEquals("000111"		, f("%.6b"		, [7]));
		assertEquals("0b000111"		, f("%#.6b"		, [7]));
		assertEquals(" 0b000111"	, f("%#9.6b"	, [7]));
		assertEquals("0b000111 "	, f("%#-9.6b"	, [7]));
		assertEquals("  0b000111"	, f("%#010.6b"	, [7]));
		assertEquals("00111"		, f("%05b"		, [7]));
		assertEquals("0000000111"	, f("%010b"		, [7]));
		assertEquals("    000111"	, f("%010.6b"	, [7]));
		assertEquals("       111"	, f("%010.0b"	, [7]));
		assertEquals("  0b000111"	, f("%#010.6b"	, [7]));
		assertEquals("  0b000111"	, f("%# 10.6b"	, [7]));
		assertEquals("    000111"	, f("%010.6b"	, [7]));
		
		assertEquals("11111111", f("%b"	, [0xff]));
		assertEquals("1111111111111111"	, f("%b"	, [0xffff]));
		assertEquals("1111111111111111111111111111111"	, f("%31b"	, [0x7FFFFFFF]));
		assertEquals("01111111111111111111111111111111"	, f("%032b"	, [0x7FFFFFFF]));
		assertEquals("11111111111111111111111111111111"	, f("%032b"	, [-1]));
	}
	
	/**
		unsigned octal
	**/
	function test_o()
	{
		assertEquals("0"			, f("%o"		, [0]));
		assertEquals("0"			, f("%#o"		, [0]));
		assertEquals(""				, f("%.0o"		, [0]));
		assertEquals("0"			, f("%#.0o"		, [0]));
		assertEquals("000"			, f("%.3o"		, [0]));
		assertEquals("000"			, f("%#.3o"		, [0]));
		assertEquals(" 000"			, f("%#4.3o"	, [0]));
		assertEquals("144"			, f("%o"		, [100]));
		assertEquals("0144"			, f("%#o"		, [100]));
		assertEquals("144"			, f("%o"		, [100]));
		assertEquals("144"			, f("%+o"		, [100]));
		assertEquals("144"			, f("%-o"		, [100]));
		assertEquals("144"			, f("% o"		, [100]));
		assertEquals("0144"			, f("%#o"		, [100]));
		assertEquals("0144"			, f("%#+o"		, [100]));
		assertEquals("0144"			, f("%#-o"		, [100]));
		assertEquals("0144"			, f("%# o"		, [100]));
		assertEquals("0144"			, f("%#-o"		, [100]));
		assertEquals("0144"			, f("%#-+o"		, [100]));
		assertEquals("0144"			, f("%#- o"		, [100]));
		assertEquals("  144"		, f("%5o"		, [100]));
		assertEquals("  144"		, f("%+5o"		, [100]));
		assertEquals("144  "		, f("%-5o"		, [100]));
		assertEquals("  144"		, f("% 5o"		, [100]));
		assertEquals(" 0144"		, f("%#5o"		, [100]));
		assertEquals(" 0144"		, f("%#+5o"		, [100]));
		assertEquals("0144 "		, f("%#-5o"		, [100]));
		assertEquals(" 0144"		, f("%# 5o"		, [100]));
		assertEquals("00144"		, f("%#.5o"		, [100]));
		assertEquals("000144"		, f("%#.6o"		, [100]));
		assertEquals("   000144"	, f("%#9.6o"	, [100]));
		assertEquals("000144   "	, f("%#-9.6o"	, [100]));
		assertEquals("    000144"	, f("%010.6o"	, [100]));
		assertEquals("    000144"	, f("%#010.6o"	, [100]));
		assertEquals("00144"		, f("%05o"		, [100]));
		assertEquals("0000000144"	, f("%010o"		, [100]));
		assertEquals("    000144"	, f("%010.6o"	, [100]));
		assertEquals("       144"	, f("%010.0o"	, [100]));
		assertEquals("    000144"	, f("%#010.6o"	, [100]));
		assertEquals("    000144"	, f("%# 10.6o"	, [100]));
		assertEquals("    000144"	, f("%# 10.6o"	, [100]));
	}
	
	/**
		unsigned hexadecimal integer lowercase/uppercase
	**/
	function test_xX()
	{
		assertEquals("0"			, f("%x"		, [0]));
		assertEquals("0"			, f("%#x"		, [0]));
		assertEquals(""				, f("%.0x"		, [0]));
		assertEquals(""				, f("%#.0x"		, [0]));
		assertEquals("64"			, f("%x"		, [100]));
		assertEquals("7fa"			, f("%x"		, [0x7fa]));
		assertEquals("7fa"			, f("%+x"		, [0x7fa]));
		assertEquals("7fa"			, f("% x"		, [0x7fa]));
		assertEquals("  7fa"		, f("%5x"		, [0x7fa]));
		assertEquals("007fa"		, f("%05x"		, [0x7fa]));
		assertEquals("7fa  "		, f("%-05x"		, [0x7fa]));
		assertEquals("  7fa"		, f("%+5x"		, [0x7fa]));
		assertEquals("7fa  "		, f("%+-5x"		, [0x7fa]));
		assertEquals("  7fa"		, f("%*x"		, [5, 0x7fa]));
		assertEquals("7fa"			, f("%1x"		, [0x7fa]));
		assertEquals("7fa"			, f("%2x"		, [0x7fa]));
		assertEquals("7fa"			, f("%3x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#+x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%# x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#5x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#05x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#-05x"	, [0x7fa]));
		assertEquals("0x7fa"		, f("%#+5x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#+-5x"	, [0x7fa]));
		assertEquals("0x7fa"		, f("%#*x"		, [5, 0x7fa]));
		assertEquals("0x7fa"		, f("%#1x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#2x"		, [0x7fa]));
		assertEquals("0x7fa"		, f("%#3x"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#+X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%# X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#5X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#05X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#-05X"	, [0x7fa]));
		assertEquals("0X7FA"		, f("%#+5X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#+-5X"	, [0x7fa]));
		assertEquals("0X7FA"		, f("%#*X"		, [5, 0x7fa]));
		assertEquals("0X7FA"		, f("%#1X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#2X"		, [0x7fa]));
		assertEquals("0X7FA"		, f("%#3X"		, [0x7fa]));
		assertEquals("0007fa"		, f("%.6x"		, [0x7fa]));
		assertEquals("0x0007fa"		, f("%#.6x"		, [0x7fa]));
		assertEquals(" 0x0007fa"	, f("%#9.6x"	, [0x7fa]));
		assertEquals("0x0007fa "	, f("%#-9.6x"	, [0x7fa]));
		assertEquals("  0x0007fa"	, f("%#010.6x"	, [0x7fa]));
		assertEquals("007fa"		, f("%05x"		, [0x7fa]));
		assertEquals("00000007fa"	, f("%010x"		, [0x7fa]));
		assertEquals("    0007fa"	, f("%010.6x"	, [0x7fa]));
		assertEquals("       7fa"	, f("%010.0x"	, [0x7fa]));
		assertEquals("  0x0007fa"	, f("%#010.6x"	, [0x7fa]));
		assertEquals("  0x0007fa"	, f("%# 10.6x"	, [0x7fa]));
		assertEquals("    0007fa"	, f("%010.6x"	, [0x7fa]));
	}
	
	/**
		signed decimal integer
	**/
	function test_di()
	{
		assertEquals("392"			, f("%d"		, [392]));
		assertEquals("392"			, f("%i"		, [392]));
		assertEquals("+392"			, f("%+d"		, [392]));
		assertEquals("+392"			, f("%+i"		, [392]));
		assertEquals(" 392"			, f("% d"		, [392]));
		assertEquals("+392"			, f("%+ d"		, [392]));
		assertEquals(" 392"			, f("% i"		, [392]));
		assertEquals("  392"		, f("%5d"		, [392]));
		assertEquals("  392"		, f("%5i"		, [392]));
		assertEquals("00392"		, f("%05d"		, [392]));
		assertEquals("00392"		, f("%05i"		, [392]));
		assertEquals("392  "		, f("%-05d"		, [392]));
		assertEquals("392  "		, f("%-05i"		, [392]));
		assertEquals(" +392"		, f("%+5d"		, [392]));
		assertEquals(" +392"		, f("%+5i"		, [392]));
		assertEquals("+392 "		, f("%+-5d"		, [392]));
		assertEquals("+392 "		, f("%+-5i"		, [392]));
		assertEquals("  392"		, f("%*d"		, [5, 392]));
		assertEquals("  392"		, f("%*i"		, [5, 392]));
		assertEquals("392"			, f("%1d"		, [392]));
		assertEquals("392"			, f("%2d"		, [392]));
		assertEquals("392"			, f("%3d"		, [392]));
		assertEquals("392"			, f("%.0d"		, [392]));
		assertEquals("392"			, f("%.1d"		, [392]));
		assertEquals("392"			, f("%.2d"		, [392]));
		assertEquals("392"			, f("%.3d"		, [392]));
		assertEquals("0392"			, f("%.4d"		, [392]));
		assertEquals("00392"		, f("%.5d"		, [392]));
		assertEquals(" 00392"		, f("%6.5d"		, [392]));
		assertEquals("0"			, f("%.1d"		, [0]));
		assertEquals(""				, f("%.0d"		, [0]));
		assertEquals("392"			, f("%ld"		, [392]));
		assertEquals("-392"			, f("%d"		, [-392]));
		assertEquals("-392"			, f("%i"		, [-392]));
		assertEquals("-392"			, f("%+d"		, [-392]));
		assertEquals("-392"			, f("%+i"		, [-392]));
		assertEquals("+00392"		, f("%+.5d"		, [392]));
		assertEquals("+00392"		, f("%+ .5d"	, [392]));
		assertEquals(" 00392"		, f("% .5d"		, [392]));
		assertEquals("-00392"		, f("%+.5d"		, [-392]));
		assertEquals("-00392"		, f("%+ .5d"	, [-392]));
		assertEquals("-00392"		, f("%.5d"		, [-392]));
		assertEquals(" +00392"		, f("%+6.5d"	, [392]));
		assertEquals(" +00392"		, f("%+ 6.5d"	, [392]));
		assertEquals("  00392"		, f("% 6.5d"	, [392]));
		assertEquals(" -00392"		, f("%+6.5d"	, [-392]));
		assertEquals(" -00392"		, f("%+ 6.5d"	, [-392]));
		assertEquals(" -00392"		, f("%6.5d"		, [-392]));
		assertEquals("+00392"		, f("%+-.5d"	, [392]));
		assertEquals("+00392"		, f("%+- .5d"	, [392]));
		assertEquals(" 00392"		, f("% -.5d"	, [392]));
		assertEquals("-00392"		, f("%+-.5d"	, [-392]));
		assertEquals("-00392"		, f("%+- .5d"	, [-392]));
		assertEquals("-00392"		, f("%-.5d"		, [-392]));
		assertEquals("+00392"		, f("%+-6.5d"	, [392]));
		assertEquals("+00392"		, f("%+- 6.5d"	, [392]));
		assertEquals(" 00392"		, f("% -6.5d"	, [392]));
		assertEquals("-00392"		, f("%+-6.5d"	, [-392]));
		assertEquals("-00392"		, f("%+- 6.5d"	, [-392]));
		assertEquals("-00392"		, f("%-6.5d"	, [-392]));
		assertEquals("+00392 "		, f("%+-7.5d"	, [392]));
		assertEquals("+00392 "		, f("%+- 7.5d"	, [392]));
		assertEquals(" 00392 "		, f("% -7.5d"	, [392]));
		assertEquals("-00392 "		, f("%+-7.5d"	, [-392]));
		assertEquals("-00392 "		, f("%+- 7.5d"	, [-392]));
		assertEquals("-00392 "		, f("%-7.5d"	, [-392]));
		assertEquals("-000000123"	, f("%+010d"	, [-123]));
		assertEquals("0000000123"	, f("%09.10d"	, [123]));
	}
	
	/**
		unsigned decimal integer
	**/
	function test_u()
	{
		assertEquals("0"				, f("%u"		, [0]));
		assertEquals(""					, f("%.0u"		, [0]));
		assertEquals("0"				, f("%.1u"		, [0]));
		assertEquals("00"				, f("%.2u"		, [0]));
		assertEquals("100"				, f("%u"		, [100]));
		assertEquals("4294967294"		, f("%u"		, [-2]));
		assertEquals("4294967294"		, f("%#u"		, [-2]));
		assertEquals("4294967294"		, f("%+u"		, [-2]));
		assertEquals("4294967294"		, f("% u"		, [-2]));
		assertEquals("4294967294"		, f("%#+ u"		, [-2]));
		assertEquals("004294967294"		, f("%.12u"		, [-2]));
		assertEquals("  004294967294"	, f("%14.12u"	, [-2]));
		assertEquals("    4294967294"	, f("%14u"		, [-2]));
		assertEquals("004294967294  "	, f("%-14.12u"	, [-2]));
		assertEquals("4294967294    "	, f("%-14u"		, [-2]));
	}
	
	/**
		decimal floating point, lowercase/uppercase
	**/
	function test_fF()
	{
		assertEquals("+0.0"			, f("%+.1f"		, [0.0]));
		
		assertEquals("3.000000"		, f("%f"		, [3.0]));
		assertEquals("3.000000"		, f("%.6f"		, [3.0]));
		assertEquals("3.000000"		, f("%.*f"		, [6, 3.0]));
		assertEquals("3.000"		, f("%.*f"		, [3, 3.0]));
		assertEquals("3.00"			, f("%.2f"		, [3.0]));
		assertEquals("3.0"			, f("%.1f"		, [3.0]));
		assertEquals("3"			, f("%.0f"		, [3.0]));
		assertEquals("3."			, f("%#.0f"		, [3.0]));
		assertEquals("3.0"			, f("%#.1f"		, [3.0]));
		assertEquals("3.14"			, f("%4.2f"		, [3.1416]));
		assertEquals(" 3.14"		, f("%5.2f"		, [3.1416]));
		assertEquals("3.14 "		, f("%-5.2f"	, [3.1416]));
		assertEquals("3.141600"		, f("%-2.6f"	, [3.1416]));
		assertEquals("3.1410    "	, f("%0-10.4f"	, [3.141]));
		assertEquals("3.1410    "	, f("%-010.4f"	, [3.141]));
		assertEquals("+3.14"		, f("%+5.2f"	, [3.1416]));
		assertEquals(" +3.14"		, f("%+6.2f"	, [3.1416]));
		assertEquals("+3.14 "		, f("%-+6.2f"	, [3.1416]));
		assertEquals("+3.14 "		, f("%+-6.2f"	, [3.1416]));
		assertEquals("0003."		, f("%0#5.0f"	, [3.0]));
		assertEquals("    3"		, f("%5.0f"		, [3.1416]));
		assertEquals("00003"		, f("%05.0f"	, [3.0]));
		assertEquals(" 0003"		, f("% 05.0f"	, [3.1416]));
		assertEquals(" 003."		, f("% 0#5.0f"	, [3.1416]));
		
		assertEquals("-3.000000"	, f("%f"		, [-3.0]));
		assertEquals("-3.000000"	, f("%.6f"		, [-3.0]));
		assertEquals("-3.000000"	, f("%.*f"		, [6, -3.0]));
		assertEquals("-3.000"		, f("%.*f"		, [3, -3.0]));
		assertEquals("-3.00"		, f("%.2f"		, [-3.0]));
		assertEquals("-3.0"			, f("%.1f"		, [-3.0]));
		assertEquals("-3"			, f("%.0f"		, [-3.0]));
		assertEquals("-3"			, f("%+.0f"		, [-3.0]));
		assertEquals("-3."			, f("%#.0f"		, [-3.0]));
		assertEquals("-3.0"			, f("%#.1f"		, [-3.0]));
		assertEquals("-3.14"		, f("%4.2f"		, [-3.1416]));
		assertEquals(" -3.14"		, f("%6.2f"		, [-3.1416]));
		assertEquals("-3.14 "		, f("%-6.2f"	, [-3.1416]));
		assertEquals("-3.141600"	, f("%-2.6f"	, [-3.1416]));
		assertEquals("-3.1410   "	, f("%0-10.4f"	, [-3.141]));
		assertEquals("-3.1410   "	, f("%-010.4f"	, [-3.141]));
		assertEquals("-3.14"		, f("%+5.2f"	, [-3.1416]));
		assertEquals(" -3.14"		, f("%+6.2f"	, [-3.1416]));
		assertEquals("-3.14 "		, f("%-+6.2f"	, [-3.1416]));
		assertEquals("-3.14 "		, f("%+-6.2f"	, [-3.1416]));
		assertEquals("-003."		, f("%0#5.0f"	, [-3.0]));
		assertEquals("-0003"		, f("%05.0f"	, [-3.0]));
		assertEquals("-2.3"			, f("%+.1f"		, [-2.34]));
		assertEquals("-0.0"			, f("%+.1f"		, [-0.01]));
	}
	
	/**
		scientific notation (mantissa/exponent), lowercase/uppercase
	**/
	function _test_eE()
	{
		// assertEquals("3.920000e+02"	, f("%e"		, [392]));
		// assertEquals(" 3.920000e+02", f("% e"		, [392]));
		// assertEquals("3.920000e+02"	, f("%e"		, [392]));
		// assertEquals("3.920000E+02"	, f("%E"		, [392]));
		// assertEquals("3.141600e+00"	, f("%e"		, [3.1416]));
		// assertEquals("3.141600E+00"	, f("%E"		, [3.1416]));
		// assertEquals("+3e+00"		, f("%+.0e"		, [3.1416]));
		// assertEquals("+3.142e+00"	, f("%+.3e"		, [3.1416]));
		// assertEquals("   3.142e+00"	, f("%12.3e"	, [3.1416]));
		// assertEquals("  +3.142e+00"	, f("%+12.3e"	, [3.1416]));
		// assertEquals("0003.142e+00"	, f("%012.3e"	, [3.1416]));
		// assertEquals("+003.142e+00"	, f("%+012.3e"	, [3.1416]));
		// assertEquals("-003.142e+00"	, f("%012.3e"	, [-3.1416]));
		// assertEquals("-003.142e+00"	, f("%+012.3e"	, [-3.1416]));
		
		//printf("[%.3e]\n", 0.0);
		//printf("[%.3e]\n", 1.0);
		//printf("[%.3e]\n", 0.1);
		//[0.000e+00]
		//[1.000e+00]
		//[1.000e-01]
		
		// Printf.DEFAULT_NUM_EXP_DIGITS = 3;
		// assertEquals("+3.142e+000"	, f("%+.3e"		, [3.1416]));
		// Printf.DEFAULT_NUM_EXP_DIGITS = 1;
		//assertEquals("+3.014e+1"	, f("%+.4e"		, [1000000000.]));
		// Printf.DEFAULT_NUM_EXP_DIGITS = 2;
		
		//printf("[%.3e]\n", 0.2);
		//printf("[%.3e]\n", 2.0);
		//printf("[%.3e]\n", 300.0);
		//printf("[%.3e]\n", 4321768.0);
		//printf("[%.3e]\n", -53.0);
		//printf("[%.3e]\n", 6720000000.);
		//printf("[%.3e]\n", 0.00000000751);
		//[2.000e-01]
		//[2.000e+00]
		//[3.000e+02]
		//[4.322e+06]
		//[-5.300e+01]
		//[6.720e+09]
		//[7.510e-09]
	}
	
	function _test_gG()
	{
		//use the shortest representation: %e or %f (%E or %F)
		
		//assertEquals("3.141592653589793", sprintf("%g", pi))
		//assert.equal("3", sprintf("%.1g", pi))
		
		// assertEquals("3.14159", f("%.6g", [Math.PI]));
        // assertEquals("3.14", f("%.3g", pi]))
	}
	
	/**
		character
	**/
	function test_c()
	{
		assertEquals("A"	, f("%c"		, [65]));
		assertEquals(" A"	, f("%2c"		, [65]));
		assertEquals("A "	, f("%-2c"		, [65]));
	}
	
	/**
		string of characters
	**/
	function test_s()
	{
		assertEquals("%s"		, f("%s"		, ["%s"]));
		assertEquals("hello"	, f("%s"		, ["hello"]));
		assertEquals("%hello%"	, f("%%%s%%"	, ["hello"]));
		assertEquals("he"		, f("%.2s"		, ["hello"]));
		assertEquals("  he"		, f("%4.2s"		, ["hello"]));
		assertEquals("he  "		, f("%-4.2s"	, ["hello"]));
		assertEquals("a ,b   "	, f("%-2s,%-4s"	, ["a", "b"]));
	}
	
	
	
	
	
	
	/*function _test_t()
	{
		assertEquals("true", sprintf("%t", true));
		assertEquals("t", sprintf("%.1t", true));
		assertEquals("true", sprintf("%t", "true"));
		assertEquals("true", sprintf("%t", 1));
		assertEquals("false", sprintf("%t", false));
		assertEquals("f", sprintf("%.1t", false));
		assertEquals("false", sprintf("%t", ""));
		assertEquals("false", sprintf("%t", 0));
	}*/
	
	/*function _test_T()
	{
		assertEqual('undefined', sprintf('%T', undefined));
		assertEqual('null', sprintf('%T', null));
		assertEqual('boolean', sprintf('%T', true));
		assertEqual('number', sprintf('%T', 42));
		assertEqual('string', sprintf('%T', "This is a string"));
		assertEqual('function', sprintf('%T', Math.log));
		assertEqual('array', sprintf('%T', [1, 2, 3]));
		assertEqual('object', sprintf('%T', {foo: 'bar'}));
		assertEqual('regexp', sprintf('%T', /<("[^"]*"|'[^']*'|[^'">])*>/));
	}*/
	
	function _test_ref()
	{
		//positional access (extra)
		
		//assertEquals("Joe is 32 years old, (name=       Joe, age=32), foo", f("%s is %d years old, (name=%1$10s, age=%2$*s), %s", ["Joe", 32, 10, "foo"]));
		
		//var x = Printf.format("%s is %d years old, and his name is %1$s", ["Joe", 32]);
		//assertTrue(true);
	}
	
	function _test_obj()
	{
		//named 
		//var x = Printf.format("%(name) is %(age), and wants to be a %d", [{name:"Joe", age:32}, 100]);
		//trace( "x : " + x );
	}
}