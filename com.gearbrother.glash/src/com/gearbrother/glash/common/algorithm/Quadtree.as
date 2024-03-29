package com.gearbrother.glash.common.algorithm {
	import com.gearbrother.glash.util.display.GColorUtil;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author lifeng
	 * @create on 2013-12-17
	 * 
	 * @see http://gamedevelopment.tutsplus.com/tutorials/quick-tip-use-quadtrees-to-detect-likely-collisions-in-2d-space--gamedev-374
	 */
	public class Quadtree {
		private var MAX_OBJECTS:int = 10;
		private var MAX_LEVELS:int = 7;

		private var level:int;
		private var objects:Array;
		private var bounds:Rectangle;
		private var nodes:Array; //Quadtree
		public var _debug:Graphics;

		/*
		* Constructor
		*/
		public function Quadtree(pBounds:Rectangle, maxObjects:int = 10, maxLevel:int = 7, currentLevel:int = 1, debug:Graphics = null) {
			objects = [];
			MAX_OBJECTS = maxObjects;
			MAX_LEVELS = maxLevel;
			level = currentLevel;
			bounds = pBounds;
			nodes = new Array(4); //new Quadtree[4];
			_debug = debug;
			if (_debug) {
				_debug.lineStyle(1, 0x00ff00, .3);
				_debug.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				_debug.endFill();
			}
		}

		/*
		* Clears the quadtree
		*/
		public function clear():void {
			objects.length = 0;

			for (var i:int = 0; i < nodes.length; i++) {
				if (nodes[i] != null) {
					nodes[i].clear();
					nodes[i] = null;
				}
			}
		}

		/*
		* Splits the node into 4 subnodes
		*/
		private function split():void {
			var subWidth:int = bounds.width >> 1;
			var subHeight:int = bounds.height >> 1;
			var x:int = bounds.x;
			var y:int = bounds.y;

			nodes[0] = new Quadtree(new Rectangle(x + subWidth, y, subWidth, subHeight), MAX_OBJECTS, MAX_LEVELS, level + 1, _debug);
			nodes[1] = new Quadtree(new Rectangle(x, y, subWidth, subHeight), MAX_OBJECTS, MAX_LEVELS, level + 1, _debug);
			nodes[2] = new Quadtree(new Rectangle(x, y + subHeight, subWidth, subHeight), MAX_OBJECTS, MAX_LEVELS, level + 1, _debug);
			nodes[3] = new Quadtree(new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight), MAX_OBJECTS, MAX_LEVELS, level + 1, _debug);
		}

		/*
		* Determine which node the object belongs to. -1 means
		* object cannot completely fit within a child node and is part
		* of the parent node
		*/
		private function getIndex(pRect:*):int {
			var index:int = -1;
			var verticalMidpoint:Number = bounds.x + (bounds.width / 2);
			var horizontalMidpoint:Number = bounds.y + (bounds.height / 2);

			// Object can completely fit within the top quadrants
			var topQuadrant:Boolean = (pRect.y < horizontalMidpoint && pRect.y + pRect.height < horizontalMidpoint);
			// Object can completely fit within the bottom quadrants
			var bottomQuadrant:Boolean = (pRect.y > horizontalMidpoint);

			// Object can completely fit within the left quadrants
			if (pRect.x < verticalMidpoint && pRect.x + pRect.width < verticalMidpoint) {
				if (topQuadrant) {
					index = 1;
				} else if (bottomQuadrant) {
					index = 2;
				}
			}
			// Object can completely fit within the right quadrants
			else if (pRect.x > verticalMidpoint) {
				if (topQuadrant) {
					index = 0;
				} else if (bottomQuadrant) {
					index = 3;
				}
			}

			return index;
		}
		
		/*private var c:uint = GColorUtil.randomColor();*/
		
		/*
		* Insert the object into the quadtree. If the node
		* exceeds the capacity, it will split and add all
		* objects to their corresponding nodes.
		*/
		public function insert(pRect:*):void {
			/*pRect.graphics.clear();
			pRect.graphics.beginFill(c, .3);
			pRect.graphics.drawRect(0, 0, 16, 16);
			pRect.graphics.endFill();*/
			if (nodes[0] != null) {
				var index:int = getIndex(pRect);
				if (index != -1) {
					nodes[index].insert(pRect);
					return;
				}
			}

			objects.push(pRect);

			if (objects.length > MAX_OBJECTS && level < MAX_LEVELS) {
				if (nodes[0] == null) {
					split();
				}

				var i:int = 0;
				while (i < objects.length) {
					index = getIndex(objects[i]);
					if (index != -1) {
						var removeds:Array = objects.splice(i, 1);
						nodes[index].insert(removeds[0]);
					} else {
						i++;
					}
				}
			}
		}

		/*
		* Return all objects that could collide with the given object
		*/
		public function retrieve(pRect:*):Array {
			var rect1:Rectangle = new Rectangle();
			var rect2:Rectangle = new Rectangle();
			var res:Array = [];
//			var index:int = getIndex(pRect);
			if (/*index != -1 && */nodes[0] != null) {
//				res = res.concat((nodes[index] as Quadtree).retrieve(pRect));
				if (_intersect(rect1, nodes[0], rect2, pRect))
					res = res.concat((nodes[0] as Quadtree).retrieve(pRect));
				if (_intersect(rect1, nodes[1], rect2, pRect))
					res = res.concat((nodes[1] as Quadtree).retrieve(pRect));
				if (_intersect(rect1, nodes[2], rect2, pRect))
					res = res.concat((nodes[2] as Quadtree).retrieve(pRect));
				if (_intersect(rect1, nodes[3], rect2, pRect))
					res = res.concat((nodes[3] as Quadtree).retrieve(pRect));
			}

			res = res.concat(objects);
			return res;
		}
		
		private function _intersect(rect1:Rectangle, node:Quadtree, rect2:Rectangle, pRect:*):Boolean {
			rect1.x = node.bounds.x;
			rect1.y = node.bounds.y;
			rect1.width = node.bounds.width;
			rect1.height = node.bounds.height;
			
			rect2.x = pRect.x;
			rect2.y = pRect.y;
			rect2.width = pRect.width;
			rect2.height = pRect.height;
			
			return rect1.intersects(rect2)
		}
	}
}
