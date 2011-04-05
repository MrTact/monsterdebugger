package controllers.panels
{
	import com.demonsters.debugger.MonsterDebuggerMenu;

	import components.Filter;
	import components.panels.ApplicationPanel;
	import events.PanelEvent;
	import com.demonsters.debugger.MonsterDebuggerConstants;
	import mx.collections.XMLListCollection;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;


	public final class ApplicationController extends EventDispatcher
	{

		[Bindable]
		private var _dataFilterd:XMLListCollection = new XMLListCollection();

		private var _data:XMLListCollection = new XMLListCollection();
		private var _panel:ApplicationPanel;
		private var _send:Function;
		private var _selectedTarget:String;


		/**
		 * Data handler for the panel
		 */
		public function ApplicationController(panel:ApplicationPanel, send:Function)
		{
			_panel = panel;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
		}


		public function get panel():ApplicationPanel
		{
			return _panel;
		}

		public function set panel(value:ApplicationPanel):void
		{
			_panel = value;
		}

		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			// Remove eventlistener
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);

			// Set tree dataprovider and listeners
			_panel.tree.dataProvider = _dataFilterd;
			_panel.tree.addEventListener(TreeEvent.ITEM_OPEN, treeOpen, false, 0, true);
			_panel.tree.addEventListener(MouseEvent.CLICK, treeClick, false, 0, true);
			_panel.tree.addEventListener(ListEvent.ITEM_ROLL_OVER, onShowInspect, false, 0, true);
			_panel.filter.addEventListener(Filter.CHANGED, filterChanged, false, 0, true);
			_panel.inspectCheckbox.addEventListener(MouseEvent.CLICK, onInspectClicked, false, 0, true);
		}

		
		/**
		 * Show a trace in an output window
		 */
		private function filterChanged(event:Event):void
		{
			filterApplication();
		}


		/**
		 * Update the filter on the application tree
		 */
		private function filterApplication():void
		{
			// Vars needed for the loops
			var data:XMLList = _data.copy();
			var targets:XMLList = data..@target;
			var children:XMLList;
			var openOld:Array;
			var openNew:Array;

			// Filter the data
			children = filterChildren(data.node);
			data.setChildren(children);

			// Get the filtered targets
			targets = data..@target;

			// Get the open items
			openOld = _panel.tree.openItems as Array;
			openNew = new Array();
			for (var i:int = 0; i < openOld.length; i++) {
				for (var n:int = 0; n < targets.length(); n++) {
					if (targets[n] == openOld[i].@target) {
						openNew.push(targets[n].parent());
					}
				}
			}

			// Set the data
			_dataFilterd.source = null;
			_dataFilterd.source = data;
			_panel.tree.openItems = openNew;
		}


		/**
		 * Recursive filter child nodes
		 * @param children: The nodes to filter
		 */
		private function filterChildren(children:XMLList):XMLList
		{
			// The return XML
			var xml:XMLList = new XMLList();

			// Variables for the loops
			var add:Boolean = true;
			var temp:*;

			// Loop through the nodes
			for (var i:int = 0; i < children.length(); i++) {
				
				// Get the data
				var name:String = String(children[i].@name).toLowerCase();
				var value:String = String(children[i].@value).toLowerCase();
				var label:String = String(children[i].@label).toLowerCase();
				var type:String = String(children[i].@type).toLowerCase();
				add = true;
				
				// Check if a filter term is given
				if (_panel.filter.words.length > 0) {
					for (var n:int = 0; n < _panel.filter.words.length; n++) {
						if (children[i].children().length() == 0) {
							if (name.indexOf(_panel.filter.words[n]) == -1 
							&& value.indexOf(_panel.filter.words[n]) == -1 
							&& label.indexOf(_panel.filter.words[n]) == -1 
							&& type.indexOf(_panel.filter.words[n]) == -1) {
								add = false;
							}
						}
					}
				}

				// Add the node if needed
				if (add) {
					if (children[i].children().length() > 0) {
						
						// The node has children
						temp = children[i];
						temp.setChildren(filterChildren(temp.children()));
						
						// The node has just one property
						if (temp.children().length() == 0) {
							temp.setChildren(XML("<node icon='iconWarning' type='Warning' label='No filter results' name='No filter results'/>"));
						}
						xml += temp;
					}
					else
					{
						// The node is just one value
						xml += children[i];
					}
				}
			}

			// Return the xml
			return xml;
		}


		private function onShowInspect(e:ListEvent):void
		{
			if (e.rowIndex == _panel.tree.selectedIndex) {
				_selectedTarget = _panel.tree.selectedItem.@target;
			}
		}


		/**
		 * Clear data
		 */
		public function clear():void
		{
			_data.removeAll();
			_dataFilterd.removeAll();
			onRefresh();
		}


		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case MonsterDebuggerConstants.COMMAND_BASE:
					_data.removeAll();
					_data.source = data["xml"].children();
					_dataFilterd.removeAll();
					_dataFilterd.source = data["xml"].children();
					_panel.tree.openItems = data["xml"].children();
					_panel.tree.invalidateList();
					_panel.tree.invalidateProperties();
					_panel.tree.invalidateDisplayList();
					_panel.tree.validateNow();
					break;
					
				case MonsterDebuggerConstants.COMMAND_GET_OBJECT:

					// Save scroll
					var treeVPOS:Number = _panel.tree.verticalScrollPosition;
					var treeHPOS:Number = _panel.tree.horizontalScrollPosition;

					// Get all targets in the current xml
					var targets:XMLList = _data.source..@target;

					// Loop through the targets
					for (var i:int = 0; i < targets.length(); i++) {
						if (targets[i] == data["xml"].node.@target) {
							targets[i].parent().setChildren(data["xml"].node.children());
							break;
						}
					}
					
					// Filter the tree
					filterApplication();

					// Set the scroll
					_panel.tree.invalidateList();
					_panel.tree.invalidateProperties();
					_panel.tree.invalidateDisplayList();
					_panel.tree.validateNow();
					_panel.tree.verticalScrollPosition = treeVPOS;
					_panel.tree.horizontalScrollPosition = treeHPOS;
					break;

				case MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT:
					_panel.inspectCheckbox.selected = true;
					break;

				case MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT:
					_panel.inspectCheckbox.selected = false;
					break;
			}
		}


		/**
		 * Inspect button clicked
		 */
		private function onInspectClicked(event:MouseEvent):void
		{
			// Send start or stop
			if (_panel.inspectCheckbox.selected) {
				_send({command:MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT});
			} else {
				_send({command:MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
			}

			// Reset
			_panel.inspectCheckbox.selected = !_panel.inspectCheckbox.selected;
		}


		/**
		 * Tree item opened
		 */
		public function treeOpen(event:TreeEvent):void
		{
			// Get the object
			if (event.item.@target != null) {
				_send({command:MonsterDebuggerConstants.COMMAND_GET_OBJECT, target:String(event.item.@target)});
			}
		}


		/**
		 * Tree item clicked
		 */
		public function treeClick(event:MouseEvent):void
		{
			var objType:String;
			var objTarget:String;

			if (event.currentTarget.selectedItem != null) {

				// Clear old values
				dispatchEvent(new PanelEvent(PanelEvent.CLEAR_PROPERTIES));

				// Save the type and target
				objType = event.currentTarget.selectedItem.@type;
				objTarget = event.currentTarget.selectedItem.@target;

				// Only get the info from objects
				if (objType != MonsterDebuggerConstants.TYPE_WARNING && objType != MonsterDebuggerConstants.TYPE_STRING && objType != MonsterDebuggerConstants.TYPE_BOOLEAN && objType != MonsterDebuggerConstants.TYPE_NUMBER && objType != MonsterDebuggerConstants.TYPE_INT && objType != MonsterDebuggerConstants.TYPE_UINT && objType != MonsterDebuggerConstants.TYPE_FUNCTION) {

					// Send commands
					_send({command:MonsterDebuggerConstants.COMMAND_HIGHLIGHT, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_PROPERTIES, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_PREVIEW, target:objTarget});
				}
			}
		}


		public function onRefresh(evt:ContextMenuEvent = null):void
		{
			if (_panel.tree.selectedItem != null) {

				// Clear old values
				dispatchEvent(new PanelEvent(PanelEvent.CLEAR_PROPERTIES));

				// Save the type and target
				var objType:String = _panel.tree.selectedItem.@type;
				var objTarget:String = _panel.tree.selectedItem.@target;
				_send({command:MonsterDebuggerConstants.COMMAND_GET_OBJECT, target:objTarget});

				if (objType != MonsterDebuggerConstants.TYPE_WARNING && objType != MonsterDebuggerConstants.TYPE_STRING && objType != MonsterDebuggerConstants.TYPE_BOOLEAN && objType != MonsterDebuggerConstants.TYPE_NUMBER && objType != MonsterDebuggerConstants.TYPE_INT && objType != MonsterDebuggerConstants.TYPE_UINT && objType != MonsterDebuggerConstants.TYPE_FUNCTION) {

					// Send commands
					_send({command:MonsterDebuggerConstants.COMMAND_HIGHLIGHT, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_PROPERTIES, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS, target:objTarget});
					_send({command:MonsterDebuggerConstants.COMMAND_GET_PREVIEW, target:objTarget});
				}
			} else {
				_send({command:MonsterDebuggerConstants.COMMAND_BASE});
			}
		}

	}
}