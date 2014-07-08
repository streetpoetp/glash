package com.gearbrother.glash.display.control {
	import com.gearbrother.glash.display.GNoScale;

	import flash.display.DisplayObject;


	/**
	 * @author neozhang
	 * @create on Oct 14, 2013
	 */
	public class GBackground extends GNoScale {
		public function GBackground(skin:DisplayObject = null) {
			super(skin);
		}

		final override public function paintNow():void {
			skin.width = originalWidth;
			skin.height = originalHeight;
		}
	}
}
