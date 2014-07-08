package com.gearbrother.glash.display.control {
	import com.gearbrother.glash.common.geom.GPadding;
	import com.gearbrother.glash.skin.GCheckButtonSkin;
	import com.gearbrother.glash.display.control.text.GText;
	import com.gearbrother.glash.util.display.GSearchUtil;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.text.TextField;

	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 多选框
	 *
	 * 标签规则：当作按钮转换
	 *
	 * @author feng.lee
	 *
	 */
	public class GCheckBox extends GButtonLite {
		public static var defaultSkin:Class = GCheckButtonSkin;

		public function GCheckBox(skin:DisplayObject = null) {
			super(skin || new defaultSkin());

			this.toggle = true;
		}
	}
}
