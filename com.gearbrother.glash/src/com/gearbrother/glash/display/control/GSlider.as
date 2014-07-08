package com.gearbrother.glash.display.control {
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.GSkinSprite;
	import com.gearbrother.glash.display.GDisplayConst;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author feng.lee
	 * create on 2012-7-26 下午2:33:37
	 */
	public class GSlider extends GRange {
		/**
		 * 滑动块 
		 */		
		public var thumb:GButtonLite;
		
		private var _autoHide:Boolean;

		/**
		 * 快速滚动速度
		 */
		public var pageDetra:int = 25;

		private var _direction:int;
		public function get direction():int {
			return _direction;
		}
		
		private var _pageSize:Number;
		
		public function get pageSize():Number {
			return _pageSize;
		}
		
		public function set pageSize(newValue:Number):void {
			_pageSize = newValue;
		}

		private var _mouseDownPos:Point;

		public function get scrollRange():Number {
			if (_direction == GDisplayConst.AXIS_Y)
				return track.height - thumb.height;
			else if (_direction == GDisplayConst.AXIS_X)
				return track.width - thumb.width;
			else
				throw new Error("unknown direction");
		}
		
		override public function set value(newValue:Number):void {
			super.value = newValue;

			if (value >= maxValue && maxButton)
				maxButton.enabled = false;
			else if (maxButton)
				maxButton.enabled = true;
			if (value <= minValue && minButton)
				minButton.enabled = false;
			else if (minButton)
				minButton.enabled = true;
		}

		public function GSlider(direction:int, skin:DisplayObject = null) {
			super(skin);

			_autoHide = true;
			_direction = direction;

			if (skin.hasOwnProperty("thumb")) {
				thumb = new GButtonLite(skin["thumb"]);
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);
			}

			if (skin.hasOwnProperty("track")) {
				track = skin["track"];
				track.addEventListener(MouseEvent.CLICK, onButtonClick);
			}
		}

		override public function onButtonClick(e:MouseEvent):void {
			super.onButtonClick(e);

			switch (e.target) {
				case thumb:
					_mouseDownPos = new Point(mouseX - thumb.x, mouseY - thumb.y);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMove, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp, false, 0, true);
					break;
				case track:
					onStageMove(e);
					break;
			}
		}

		protected function onStageMove(e:MouseEvent):void {
			if (direction == GDisplayConst.AXIS_X) {
				percent = (mouseX - track.x - (_mouseDownPos ? _mouseDownPos.x : 0)) / scrollRange;
			} else if (direction == GDisplayConst.AXIS_Y) {
				percent = (mouseY - track.y - (_mouseDownPos ? _mouseDownPos.y : 0)) / scrollRange;
			}
			e.updateAfterEvent();
		}

		protected function onStageUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
			_mouseDownPos = null;
		}

		override public function paintNow():void {
			/*if (direction == GDisplayConst.AXIS_X) {
			if (maxButton)
			maxButton.x = width - maxButton.width;
			
			if (track) {
			track.x = minButton ? minButton.x + minButton.width : 0;
			track.width = width - track.x - (maxButton ? maxButton.width : 0);
			}
			} else {
			if (maxButton)
			maxButton.y = height - maxButton.height;
			
			if (track) {
			track.y = minButton ? minButton.y + minButton.height : 0;
			track.height = height - track.y - (maxButton ? maxButton.height : 0);
			}
			}*/
			updateThumb();
			super.paintNow();
		}
		
		protected function updateThumb():void {
			if (!thumb)
				return;

			if (direction == GDisplayConst.AXIS_X) {
				thumb.width = Math.max(10, track.width * _pageSize / (maxValue - minValue + _pageSize));
				thumb.x = track.x + scrollRange * percent;
			} else if (direction == GDisplayConst.AXIS_Y) {
				thumb.height = Math.max(10, track.height * _pageSize / (maxValue - minValue + _pageSize));
				thumb.y = track.y + scrollRange * percent;
			}
			if (_autoHide && value == minValue && value == maxValue) {
				thumb.visible = false;
			} else {
				thumb.visible = true;
			}
		}

		override protected function doDispose():void {
			if (minButton)
				minButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if (maxButton)
				maxButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if (thumb)
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);
			if (track)
				track.removeEventListener(MouseEvent.CLICK, onButtonClick);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);

			super.doDispose();
		}
	}
}