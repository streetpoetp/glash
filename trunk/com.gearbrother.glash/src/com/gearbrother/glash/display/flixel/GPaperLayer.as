package com.gearbrother.glash.display.flixel {
	import com.gearbrother.glash.common.algorithm.GBoxsGrid2;
	import com.gearbrother.glash.common.collections.ArrayList;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.IGTickable;
	import com.gearbrother.glash.display.flixel.sort.ISortManager;
	import com.gearbrother.glash.util.camera.Camera;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class GPaperLayer extends GNoScale {
		public var sortManager:ISortManager;

		protected var _positionCache:GBoxsGrid2;

		public function get boxsGrid():GBoxsGrid2 {
			return _positionCache;
		}
		public function set boxsGrid(newValue:GBoxsGrid2):void {
			_positionCache = newValue;
		}

		public var childrenDict:Dictionary;

		public var childrenInScreenDict:Dictionary;

		/**
		 * 进行屏幕判断需要多判断的范围
		 */
		public var exScreenRect:int = 100;

		private var _camera:Camera;

		public function get camera():Camera {
			return _camera;
		}

		public function GPaperLayer(camera:Camera) {
			super();

			_camera = camera;
			childrenDict = new Dictionary();
			childrenInScreenDict = new Dictionary();
//			_boxsGrid = new BoxsGrid2(paper.camera.bound, boxWidth, boxHeight);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			throw new Error("call addObject");
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			throw new Error("call addObject");
		}

		override public function removeChild(child:DisplayObject):DisplayObject {
			throw new Error("call removeObject");
		}
		
		override public function removeChildAt(index:int):DisplayObject {
			throw new Error("call removeObject");
		}
		
		override public function removeAllChildren():void {
			for (var child:* in childrenDict) {
				removeObject(child);
			}
		}

		public function updateObjectPosition(child:DisplayObject):void {
			if (_positionCache)
				_positionCache.reinsert(child);
		}

		public function addObject(child:DisplayObject):DisplayObject {
			if (_positionCache) {
				_positionCache.reinsert(child);
			} else {
				super.addChild(child);
				childrenInScreenDict[child] = true;
			}
			childrenDict[child] = true;
			return child;
		}

		public function removeObject(child:DisplayObject):DisplayObject {
			if (_positionCache) {
				_positionCache.remove(child);
			} else {
				delete childrenInScreenDict[child];
				super.removeChild(child);
			}
			delete childrenDict[child];
			return child;
		}

		override public function tick(interval:int):void {
			//set _boxsGrid to remove elements out of screen
			if (_positionCache) {
				var screenRect:Rectangle = camera.screenRect.clone();
				screenRect.inflate(exScreenRect, exScreenRect);

				var oldsInScreen:Dictionary = childrenInScreenDict;
				var newsInScreen:Dictionary = new Dictionary();
				var news:Array = _positionCache.retrieve(screenRect, newsInScreen);

				childrenInScreenDict = newsInScreen;

				var child:*;
				for (child in oldsInScreen) {
					if (!newsInScreen[child] && DisplayObject(child).parent == this)
						$removeChild(child);
				}
				for (child in newsInScreen) {
					if (!oldsInScreen[child])
						$addChild(child);
				}
			}

			if (sortManager)
				sortManager.sortAll();

//			maxScrollH = Math.max(0, camera.bound.width - camera.screenRect.width);
//			maxScrollV = Math.max(0, camera.bound.height - camera.screenRect.height);
//			width = camera.screenRect.width;
//			height = camera.screenRect.height;
			scrollRect = camera.screenRect;
		}
	}
}
