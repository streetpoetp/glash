package com.gearbrother.glash.display {
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.container.GContainer;
	import com.gearbrother.glash.display.manager.GPaintManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	/**
	 * 重写了width,height,scaleX,scaleY，大部分组件类的基类
	 *
	 */
	public class GNoScale extends GSkinSprite {
		private var _scaleX:Number;

		override public function get scaleX():Number {
			return _scaleX;
		}

		override public function set scaleX(newValue:Number):void {
			if (_scaleX != newValue) {
				_scaleX = newValue;
				super.scaleX = _scaleX;
				if (container)
					container.invalidateLayout();
			}
		}

		private var _scaleY:Number;

		override public function get scaleY():Number {
			return _scaleY;
		}

		override public function set scaleY(newValue:Number):void {
			if (_scaleY != newValue) {
				_scaleY = newValue;
				super.scaleY = _scaleY;
				if (container)
					container.invalidateLayout();
			}
		}

		private var _originalSize:GDimension;

		public function get originalWidth():Number {
			return _originalSize.width;
		}

		override public function get width():Number {
			return _originalSize.width * _scaleX;
		}

		override public function set width(newValue:Number):void {
			if (_scaleX != .0) {
				newValue /= _scaleX;
				if (_originalSize.width != newValue) {
					_originalSize.width = newValue;
					invalidateLayout();
					repaint();
				}
			}
		}
		
		public function set scaleToWidth(newValue:Number):void {
			if (_originalSize.width) {
				var toScaleX:Number = newValue / _originalSize.width;
				scaleX = toScaleX;
			}
		}

		override public function get height():Number {
			return _originalSize.height * _scaleY;
		}

		public function get originalHeight():Number {
			return _originalSize.height;
		}

		override public function set height(newValue:Number):void {
			if (_scaleY != .0) {
				newValue /= _scaleY;
				if (_originalSize.height != newValue) {
					_originalSize.height = newValue;
					invalidateLayout();
					repaint();
				}
			}
		}
		
		public function set scaleToHeight(newValue:Number):void {
			if (_originalSize.height) {
				var toScaleY:Number = newValue / _originalSize.height;
				scaleY = toScaleY;
			}
		}

		public function get container():GContainer {
			if (parent is GContainer)
				return parent as GContainer;
			else
				return null;
		}

		public function get preferredSize():GDimension {
			return new GDimension(_originalSize.width * _scaleY, _originalSize.height * _scaleY);
		}

		public function get minimumSize():GDimension {
			return new GDimension(0, 0);
		}

		public function get maximumSize():GDimension {
			return new GDimension(10000, 10000);
		}

		private var _isLayoutValid:Boolean;
		public function get isLayoutValid():Boolean {
			return _isLayoutValid;
		}

		public function get isLayoutRoot():Boolean {
			if (stage != null && container == null)
				return true;
			else
				return false;
		}

		public function GNoScale(skin:DisplayObject = null) {
			super(skin);

			_scaleX = _scaleY = 1.0;
			if (skin)
				_originalSize = new GDimension(skin.width, skin.height);
			else
				_originalSize = new GDimension();
		}
		
		override protected function doInit():void {
			super.doInit();

			revalidateLayout();
		}

		public function revalidateLayout():void {
			invalidateLayout();
			//if has parent, notify parent, parent will manage child's resize
			GPaintManager.instance.addInvalidLayoutComponent(this);
		}

		public function invalidateLayout():void {
			_isLayoutValid = false;
			if (container && container.isLayoutValid)
				container.invalidateLayout();
		}

		final public function validateLayoutNow():void {
			if (!_isLayoutValid) {
				doValidateLayout();
				_isLayoutValid = true;
			}
		}

		protected function doValidateLayout():void {
			//do nothing
		}

		override public function replace(target:DisplayObject):void {
			var oldIndex:int = target.parent.getChildIndex(target);
			var oldParent:DisplayObjectContainer = target.parent;
			oldParent.removeChild(target);
			oldParent.addChildAt(this, oldIndex);
			x = target.x;
			y = target.y;
			width = target.width;
			height = target.height;
		}

		public function get $width():Number {
			return super.width;
		}

		public function set $width(newValue:Number):void {
			super.width = newValue;
		}

		public function get $height():Number {
			return super.height;
		}

		public function set $height(newValue:Number):void {
			super.height = newValue;
		}
		
		public function get $scaleX():Number {
			return super.scaleX;
		}
		
		public function get $scaleY():Number {
			return super.scaleY;
		}

		public function $addChild(newValue:DisplayObject):DisplayObject {
			return super.addChild(newValue);
		}

		public function $addChildAt(newValue:DisplayObject, index:int):DisplayObject {
			return super.addChildAt(newValue, index);
		}

		public function $removeChild(newValue:DisplayObject):DisplayObject {
			return super.removeChild(newValue);
		}

		public function $removeChildAt(index:int):DisplayObject {
			return super.removeChildAt(index);
		}

		public function $getChildAt(index:int):DisplayObject {
			return super.getChildAt(index);
		}

		public function $getChildByName(name:String):DisplayObject {
			return super.getChildByName(name);
		}

		public function $getChildIndex(child:DisplayObject):int {
			return super.getChildIndex(child);
		}
	}
}
