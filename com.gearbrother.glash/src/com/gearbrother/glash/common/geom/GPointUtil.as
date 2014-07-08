package com.gearbrother.glash.common.geom {

	import flash.geom.Point;

	/**
	 * A point with x and y coordinates in int.
	 * @author iiley
	 */
	public class GPointUtil  {
		/**
		 * Moves this point with an direction in radians and distance, then return itself.
		 * @param angle the angle in radians.
		 * @param distance the distance in pixels.
		 * @return the point itself.
		 */
		static public function moveRadians(pt:Point, angleRadians:int, distance:int):Point {
			return pt.add(new Point(Math.round(Math.cos(angleRadians) * distance)
				, Math.round(Math.sin(angleRadians) * distance)));
		}

		/**
		 * Returns the distance between this point and passing point.
		 * @param p the another point.
		 * @return the distance from this to p.
		 */
		static public function distance(pt1:Point, pt2:Point):int {
			return Math.sqrt((pt1.x - pt2.x) * (pt1.x - pt2.x) + (pt1.y - pt2.y) * (pt1.y - pt2.y));
		}

		static public function distancePoint(pt1:Point, pt2:Point):Point {
			return new Point(pt1.x - pt2.x, pt1.y - pt2.y);
		}

		static public function reverse(pt:Point):Point {
			return new Point(-pt.x, -pt.y);
		}
	}
}
