package com.demonsters.debugger
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;


	public class MonsterDebuggerPreferences
	{
		
		// Properties
		public static var properties:Dictionary = new Dictionary();


		/**
		 * Get a property, returns null if not available
		 */
		public static function getProperty(name:String):*
		{
			if (name in properties) {
				return properties[name];
			}
			return null;
		}


		/**
		 * Set a property
		 */
		public static function setProperty(name:String, value:*):void
		{
			properties[name] = value;
		}


		/**
		 * Load the preferences
		 */
		public static function load():void
		{
			// Path to the settings xml
			var file:File = File.applicationStorageDirectory.resolvePath("preferences.xml");

			// Check if the file is there
			if (file.exists) {
				
				// Read the XML
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var fileXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();

				// Loop through the XML
				var itemXML:XMLList = fileXML["item"];
				for (var i:int = 0; i < itemXML.length(); i++) {
					var v:String = String(itemXML[i].@value);
					if (v == "true" || v == "false") {
						properties[String(itemXML[i].@name)] = (String(itemXML[i].@value) == "true") ? true : false;
					} else {
						properties[String(itemXML[i].@name)] = itemXML[i].@value;
					}
				}
			}
		}


		/**
		 * Save preferences
		 */
		public static function save():void
		{
			var fileXML:XML = new XML("<preferences/>");
			var itemXML:XML;

			// Create the xml
			for (var key:Object in properties) {
				itemXML = new XML("<item/>");
				itemXML.@name = key;
				itemXML.@value = String(properties[key]);
				fileXML.appendChild(itemXML);
			}

			// Save settings
			var file:File = File.applicationStorageDirectory.resolvePath("preferences.xml");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(fileXML.toXMLString());
			fileStream.close();
		}


		/**
		 * Check is a preferences file exists
		 */
		public static function get exists():Boolean {
			var file:File = File.applicationStorageDirectory.resolvePath("preferences.xml");
			return file.exists;
		}
	}
}