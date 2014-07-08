package com.gearbrother.glash.common.oper {
	
	/**
	 * @author feng.lee
	 * create on 2012-11-9 下午5:36:59
	 */
	public class GOperGroupListener {
		private var _succHandler:Function;

		private var _opers:Array;
		public function get opers():Array {
			return _opers.concat();
		}
		
		public function get isRunning():Boolean {
			return _opers.length == 0;
		}

		public function GOperGroupListener(opers:Array) {
			_opers = opers;
		}

		public function addOper(oper:GOper):GOperGroupListener {
			if (oper.state != GOper.STATE_END) {
				oper.addEventListener(GOperEvent.OPERATION_COMPLETE, _handleOperEvent);
				_opers.push(oper);
			}
			return this;
		}

		protected function _handleOperEvent(event:GOperEvent):void {
			var oper:GOper = event.target as GOper;
			oper.removeEventListener(GOperEvent.OPERATION_COMPLETE, _handleOperEvent);
			var at:int = _opers.indexOf(oper);
			if (at != -1)
				_opers.splice(at, 1);
			if (_opers.length == 0)
				_succHandler();
		}

		public function start(succCall:Function):void {
			_succHandler = succCall;
			if (isRunning)
				_succHandler.call();
		}

		public function stop():void {
			while (_opers.length) {
				var oper:GOper = _opers.shift();
				oper.removeEventListener(GOperEvent.OPERATION_COMPLETE, _handleOperEvent);
				_succHandler = null;
			}
		}
	}
}