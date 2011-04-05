package com.demonsters.debugger
{
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Rectangle;


	final public class MonsterDebuggerUtils
	{

		/**
		 * Strip the breaks from a string
		 * @param s: The string to strip
		 */
		public static function stripBreaks(s:String):String
		{
			s = s.replace("\n", " ");
			s = s.replace("\r", " ");
			s = s.replace("\t", " ");
			return s;
		}


		/**
		 * Converts HTML characters to regular characters
		 * @param s: The string to convert
		 */
		public static function htmlUnescape(s:String):String
		{
			if (s) {
				// Remove html elements
				if (s.indexOf("&apos;") != -1) {
					s = s.split("&apos;").join("\'");
				}
				if (s.indexOf("&quot;") != -1) {
					s = s.split("&quot;").join("\"");
				}
				if (s.indexOf("&lt;") != -1) {
					s = s.split("&lt;").join("<");
				}
				if (s.indexOf("&gt;") != -1) {
					s = s.split("&gt;").join(">");
				}
				if (s.indexOf("&amp;") != -1) {
					s = s.split("&amp;").join("&");
				}

				var xml:XML = <a/>;
				xml.replace(0, s);
				return String(xml);
			} else {
				return "";
			}
		}

		
		/**
		 * Allign to screen
		 */
		public static function checkWindow(window:NativeWindow):void
		{
			// Check if window is onscreen
			var main:Screen = Screen.mainScreen;
			var screens:Array = Screen.screens;
			var bounds:Rectangle = window.bounds.clone();
			var onScreen:Boolean = false;
			for (var i:int = 0; i < screens.length; i++) {
				if (Screen(screens[i]).bounds.intersects(bounds)) {
					onScreen = true;
				}
			}

			// Center if not onscreen
			if (!onScreen) {
				if (bounds.width > int(main.bounds.width * 0.9)) {
					bounds.width = int(main.bounds.width * 0.9);
				}
				if (bounds.height > int(main.bounds.height * 0.9)) {
					bounds.height = int(main.bounds.height * 0.9);
				}
				bounds.x = int((main.bounds.width - bounds.width) / 2);
				bounds.y = int((main.bounds.height - bounds.height) / 2);
				window.bounds = bounds;
			}
		}
	}
}