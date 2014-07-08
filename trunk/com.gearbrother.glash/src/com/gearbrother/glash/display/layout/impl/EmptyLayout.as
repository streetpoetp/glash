package com.gearbrother.glash.display.layout.impl {
	import com.gearbrother.glash.common.algorithm.GBoxsGrid2;
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.container.GContainer;
	import com.gearbrother.glash.display.layout.interfaces.IGLayoutManager;
	
	import flash.display.DisplayObject;

	/**
	 * LayoutManager's empty implementation.
	 * @author iiley
	 */
	public class EmptyLayout implements IGLayoutManager {
		public function EmptyLayout() {
		}

		/**
		 * Do nothing
		 * @inheritDoc
		 */
		public function addLayoutComponent(comp:GNoScale, constraints:Object = null):void {
		}

		/**
		 * Do nothing
		 * @inheritDoc
		 */
		public function removeLayoutComponent(comp:GNoScale):void {
		}

		/**
		 * Simply return target.getSize();
		 */
		public function preferredLayoutSize(target:GContainer):GDimension {
			return new GDimension(target.width, target.height);
		}

		/**
		 * new IntDimension(0, 0);
		 */
		public function minimumLayoutSize(target:GContainer):GDimension {
			return new GDimension(0, 0);
		}

		/**
		 * return IntDimension.createBigDimension();
		 */
		public function maximumLayoutSize(target:GContainer):GDimension {
			return GDimension.createBigDimension();
		}

		/**
		 * do nothing
		 */
		public function layoutContainer(target:GContainer, boxsGrid:GBoxsGrid2):void {
		}
	}
}
