package com.gearbrother.glash.display.container {
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.layout.impl.EmptyLayout;
	import com.gearbrother.glash.display.layout.interfaces.IGLayoutManager;
	
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.level.DEBUG;


	/**
	 * 容器
	 *
	 * 子容器应该加到content内而不是自身，否则无法布局。skin也会在content内，无法作为背景存在。
	 * 这个容器的大小是由layout控制,transition控制缓动
	 *
	 */
	public class GContainer extends GNoScale {
		static public const logger:ILogger = getLogger(GContainer);
		
		private var _manualPreferredSize:GDimension;
		public function get manualPreferredSize():GDimension {
			return _manualPreferredSize;
		}
		public function set manualPreferredSize(newValue:GDimension):void {
			_manualPreferredSize = newValue;
		}

		protected var _cachedPreferredSize:GDimension;

		override public function get preferredSize():GDimension {
			if (manualPreferredSize) {
				return new GDimension(manualPreferredSize.width * scaleX, manualPreferredSize.height * scaleY);
			} else if (_cachedPreferredSize) {
				return new GDimension(_cachedPreferredSize.width * scaleX, _cachedPreferredSize.height * scaleY);
			} else {
				_cachedPreferredSize = _layout.preferredLayoutSize(this);
				return new GDimension(_cachedPreferredSize.width * scaleX, _cachedPreferredSize.height * scaleY);
			}
		}

		//================================ layout ================================//
		private var _layout:IGLayoutManager;

		public function set layout(layout:IGLayoutManager):void {
			_layout = layout;
			revalidateLayout();
		}

		public function get layout():IGLayoutManager {
			return _layout;
		}

		public function GContainer() {
			super();

			layout = new EmptyLayout();
		}

		public function append(child:DisplayObject, constraint:Object = null):DisplayObject {
			CONFIG::debug {
				if (child is GNoScale == false)
					throw new Error("child only is instance of GNoScale");
			}
			if (_layout)
				_layout.addLayoutComponent(child as GNoScale, constraint);
			return addChild(child);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			CONFIG::debug {
				if (child is GNoScale == false)
					throw new Error("child only is instance of GNoScale");
			}
			revalidateLayout();
			return super.addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			CONFIG::debug {
				if (child is GNoScale == false)
					throw new Error("child only is instance of GNoScale");
			}
			revalidateLayout();
			return super.addChildAt(child, index);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			revalidateLayout();
			layout.removeLayoutComponent(child as GNoScale);
			return super.removeChild(child);
		}
		
		override public function removeChildAt(index:int):DisplayObject {
			revalidateLayout();
			var res:DisplayObject = super.removeChildAt(index);
			layout.removeLayoutComponent(res as GNoScale);
			return res;
		}

		override public function invalidateLayout():void {
			_cachedPreferredSize = null;

			super.invalidateLayout();
		}

		override protected function doValidateLayout():void {
			//first, validate children
			_layout.layoutContainer(this, null/*_boxsGrid*/);
			//then, layout children
			for (var j:int = 0; j < numChildren; j++) {
				var child:GNoScale = getChildAt(j) as GNoScale;
				child.validateLayoutNow();
			}
			super.doValidateLayout();
		}
	}
}