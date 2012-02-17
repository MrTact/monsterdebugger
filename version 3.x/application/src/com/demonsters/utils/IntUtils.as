package com.demonsters.utils
{

	final public class IntUtils
	{
		
		
		private static var hexChars:String = "0123456789abcdef";
		
		
		/**
		 * Rotates x left n bits
		 */
		public static function rol ( x:int, n:int ):int {
			return ( x << n ) | ( x >>> ( 32 - n ) );
		}
		
		
		/**
		 * Rotates x right n bits
		 */
		public static function ror ( x:int, n:int ):uint {
			var nn:int = 32 - n;
			return ( x << nn ) | ( x >>> ( 32 - nn ) );
		}
		

		/**
		 * Outputs the hex value of a int, allowing the developer to specify
		 * the endinaness in the process.  Hex output is lowercase.
		 * @param n The int value to output as hex
		 * @param bigEndian Flag to output the int as big or little endian
		 */
		public static function toHex( n:int, bigEndian:Boolean = false ):String {
			var s:String = "";
			
			if ( bigEndian ) {
				for ( var i:int = 0; i < 4; i++ ) {
					s += hexChars.charAt( ( n >> ( ( 3 - i ) * 8 + 4 ) ) & 0xF ) 
						+ hexChars.charAt( ( n >> ( ( 3 - i ) * 8 ) ) & 0xF );
				}
			} else {
				for ( var x:int = 0; x < 4; x++ ) {
					s += hexChars.charAt( ( n >> ( x * 8 + 4 ) ) & 0xF )
						+ hexChars.charAt( ( n >> ( x * 8 ) ) & 0xF );
				}
			}
			
			return s;
		}
	}
}
