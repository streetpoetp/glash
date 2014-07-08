package com.gearbrother.glash.display.propertyHandler {
	import com.gearbrother.glash.GMain;
	import com.gearbrother.glash.common.oper.GOper;
	import com.gearbrother.glash.common.oper.GOperEvent;
	import com.gearbrother.glash.common.oper.GOperPool;
	import com.gearbrother.glash.common.oper.GQueue;
	import com.gearbrother.glash.common.utils.GClassFactory;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class GPropertyPoolOperHandler extends GPropertyHandler {
		public var succHandler:Function;

		public var processHandler:Function;

		public var failHandler:Function;

		private var _cachedOper:GOper;
		public function get cachedOper():GOper {
			return _cachedOper;
		}
		private function setOper(newValue:GOper):void {
			if (_cachedOper) {
				_cachedOper.removeEventListener(GOperEvent.OPERATION_COMPLETE, _handleOperEvent);
				pool.returnInstance(_cachedOper);
				if (isShowProccess)
					GMain.instance.processingLayer.removeOper(_cachedOper);
			}
			_cachedOper = newValue;
			if (_cachedOper) {
				if (_cachedOper.state == GOper.STATE_END) {
					_handleOperEvent();
				} else {
					_cachedOper.addEventListener(GOperEvent.OPERATION_COMPLETE, _handleOperEvent);
					if (processHandler != null)
						processHandler();
				}
				if (isShowProccess)
					GMain.instance.processingLayer.addOper(_cachedOper);
			}
		}

		private function _handleOperEvent(event:Event = null):void {
			switch (_cachedOper.resultType) {
				case GOper.RESULT_TYPE_SUCCESS:
					succHandler(this);
					break;
				case GOper.RESULT_TYPE_ERROR:
					failHandler(this);
					break;
			}
		}

		protected var pool:GOperPool;
		
		protected var queue:GQueue;
		
		protected var isShowProccess:Boolean;

		public function GPropertyPoolOperHandler(pool:GOperPool, queue:GQueue, isShowProccess:Boolean, propertyOwner:DisplayObject, isValidateLater:Boolean = false) {
			super(propertyOwner, isValidateLater);

			this.pool = pool;
			this.queue = queue;
			this.isShowProccess = isShowProccess;
		}

		override protected function doValidate():void {
			if (value) {
				setOper(pool.getInstance(value, queue) as GOper);
			} else {
				setOper(null);
			}
		}

		override public function dispose():void {
			setOper(null);
		}
	}
}
