import de.polygonal.Printf.format as f;

//http://www.cplusplus.com/reference/cstdio/printf/
class TestPrintf extends haxe.unit.TestCase
{
	function new()
	{
		super();
	}
	
	function test_di()
	{
		//signed decimal integer
		
		assertEquals("392"		, f("%d"		, [392]));
		assertEquals("392"		, f("%i"		, [392]));
		assertEquals("+392"		, f("%+d"		, [392]));
		assertEquals("+392"		, f("%+i"		, [392]));
		assertEquals(" 392"		, f("% d"		, [392]));
		assertEquals(" 392"		, f("% i"		, [392]));
		assertEquals("  392"	, f("%5d"		, [392]));
		assertEquals("  392"	, f("%5i"		, [392]));
		assertEquals("00392"	, f("%05d"		, [392]));
		assertEquals("00392"	, f("%05i"		, [392]));
		assertEquals("392  "	, f("%-05d"		, [392]));
		assertEquals("392  "	, f("%-05i"		, [392]));
		assertEquals(" +392"	, f("%+5d"		, [392]));
		assertEquals(" +392"	, f("%+5i"		, [392]));
		assertEquals("+392 "	, f("%+-5d"		, [392]));
		assertEquals("+392 "	, f("%+-5i"		, [392]));
		assertEquals("  392"	, f("%*d"		, [5, 392]));
		assertEquals("  392"	, f("%*i"		, [5, 392]));
		assertEquals("392"		, f("%1d"		, [392]));
		assertEquals("392"		, f("%2d"		, [392]));
		assertEquals("392"		, f("%3d"		, [392]));
		
		assertEquals("392"		, f("%.0d"		, [392]));
		assertEquals("392"		, f("%.1d"		, [392]));
		assertEquals("392"		, f("%.2d"		, [392]));
		assertEquals("392"		, f("%.3d"		, [392]));
		assertEquals("0392"		, f("%.4d"		, [392]));
		assertEquals("00392"	, f("%.5d"		, [392]));
		
		assertEquals("0"		, f("%.1d"		, [0]));
		assertEquals(""			, f("%.0d"		, [0]));
		assertEquals("392"		, f("%ld"		, [392]));
	}
	
	function test_u()
	{
		//unsigned decimal integer
		
		assertEquals("144"		, f("%o"		, [100]));
	}
	
	function test_o()
	{
		//unsigned octal
		
		assertEquals("0144"		, f("%#o"		, [100]));
	}
	
	function test_xX()
	{
		//unsigned hexadecimal integer lowercase/uppercase
		
		assertEquals("64"		, f("%x"		, [100]));
		
		assertEquals("7fa"		, f("%x"		, [0x7fa]));
		assertEquals("7fa"		, f("%+x"		, [0x7fa]));
		assertEquals("7fa"		, f("% x"		, [0x7fa]));
		assertEquals("  7fa"	, f("%5x"		, [0x7fa]));
		assertEquals("007fa"	, f("%05x"		, [0x7fa]));
		assertEquals("7fa  "	, f("%-05x"		, [0x7fa]));
		assertEquals("  7fa"	, f("%+5x"		, [0x7fa]));
		assertEquals("7fa  "	, f("%+-5x"		, [0x7fa]));
		assertEquals("  7fa"	, f("%*x"		, [5, 0x7fa]));
		assertEquals("7fa"		, f("%1x"		, [0x7fa]));
		assertEquals("7fa"		, f("%2x"		, [0x7fa]));
		assertEquals("7fa"		, f("%3x"		, [0x7fa]));
		
		assertEquals("0x7fa"	, f("%#x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#+x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%# x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#5x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#05x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#-05x"	, [0x7fa]));
		assertEquals("0x7fa"	, f("%#+5x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#+-5x"	, [0x7fa]));
		assertEquals("0x7fa"	, f("%#*x"		, [5, 0x7fa]));
		assertEquals("0x7fa"	, f("%#1x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#2x"		, [0x7fa]));
		assertEquals("0x7fa"	, f("%#3x"		, [0x7fa]));
		
		assertEquals("0X7FA"	, f("%#X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#+X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%# X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#5X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#05X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#-05X"	, [0x7fa]));
		assertEquals("0X7FA"	, f("%#+5X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#+-5X"	, [0x7fa]));
		assertEquals("0X7FA"	, f("%#*X"		, [5, 0x7fa]));
		assertEquals("0X7FA"	, f("%#1X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#2X"		, [0x7fa]));
		assertEquals("0X7FA"	, f("%#3X"		, [0x7fa]));
	}
	
	function test_fF()
	{
		//decimal floating point, lowercase/uppercase
		
		assertEquals("3.000000"		, f("%f"		, [3.0]));
		assertEquals("3.000000"		, f("%.6f"		, [3.0]));
		assertEquals("3.000000"		, f("%.*f"		, [6, 3.0]));
		assertEquals("3.000"		, f("%.*f"		, [3, 3.0]));
		assertEquals("3.00"			, f("%.2f"		, [3.0]));
		assertEquals("3.0"			, f("%.1f"		, [3.0]));
		assertEquals("3"			, f("%.0f"		, [3.0]));
		assertEquals("3."			, f("%#.0f"		, [3.0]));
		assertEquals("3.14"			, f("%4.2f"		, [3.1416]));
		assertEquals(" 3.14"		, f("%5.2f"		, [3.1416]));
		assertEquals("3.14 "		, f("%-5.2f"	, [3.1416]));
		assertEquals("+3.14"		, f("%+5.2f"	, [3.1416]));
		assertEquals(" +3.14"		, f("%+6.2f"	, [3.1416]));
		assertEquals("+3.14 "		, f("%-+6.2f"	, [3.1416]));
		assertEquals("+3.14 "		, f("%+-6.2f"	, [3.1416]));
		assertEquals("0003."		, f("%0#5.0f"	, [3.0]));
		assertEquals("0.0000001"	, f("%.7f"		, [0.0000001]));
		assertEquals("0.00000010"	, f("%.8f"		, [0.0000001]));
		assertEquals("    3"		, f("%5.0f"		, [3.1416]));
		assertEquals(" 0003"		, f("% 05.0f"	, [3.1416]));
		assertEquals(" 003."		, f("% 0#5.0f"	, [3.1416]));
	}
	
	function test_eE()
	{
		//scientific notation (mantissa/exponent), lowercase/uppercase
		
		assertEquals("3.920000e+02"	, f("%e"		, [392]));
		assertEquals(" 3.920000e+02", f("% e"		, [392]));
		assertEquals("3.920000e+02"	, f("%e"		, [392]));
		assertEquals("3.920000E+02"	, f("%E"		, [392]));
		assertEquals("3.141600e+00"	, f("%e"		, [3.1416]));
		assertEquals("3.141600E+00"	, f("%E"		, [3.1416]));
		assertEquals("+3e+00"		, f("%+.0e"		, [3.1416]));
		assertEquals("+3.142e+00"	, f("%+.3e"		, [3.1416]));
		assertEquals("   3.142e+00"	, f("%12.3e"	, [3.1416]));
		assertEquals("  +3.142e+00"	, f("%+12.3e"	, [3.1416]));
		assertEquals("0003.142e+00"	, f("%012.3e"	, [3.1416]));
		assertEquals("+003.142e+00"	, f("%+012.3e"	, [3.1416]));
		assertEquals("-003.142e+00"	, f("%012.3e"	, [-3.1416]));
		assertEquals("-003.142e+00"	, f("%+012.3e"	, [-3.1416]));
	}
	
	function test_gG()
	{
		//use the shortest representation: %e or %f (%E or %F)
	}
	
	function test_c()
	{
		//character
		
		assertEquals("A"	, f("%c"		, [65]));
	}
	
	function test_s()
	{
		//string of characters
		
		assertEquals("hello"	, f("%s"		, ["hello"]));
		assertEquals("%hello%"	, f("%%%s%%"	, ["hello"]));
		assertEquals("he"		, f("%.2s"		, ["hello"]));
	}
	
	function test_b()
	{
		//binary
		
		assertEquals("b1010"		, f("%#b"		, [10]));
		assertEquals("10000000000"	, f("%b"		, [1024]));
	}
}