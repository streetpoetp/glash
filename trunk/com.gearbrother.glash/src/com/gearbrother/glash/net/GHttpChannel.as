package com.gearbrother.glash.net {
	import com.gearbrother.glash.common.utils.GHandler;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class GHttpChannel extends GChannel {
		static public const logger:ILogger = getLogger(GHttpChannel);

		private var _url:String;
		
		private var _method:String;
		
		private var _heads:Array;

		private var _stream:URLStream;

		public function GHttpChannel(url:String, method:String = URLRequestMethod.POST, heads:Array = null) {
			super();

			_url = url;
			_method = method;
			_heads = heads;
		}

		override public function call(bytes:ByteArray):void {
			_stream = new URLStream();
			_stream.addEventListener(Event.CLOSE, _handleStreamEvent);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, _handleStreamEvent);
			_stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _handleStreamEvent);
			_stream.addEventListener(ProgressEvent.PROGRESS, _handleStreamEvent);
			_stream.addEventListener(HTTPStatusEvent.HTTP_STATUS, _handleStreamEvent);
			_stream.addEventListener(Event.COMPLETE, _handleStreamEvent);
			var request:URLRequest = new URLRequest(_url);
			request.method = _method; 			//POST
			request.requestHeaders = _heads;	//[new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded")];
			request.data = bytes;
			_stream.load(request);
		}

		//================ Handle Event ===================//
		protected function _handleStreamEvent(event:Event):void {
			var stream:URLStream = event.target as URLStream;
			switch (event.type) {
				case Event.CLOSE:
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					dispatchEvent(new GChannelEvent(GChannelEvent.RECIEVE_ERROR));
					break;
				case ProgressEvent.PROGRESS:
				case HTTPStatusEvent.HTTP_STATUS:
					break;
				case Event.COMPLETE:
					var bytes:ByteArray = new ByteArray();
					stream.readBytes(bytes);
					//dispatchEvent(new GChannelEvent(GChannelEvent.RECIEVE_SUCCESS, bytes));
					stream.removeEventListener(Event.CLOSE, _handleStreamEvent);
					stream.removeEventListener(IOErrorEvent.IO_ERROR, _handleStreamEvent);
					stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _handleStreamEvent);
					stream.removeEventListener(ProgressEvent.PROGRESS, _handleStreamEvent);
					stream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, _handleStreamEvent);
					stream.removeEventListener(Event.COMPLETE, _handleStreamEvent);
					break;
			}
		}
	}
}
