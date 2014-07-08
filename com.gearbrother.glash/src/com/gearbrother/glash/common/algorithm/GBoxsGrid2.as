package com.gearbrother.glash.common.algorithm {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * 数据按坐标范围划分并随时存取
	 *
	 */
	public class GBoxsGrid2 {
		public var rect:Rectangle;
		public var boxWidth:Number;
		public var boxHeight:Number;

		public var dict:Dictionary;
		protected var boxs:Array;

		private var w:int;
		private var h:int;

		public function GBoxsGrid2(rect:Rectangle, boxWidth:Number, boxHeight:Number):void {
			this.rect = rect;
			this.boxWidth = boxWidth;
			this.boxHeight = boxHeight;

			this.dict = new Dictionary(true);
			this.w = Math.ceil(rect.width / boxWidth);
			this.h = Math.ceil(rect.height / boxHeight);
			var l:int = w * h;
			this.boxs = new Array(l);
			for (var i:int = 0; i < l; i++)
				this.boxs[i] = [];
		}

		/**
		 * 获得对象所在的方块数组
		 * @param item
		 * @return
		 *
		 */
		public function isIn(item:*):Array {
			var x:int = int((item.x - rect.x) / boxWidth);
			var y:int = int((item.y - rect.y) / boxHeight);
			x = x < 0 ? 0 : x > w ? w : x;
			y = y < 0 ? 0 : y > h ? h : y;
			return boxs[y * w + x];
		}

		/**
		 * 增加对象
		 * @param item
		 *
		 */
		public function insert(item:*):void {
			var box:Array = isIn(item);
			box[box.length] = item;

			this.dict[item] = box;
		}

		/**
		 * 重新插入对象
		 * @param item
		 *
		 */
		public function reinsert(item:*):void {
			var list:Array = isIn(item);
			var oldlist:Array = this.dict[item];
			if (list != oldlist) {
				if (oldlist) {
					var index:int = oldlist.indexOf(item);
					if (index != -1)
						oldlist.splice(index, 1);
				}

				if (list) {
					list[list.length] = item;
					this.dict[item] = list;
				}
			}
		}

		/**
		 * 移除对象
		 * @param item
		 *
		 */
		public function remove(item:*):void {
			var list:Array = this.dict[item];
			if (list) {
				var index:int = list.indexOf(item);
				if (index != -1)
					list.splice(index, 1);
			}
		}

		/**
		 * 获得一个范围内的所有对象
		 *
		 * @param rect
		 *
		 */
		public function retrieve(p:*, dict:Dictionary = null):Array {
			var x:int = int((p.x - rect.x) / boxWidth);
			var y:int = int((p.y - rect.y) / boxHeight);
			var il:int = Math.ceil((p.x - rect.x + p.width) / boxWidth);
			il = il < w ? il - x : w - x;
			var jl:int = Math.ceil((p.y - rect.y + p.height) / boxHeight);
			jl = jl < h ? jl - y : h - y;
			var result:Array = [];
			for (var j:int = 0; j < jl; j++) {
				for (var i:int = 0; i < il; i++) {
					var box:Array = boxs[(y + j) * w + x + i];
					result.push.apply(null, box);
					if (dict) {
						for each (var child:* in box)
							dict[child] = child;
					}
				}
			}
			return result;
		}
		
		public function reset():void {
			var l:int = this.boxs.length;
			for (var i:int = 0; i < l; i++)
				(this.boxs[i] as Array).length = 0;
		}
	}
}
