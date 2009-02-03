package 
{
	
	/********************************
	 * This is a dummy custom class
	 *******************************/
	 
	public class Person
	{
		
		// The persons information
		public var name:String = "Mike";
		public var age:int = 25;
		public var gender:String = "male";
		
		
		// The amount of beer and food
		private var _beer:int = 0;
		private var _food:int = 0;
		
		
		/**
		 * Just an empty constructor
		 */
		public function Person()
		{
			// Do nothing
		}
		
		
		// The amount of beer is read-only
		public function get beer():int
		{
			return _beer;
		}
		
		
		// The amount of beer is read-only
		public function get food():int
		{
			return _food;
		}
		
		
		/**
		 * Add beer to the person and returns the class
		 */
		public function addBeer():Person
		{
			// Add the beer
			_beer++;
			
			// Return the class
			return this;
		}
		
		
		/**
		 * Add food to the person and returns the class
		 */
		public function addFood():Person
		{
			// Add the beer
			_food++;
			
			// Return the class
			return this;
		}
		
	}
	
}