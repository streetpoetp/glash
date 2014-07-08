package com.gearbrother.glash.display.control {

	import com.gearbrother.glash.common.utils.GClassFactory;
	import com.gearbrother.glash.display.GDisplayConst;
	import com.gearbrother.glash.display.GSprite;
	import com.gearbrother.glash.display.IGScrollable;
	import com.gearbrother.glash.display.control.GSlider;
	import com.gearbrother.glash.display.event.GDisplayEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;


	/**
	 *
	 * @author feng.lee
	 *
	 */
	public class GScrollBar extends GSlider {
		public function get scrollTarget():IGScrollable {
			return null;
		}

		public function set scrollTarget(newValue:IGScrollable):void {
		}

		override public function get value():Number {
			switch (direction) {
				case GDisplayConst.AXIS_X:
					if (scrollTarget)
						return scrollTarget.scrollH;
					break;
				case GDisplayConst.AXIS_Y:
					if (scrollTarget)
						return scrollTarget.scrollV;
					break;
			}
			return 0;
		}

		override public function set value(newValue:Number):void {
			if (super.value != newValue) {
				if (scrollTarget) {
					switch (direction) {
						case GDisplayConst.AXIS_X:
							scrollTarget.scrollH = newValue;
							break;
						case GDisplayConst.AXIS_Y:
							scrollTarget.scrollV = newValue;
							break;
					}
				}
				super.value = newValue;
			}
		}

		public function GScrollBar(direction:int, skin:DisplayObject = null) {
			super(direction, skin);
		}
	}
}

