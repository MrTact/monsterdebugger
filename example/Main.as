package
{
	
	/***************************************************************************
	 * This is an example document class that uses De MonsterDebugger.
	 ***************************************************************************/
	 
	// Import classes
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import fl.controls.Button;
	import nl.demonsters.debugger.MonsterDebugger;
	
	
	public class Main extends Sprite
	{
		
		// De MonsterDebugger instance
		// This is needed to explore your live application
		private var debugger:MonsterDebugger;

		
		/***********************
		 * EXAMPLE DATA OBJECTS
		 ***********************/
		public var exampleArray:Array = ["Apples", "Oranges", "Melons"];
		public var exampleObject:Object = {name:"Mike", age:25, gender:"male"};
		public var exampleClass:Person = new Person();
		public var exampleXML:XML = new XML('<cars><car id="1" color="#FF0000">A nice red car</car><car id="2" color="#FFFF00">A yellow cab</car></cars>');
		public var exampleXMLList:XMLList = new XMLList('<car id="1" color="#FF0000">A nice red car</car><car id="2" color="#FFFF00">A yellow cab</car>');
		public var exampleVector:Vector.<String> = new Vector.<String>();
		
		
		public function Main()
		{
			// Fill the vector
			exampleVector.push("Apples", "Oranges", "Melons");
			
			// Initialize De MonsterDebugger
			debugger = new MonsterDebugger(this);
			
			// Send a trace
			MonsterDebugger.trace(this, "Hello World!");
			
			// Setup the event listeners on the buttons
			button1.addEventListener(MouseEvent.CLICK, buttonClickHander);
			button2.addEventListener(MouseEvent.CLICK, buttonClickHander);
			button3.addEventListener(MouseEvent.CLICK, buttonClickHander);
			button4.addEventListener(MouseEvent.CLICK, buttonClickHander);
			button5.addEventListener(MouseEvent.CLICK, buttonClickHander);
			button6.addEventListener(MouseEvent.CLICK, buttonClickHander);
		}
		
		
		/**
		 * A button has been clicked
		 */
		private function buttonClickHander(event:MouseEvent):void
		{
			switch(event.target)
			{
				// Trace an Array
				case button1:
				MonsterDebugger.trace(this, exampleArray);
				break;
				
				// Trace an Vector
				case button2:
				MonsterDebugger.trace(this, exampleVector);
				break;
				
				// Trace an Object
				case button3:
				MonsterDebugger.trace(this, exampleObject);
				break;
				
				// Trace a XML
				case button4:
				MonsterDebugger.trace(this, exampleXML);
				break;
				
				// Trace an XML List
				case button5:
				MonsterDebugger.trace(this, exampleXMLList);
				break;
				
				// Trace an class
				case button6:
				MonsterDebugger.trace(this, exampleClass);
				break;
			}
		}
		
		
		/**
		 * Start an animation
		 * Note: This public function can be called from the debugger!
		 */
		public function animationStart():void
		{
			addEventListener(Event.ENTER_FRAME, move);
		}
		
		
		/**
		 * Stop an animation
		 * Note: This public function can be called from the debugger!
		 */
		public function animationStop():void
		{
			removeEventListener(Event.ENTER_FRAME, move);
		}

		
		/**
		 * Move the ball on the stage
		 * @param event: Enter frame event
		 */
		private function move(event:Event):void
		{			
			ball.x -= 10;
			ball.rotationX += 5;
			ball.rotationY += 5;
			ball.rotationZ += 5;
			if (ball.x < -200) {
				ball.x = 1000;
			}
		}
		
	}
}