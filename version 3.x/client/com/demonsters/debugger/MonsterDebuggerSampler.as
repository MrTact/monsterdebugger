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

	import flash.events.TimerEvent;
	import flash.sampler.DeleteObjectSample;
	import flash.sampler.Sample;
	import flash.sampler.StackFrame;
	import flash.sampler.clearSamples;
	import flash.sampler.getSampleCount;
	import flash.sampler.getSamples;
	import flash.sampler.pauseSampling;
	import flash.sampler.startSampling;
	import flash.utils.Dictionary;
	import flash.utils.Timer;


	/**
	 * @private
	 * The Monster Debugger sampler functions
	 */
	internal class MonsterDebuggerSampler
	{

		private static var timer:Timer;
		private static var time:Number;
		private static var methods:Dictionary;
		private static var stacks:Dictionary;
	

		/**
		 * Start the class.
		 */
		internal static function initialize():void
		{
			//methods = new Dictionary();
			//stacks = new Dictionary();
			//timer = new Timer(100);
			//timer.addEventListener(TimerEvent.TIMER, analyseSamples, false, 0, true);
			//startSampling();
		}


		/**
		 * Analyse the samples
		 */
		private static function analyseSamples(event:TimerEvent):void
		{
			pauseSampling();
			if (MonsterDebugger.enabled && MonsterDebuggerConnection.connected) {
				var handled:uint = 0;

				// Don't oversample, this stalls the computer to much
				// It does mean we can't sample large scene's...
				if (getSampleCount() < 5000) {
					while (handled < getSampleCount()) {
						var i:uint = 0;
						for each (var sample:Sample in getSamples()) {

							// Save sample
							var timeDiff:int = sample.time - time;
							if (time > 0 && timeDiff > 0 && (i >= handled) && !isInternalSample(sample)) {
								var stack:Array = getStackTrace(sample.stack);
								var stackLength:int = stack.length;
								if (stackLength > 0) {
									for (var n:int = 0; n < stackLength; n++) {
										var method:String = stack[n];
										if (method in methods) {
											methods[method].count++;
											methods[method].time += timeDiff;
										} else {
											methods[method] = {count:1, time:timeDiff};
										}
									}
								}
							}
							time = sample.time;
							i++;
						}
						handled = i;
					}
				}

//					// Save in list
//					var listMost:Array = [];
//					var listLongest:Array = [];
//					for (var name:* in methods) {
//						var value:Object = methods[name];
//						listMost[listMost.length] = {count:value.count, time:value.time, name:name};
//						listLongest[listLongest.length] = {count:value.count, time:value.time, name:name};
//					}
//					
//					// Sort
//					listMost.sortOn("count", Array.NUMERIC | Array.DESCENDING);
//					listLongest.sortOn("time", Array.NUMERIC | Array.DESCENDING);
//					if (listMost.length > 20) listMost.length = 20;
//					if (listLongest.length > 20) listLongest.length = 20;
					
					
//					trace("listMost:");
//					for (n = 0; n < listMost.length; n++) {
//						trace(listMost[n].count, listMost[n].name);
//					}
//					trace(" ");
//					trace("listLongest:");
//					for (n = 0; n < listLongest.length; n++) {
//						trace(listLongest[n].time, listLongest[n].name);
//					}
//					trace("--");


				clearSamples();
				startSampling();
			}
		}


		/**
		 * Check if the samples are from the profiler agent
		 */
		private static function isInternalSample(sample:Sample):Boolean
		{
			// Check if we have a stack
			if (sample.stack == null) {
				return true;
			}

			// Delete object are not needed for function performance
			if (sample is DeleteObjectSample) {
				return true;
			}
			
			// Check if the sample is from the MonsterDebugger
			var length:int = sample.stack.length;
			for (var i:int = 0; i < length; i++) {
				if (sample.stack[i] != null) {
					var method:String = StackFrame(sample.stack[i]).name;
					if (method.indexOf("MonsterDebugger") == 0) {
						return true;
					}
				}
			}

			return false;
		}
		
		
		/**
		 * Check if the samples are from the profiler agent
		 */
		private static function getStackTrace(stack:Array):Array
		{
			var items:Array = [];
			
			// Check if the sample is from the MonsterDebugger
			var length:int = stack.length;
			for (var i:int = 0; i < length; i++) {
				if (stack[i] != null) {
					var method:String = StackFrame(stack[i]).name;
					if (method == null
					 || method == ""
					 || method.charAt(0) == "[" 
					 || method.indexOf("global") == 0 
					 || method.indexOf("http://") != -1 
					 || method.indexOf("builtin.as$0:MethodClosure") != -1 
					 || method.indexOf("<anonymous>") != -1) {
					 	// Do nothing
					} else {
					
						// Save method name
						method = method.split("::").join(".");
						method = method.split("$/").join("::");
						method = method.split("/").join(".");
						method += "()";
						
						// Save in items
						items[items.length] = method;
					}
				}
			}
			
			return items;
		}
		
	}
}
