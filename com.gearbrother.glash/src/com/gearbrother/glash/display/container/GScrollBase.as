package com.gearbrother.glash.display.container {
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.IGScrollable;
	import com.gearbrother.glash.display.event.GDisplayEvent;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	[Event(name = "scroll", type = "com.gearbrother.glash.display.event.GDisplayEvent")]

	/**
	 * 滚动容器, 内部content来判断实际大小, 外部width,height来设置显示大小
	 *
	 * @author feng.lee
	 * create on 2013-2-7
	 */
	public class GScrollBase extends GContainer implements IGScrollable {
		private var _minScrollH:int;

		public function get minScrollH():int {
			return _minScrollH;
		}

		public function set minScrollH(newValue:int):void {
			if (_minScrollH != newValue) {
				_minScrollH = newValue;
				dispatchEvent(new GDisplayEvent(GDisplayEvent.SCROLL_CHANGE));
			}
		}

		public function get maxScrollH():int {
			return Math.max(minScrollH, preferredSize.width - width);
		}

		public function get scrollH():int {
			return scrollRect ? scrollRect.x : 0;
		}

		public function set scrollH(newValue:int):void {
			newValue = Math.max(minScrollH, Math.min(maxScrollH, newValue));
			var viewPort:Rectangle = scrollRect || new Rectangle(minScrollH, minScrollV, scrollHPageSize, scrollVPageSize);
			if (viewPort.x != newValue) {
				viewPort.x = newValue;
				scrollRect = viewPort;
				dispatchEvent(new GDisplayEvent(GDisplayEvent.SCROLL_CHANGE));
			}
		}

		public function get scrollHPageSize():int {
			return width;
		}

		private var _minScrollV:int;

		public function get minScrollV():int {
			return _minScrollV;
		}

		public function set minScrollV(newValue:int):void {
			_minScrollV = newValue;
			dispatchEvent(new GDisplayEvent(GDisplayEvent.SCROLL_CHANGE));
		}
		
		public function get maxScrollV():int {
			return Math.max(minScrollV, preferredSize.height - height);
		}

		public function get scrollV():int {
			return scrollRect ? scrollRect.y : 0;
		}

		public function set scrollV(newValue:int):void {
			newValue = Math.max(minScrollV, Math.min(maxScrollV, newValue));
			var viewPort:Rectangle = scrollRect || new Rectangle(minScrollH, minScrollV, width, height);
			if (viewPort.y != newValue) {
				viewPort.y = newValue;
				scrollRect = viewPort;
				dispatchEvent(new GDisplayEvent(GDisplayEvent.SCROLL_CHANGE));
			}
		}

		public function get scrollVPageSize():int {
			return height;
		}

		override public function set width(newValue:Number):void {
			var viewPort:Rectangle = scrollRect || new Rectangle(0, 0, width, height);
			viewPort.width = newValue;
			scrollRect = viewPort;
			super.width = newValue;
		}

		override public function set height(newValue:Number):void {
			var viewPort:Rectangle = scrollRect || new Rectangle(0, 0, width, height);
			viewPort.height = newValue;
			scrollRect = viewPort;
			super.height = newValue;
		}

		public function GScrollBase() {
			super();
		}

		override protected function doValidateLayout():void {
			super.doValidateLayout();

			dispatchEvent(new GDisplayEvent(GDisplayEvent.SCROLL_CHANGE));
		}
	}
}
