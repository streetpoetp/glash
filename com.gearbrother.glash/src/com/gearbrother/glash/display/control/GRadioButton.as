package com.gearbrother.glash.display.control {
	import com.gearbrother.glash.common.geom.GPadding;
	import com.gearbrother.glash.display.control.text.GText;
	import com.gearbrother.glash.skin.GRadioButtonSkin;
	import com.gearbrother.glash.util.display.GSearchUtil;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;

	[Event(name="change", type="flash.events.Event")]

	/**
	 * 单选框
	 *
	 * 标签规则：当作按钮转换
	 *
	 * @author feng.lee
	 *
	 */
	public class GRadioButton extends GButtonLite {
		public static var defaultSkin:Class = GRadioButtonSkin;

		private var _group:GSelectGroup;
		public function get group():GSelectGroup {
			return _group;
		}
		public function set group(newValue:GSelectGroup):void {
			_group = newValue;
			_group.addItem(this);
		}

		override public function set selected(newValue:Boolean):void {
			super.selected = newValue;
			if (_group && selected) {
				_group.selectedItem = this;
			}
		}

		public function GRadioButton(skin:DisplayObject = null) {
			super(skin ||= new defaultSkin());
		}

		override protected function _handleMouseEvent(event:MouseEvent):void {
			super._handleMouseEvent(event);

			switch (event.type) {
				case MouseEvent.CLICK:
					this.selected = true;
					break;
			}
		}
	}
}