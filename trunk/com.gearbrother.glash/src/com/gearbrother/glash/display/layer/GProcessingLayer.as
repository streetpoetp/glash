package com.gearbrother.glash.display.layer {
	import com.gearbrother.glash.common.oper.GOper;
	import com.gearbrother.glash.common.oper.GOperEvent;
	import com.gearbrother.glash.common.oper.GOperGroupListener;
	import com.gearbrother.glash.common.oper.GQueue;
	import com.gearbrother.glash.display.layout.impl.CenterLayout;
	
	import flash.events.Event;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	/**
	 * 素材加载, 数据加载, 操作.. 等待框
	 * 初始化资源加载等待框
	 * 为了避免数据频繁交换而造成等待框频繁闪现造成的视觉疲劳，定为0.5秒前只屏蔽操作，0.5秒后显示等待框.这样只要数据在0.5秒前返回便不会出现等待框.
	 *
	 * @author feng.lee
	 * create on 2012-6-11 下午8:22:33
	 * @see com.gearbrother.glash.common.resource.GResourceLoader
	 */
	public class GProcessingLayer extends GAlertLayer {
		static public const logger:ILogger = getLogger(GProcessingLayer);
		
		private var _isOnHandling:Boolean;
		
		private var _opers:Array;

		public function GProcessingLayer() {
			super();

			maskColor = 0x000000;
			maskAlpha = .1;

			layout = new CenterLayout();
			_opers = [];
		}

		public function addOper(value:GOper):void {
			if (_isOnHandling) {
				
			} else {
				
			}
			if (value.state == GOper.STATE_END) {
				//do nothing
			} else {
				value.addEventListener(GOperEvent.OPERATION_START, handleQperEvent);
				value.addEventListener(GOperEvent.OPERATION_COMPLETE, handleQperEvent);
				_refresh();
			}
		}
		
		public function removeOper(value:GOper):void {
			var at:int = _opers.indexOf(value);
			_opers.splice(at, 1);
		}
		
		public function addListener(listener:GOperGroupListener):void {
			var opers:Array = listener.opers;
			for each (var oper:GOper in opers) {
				addOper(oper);
			}
		}
		
		public function removeListener(listener:GOperGroupListener):void {
			var opers:Array = listener.opers;
			for each (var oper:GOper in opers) {
				removeOper(oper);
			}
		}
		
		private function _refresh():void {
			
		}

		public function handleQperEvent(event:Event):void {
			enableTick = true;
		}

		override public function tick(interval:int):void {
			for each (var oper:GOper in _opers) {
				logger.debug(oper);
			}
			enableTick = false;
		}
	}
}
