package com.gearbrother.glash.display.propertyHandler {
	import com.gearbrother.glash.display.GDisplayConst;
	import com.gearbrother.glash.display.GDisplaySprite;
	import com.gearbrother.glash.display.IGDisplay;
	import com.gearbrother.glash.display.container.GScrollBase;
	import com.gearbrother.glash.display.control.GScrollBar;
	import com.gearbrother.glash.display.event.GDisplayEvent;
	import com.gearbrother.glash.display.manager.GPaintManager;
	import com.gearbrother.glash.display.manager.GTickEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author neozhang
	 * @create on Aug 8, 2013
	 */
	public class GPropertyScrollTargetHandler extends GPropertyHandler {
		public function GPropertyScrollTargetHandler(propertyOwner:DisplayObject, isValidateLater:Boolean = false) {
			super(propertyOwner, isValidateLater);
		}

		override protected function doValidate():void {
			if (value)
				propertyOwner.addEventListener(GDisplayEvent.SCROLL_CHANGE, _handleScrollEvent);
			_handleScrollEvent();
		}

		private function _handleScrollEvent(event:Event = null):void {
			var propertyOwner:GScrollBar = this.propertyOwner as GScrollBar;
			if (propertyOwner.direction == GDisplayConst.AXIS_X) {
				propertyOwner.minValue = this.value.minScrollH;
				propertyOwner.maxValue = this.value.maxScrollH;
				propertyOwner.pageSize = this.value.scrollHPageSize;
				propertyOwner.value = this.value.scrollH;
			} else if (propertyOwner.direction == GDisplayConst.AXIS_Y) {
				propertyOwner.minValue = this.value.minScrollV;
				propertyOwner.maxValue = this.value.maxScrollV;
				propertyOwner.pageSize = this.value.scrollVPageSize;
				propertyOwner.value = this.value.scrollV;
			}

			switch (propertyOwner.direction) {
				case GDisplayConst.AXIS_X:
					propertyOwner.pageSize = value.scrollHPageSize;
					break;
				case GDisplayConst.AXIS_Y:
					value.addEventListener(MouseEvent.MOUSE_WHEEL, _handleTargetEvent);
					propertyOwner.pageSize = value.scrollVPageSize;
					break;
			}
		}

		private function _handleTargetEvent(event:Event):void {
			var propertyOwner:GScrollBar = propertyOwner as GScrollBar;
			switch (event.type) {
				case MouseEvent.MOUSE_WHEEL:
					propertyOwner.value -= (event as MouseEvent).delta * propertyOwner.stepSize;
					break;
			}
		}

		override public function dispose():void {
			propertyOwner.removeEventListener(GDisplayEvent.SCROLL_CHANGE, _handleScrollEvent);
		}
	}
}
