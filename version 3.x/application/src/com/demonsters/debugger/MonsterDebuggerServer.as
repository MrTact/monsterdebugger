package com.demonsters.debugger
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.TimerEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;


	public class MonsterDebuggerServer
	{

		// Group pin
		private static const PIN:String = "monsterdebugger";
		
		
		// Properties
		private static var _port:int;
		private static var _server:ServerSocket;
		private static var _clients:Dictionary;
		private static var _dispatcher:EventDispatcher;
		private static var _timer:Timer;
		
		
		// Connection properties
		private static var _multiCastIP:String = "225.225.0.1";
		private static var _multiCastPort:String = "58000";
		private static var _connection:NetConnection;
		private static var _group:NetGroup;
		private static var _id:String;
		
		
		// Callback functions
		// Format: onClientConnect(client:MonsterDebuggerClient, uid:String):void;
		public static var onClientConnect:Function;


		/**
		 * Start the server
		 */
		public static function initialize():void
		{
			// Start the server
			_port = 5800;
			_clients = new Dictionary();
			_server = new ServerSocket();
			_dispatcher = new EventDispatcher();
			_server.addEventListener(Event.CONNECT, onConnect, false, 0, false);
			_timer = new Timer(500, 1);
			_timer.addEventListener(TimerEvent.TIMER, bind, false, 0, false);

			// Create rtfmp
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_connection.connect('rtmfp:');

			bind();
		}
		
		
		/**
		 * Stop server
		 */
		public static function stop():void {
			if (_connection) {
				_connection.close();
				_connection = null;
			}
			if (_server) {
				_server.close();
				_server = null;
			}
		}
		

		/**
		 * Called whenever something happens on the peer-to-peer connection.
		 * Once the connection is established a group is joined.
		 * Once the group was joined, we setup messaging.
		 */
		private static function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					joinGroup();
					break;
				case "NetGroup.Connect.Success":
					_id = _group.convertPeerIDToGroupAddress(_connection.nearID);
					break;
			}
		}


		/**
		 * Creates a new or joins an existing NetGroup on the peer-2-peer connection
		 * that allows multicast communication.
		 */
		private static function joinGroup():void
		{
			// Create group specifications
			var groupSpec:GroupSpecifier = new GroupSpecifier(PIN);
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.routingEnabled = true;
			groupSpec.addIPMulticastAddress(_multiCastIP + ':' + _multiCastPort);

			// Create a new net group to receive posts
			_group = new NetGroup(_connection, groupSpec.groupspecWithoutAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupUpdates, false, 0, true);
		}


		/**
		 * Called whenever something happens in the group we've joined on the peer-to-peer
		 * group. Other neighbors messages are being evaluated and we send out our own
		 * address as soon as we join successfully.
		 */
		private static function onGroupUpdates(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetGroup.Neighbor.Connect":
					// Create a new client
					var client:MonsterDebuggerClient = new MonsterDebuggerClient(null, _group, event.info.neighbor);
					client.onStart = startClient;
					client.onDisconnect = removeClient;
					// Save client
					_clients[client] = {};
					break;
			}
		}


		private static function bind(e:TimerEvent = null):void
		{
			if (_server.bound) {
				_server.close();
				_server = new ServerSocket();
			}
			try {
				_server.bind(_port, "127.0.0.1");
				_server.listen();
			} catch(e:Error) {
				_timer.reset();
				_timer.start();
			}
		}


		/**
		 * Socket error
		 */
		public static function send(uid:String, id:String, data:Object):void
		{
			for (var client:Object in _clients) {
				if (_clients[client] == uid) {
					MonsterDebuggerClient(client).send(id, data);
				}
			}
		}
		

		/**
		 * Socket connected
		 */
		private static function onConnect(event:ServerSocketConnectEvent):void
		{
			// Accept socket
			var socket:Socket = event.socket;
			socket.addEventListener(Event.CLOSE, disconnect, false, 0, false);
			socket.addEventListener(IOErrorEvent.IO_ERROR, disconnect, false, 0, false);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect, false, 0, false);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler, false, 0, false);
		}


		/**
		 * Socket received the first data
		 */
		private static function dataHandler(event:ProgressEvent):void
		{
			// Get the socket
			var socket:Socket = event.target as Socket;

			// Read the bytes
			var bytes:ByteArray = new ByteArray;
			socket.readBytes(bytes, 0, socket.bytesAvailable);

			// Read the command
			var command:String = bytes.readUTFBytes(bytes.bytesAvailable);
			if (command == "<policy-file-request/>") {
				
				// Write the policy file
				var xml:ByteArray = new ByteArray();
				xml.writeUTFBytes('<?xml version="1.0"?>');
				xml.writeUTFBytes('<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">');
				xml.writeUTFBytes('<cross-domain-policy xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.adobe.com/xml/schemas/PolicyFile.xsd">');
				xml.writeUTFBytes('<site-control permitted-cross-domain-policies="master-only"/>');
				xml.writeUTFBytes('<allow-access-from domain="*" to-ports="*" secure="false"/>');
				xml.writeUTFBytes('<allow-http-request-headers-from domain="*" headers="*" secure="false"/>');
				xml.writeUTFBytes('</cross-domain-policy>');
				xml.writeByte(0);
				xml.position = 0;
				socket.writeBytes(xml, 0, xml.bytesAvailable);
				socket.flush();
				return;
			}

			// Configure wrapper
			socket.removeEventListener(Event.CLOSE, disconnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, disconnect);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);

			// Create a new client
			var client:MonsterDebuggerClient = new MonsterDebuggerClient(socket);
			client.onStart = startClient;
			client.onDisconnect = removeClient;

			// Save client
			_clients[client] = {};
		}


		/**
		 * Client is started and ready for a tab
		 * THIS IS A CALLBACK FUNCTION
		 */
		private static function startClient(client:MonsterDebuggerClient):void
		{
			// Connect
			if (onClientConnect != null) {
				onClientConnect(client);
			}
		}
		

		/**
		 * Client is done
		 * THIS IS A CALLBACK FUNCTION
		 */
		private static function removeClient(client:MonsterDebuggerClient):void
		{
			client.onData = null;
			client.onStart = null;
			client.onDisconnect = null;
			if (client in _clients) {
				_clients[client] = null;
				delete _clients[client];
			}
		}


		/**
		 * Socket error
		 */
		private static function disconnect(event:Event):void
		{
			var socket:Socket = event.target as Socket;
			socket.removeEventListener(Event.CLOSE, disconnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, disconnect);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			socket = null;
		}
	}
}