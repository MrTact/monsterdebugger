/**
 * 
 * This is the client code that needs to be implemented into a 
 * Flash, FLEX or AIR application to collect debug information 
 * in De Monster Debugger. 
 * 
 * Be aware that any traces made to De Monster Debugger may 
 * be viewed by others. De MonsterDebugger is intended to be 
 * used to debug Flash, FLEX or AIR applications in a protective
 * environment that they will not be used in the final launch. 
 * Please make sure that you do not send any debug material to
 * the debugger from a live running application. 
 * 
 * Use at your own risk.
 * 
 * @author		Ferdi Koomen, Joost Harts and Stijn van der Laan
 * @company 	De Monsters
 * @link 		http://www.MonsterDebugger.com
 * @version 	3.0
 * 
 *
 * Special thanks to: 
 * Arjan van Wijk and Thijs Broerse for their feedback on the 2.5 version
 * Michel Wacker for sharing his P2P AIRborne library
 *
 * 
 * Copyright 2011, De Monsters
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 */
package com.demonsters.debugger
{

	/**
	 * @private
	 * The Monster Debugger plugin base class (ALPHA).
	 */
	public class MonsterDebuggerPlugin
	{
		
		// Plugin id
		private var _id:String;
		

		/**
		 * Create the plugin and set the id.
		 * @param id: The plugin id
		 */
		public function MonsterDebuggerPlugin(id:String)
		{
			// Save the id
			_id = id;
		}
		
		
		/**
		 * Get the plugin id.
		 */
		public function get id():String {
			return _id;
		}
		

		/**
		 * Send the data from this plugin to the desktop application.
		 * @param id: The id of the plugin
		 * @param data: The data to send
		 */
		protected function send(data:Object):void {
			MonsterDebugger.send(_id, data);
		}
		
		
		/**
		 * Handle incomming data.
		 * @param item: Data from the desktop application
		 */
		public function handle(item:MonsterDebuggerData):void
		{
			// Override this function
		}
		
	}
	
}