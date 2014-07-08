package com.gearbrother.glash.display.container {
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.GDisplayConst;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.layout.impl.BoxLayout;
	import com.gearbrother.glash.display.layout.impl.VerticalLayout;
	
	import flash.display.DisplayObject;


	/**
	 * 竖型排列容器
	 *
	 * @author feng.lee
	 * @create on 2013-2-13
	 */
	public class GVBox extends GScrollBase {
		public function GVBox(padding:int = 5) {
			super();

			layout = new VerticalLayout(GDisplayConst.ALIGN_LEFT, padding);
		}
	}
}
