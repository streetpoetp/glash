package com.gearbrother.glash.display.layout.impl {
	import com.gearbrother.glash.common.algorithm.GBoxsGrid2;
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.GDisplayConst;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.container.GContainer;
	
	import flash.geom.Rectangle;


	/**
	 * A layout manager that allows multiple components to be arranged either vertically or
	 * horizontally. The components will not be wrapped. The width, height, preferredWidth,preferredHeight doesn't affect the way
	 * this layout manager layout the components. Note, it does  not work the same way as Java swing boxlayout does.
	 * <p>
	 * If this boxlayout is set to X_AXIS, it will layout the child componnets evenly regardless the value of width,height,preferredWidth,preferredHeight.
	 * The height of the child components is the same as the parent container.
	 * The following picture illustrate this:
	 * <img src="../../aswingImg/BoxLayout_X_AXIS.JPG" ></img>
	 * </p>
	 * <br/>
	 * <br/>
	 * <p>
	 * It works the same way when it is set to Y_AXIS.
	 * </p>
	 * <br>
	 * Note that this layout will first subtract all of the gaps before it evenly layout the components.
	 * If you have a container that is 100 pixel in width with 5 child components, the layout manager is boxlayout, and set to X_AXIS, the gap is 20.
	 * You would not see any child componnet in visual.
	 * Because the layout mananager will first subtract 20(gap)*5(component) =100 pixels from the visual area. Then, each component's width would be 0.
	 * Pay attention to this when you use this layout manager.
	 * </br>
	 * @author iiley
	 */
	public class BoxLayout extends EmptyLayout {
		/**
		 * Specifies that components should be laid out left to right.
		 */
		public static const X_AXIS:int = GDisplayConst.AXIS_X;

		/**
		 * Specifies that components should be laid out top to bottom.
		 */
		public static const Y_AXIS:int = GDisplayConst.AXIS_Y;


		private var axis:int;
		private var gap:int;

		/**
		 * @param axis (optional)the layout axis, default is X_AXIS
		 * @param gap  (optional)the gap between children, default is 0
		 *
		 * @see #X_AXIS
		 * @see #X_AXIS
		 */
		public function BoxLayout(axis:int = X_AXIS, gap:int = 0) {
			setAxis(axis);
			setGap(gap);
		}

		/**
		 * Sets new axis.
		 * @param axis new axis default is X_AXIS
		 */
		public function setAxis(axis:int = X_AXIS):void {
			this.axis = axis;
		}

		/**
		 * Gets axis.
		 * @return axis
		 */
		public function getAxis():int {
			return axis;
		}

		/**
		 * Sets new gap.
		 * @param get new gap
		 */
		public function setGap(gap:int = 0):void {
			this.gap = gap;
		}

		/**
		 * Gets gap.
		 * @return gap
		 */
		public function getGap():int {
			return gap;
		}

		override public function preferredLayoutSize(target:GContainer):GDimension {
			return getCommonLayoutSize(target, false);
		}

		override public function minimumLayoutSize(target:GContainer):GDimension {
			return new GDimension(target.width, target.height);
		}

		override public function maximumLayoutSize(target:GContainer):GDimension {
			return getCommonLayoutSize(target, true);
		}

		private function getCommonLayoutSize(target:GContainer, isMax:Boolean):GDimension {
			var count:int = target.numChildren;
			var width:int = 0;
			var height:int = 0;
			var amount:int = 0;
			for (var i:int = 0; i < count; i++) {
				var c:GNoScale = target.getChildAt(i) as GNoScale;
				var size:GDimension = isMax ? c.maximumSize : c.preferredSize;
				width = Math.max(width, size.width);
				height = Math.max(height, size.height);
				amount++;
			}
			if (axis == Y_AXIS) {
				height = height * amount;
				if (amount > 0) {
					height += (amount - 1) * gap;
				}
			} else {
				width = width * amount;
				if (amount > 0) {
					width += (amount - 1) * gap;
				}
			}
			var dim:GDimension = new GDimension(width, height);
			return dim;
		}

		override public function layoutContainer(target:GContainer, boxsGrid:GBoxsGrid2):void {
			var count:int = target.numChildren;
			var amount:int = 0;
			for (var i:int = 0; i < count; i++) {
				var c:GNoScale = target.getChildAt(i) as GNoScale;
				amount++;
			}
			var size:GDimension = new GDimension(target.width, target.height);
			var rd:Rectangle = size.getBounds();
			var ch:int;
			var cw:int;
			if (axis == Y_AXIS) {
				ch = Math.floor((rd.height - (amount - 1) * gap) / amount);
				cw = rd.width;
			} else {
				ch = rd.height;
				cw = Math.floor((rd.width - (amount - 1) * gap) / amount);
			}
			var x:int = rd.x;
			var y:int = rd.y;
			var xAdd:int = (axis == Y_AXIS ? 0 : cw + gap);
			var yAdd:int = (axis == Y_AXIS ? ch + gap : 0);

			for (var ii:int = 0; ii < count; ii++) {
				var comp:GNoScale = target.getChildAt(ii) as GNoScale;
				comp.x = x;
				comp.y = y;
				comp.width = cw;
				comp.height = ch;
				x += xAdd;
				y += yAdd;
			}
		}
	}
}
