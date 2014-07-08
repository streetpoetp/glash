package com.gearbrother.glash.display.control.text {
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.control.text.GText;
	import com.gearbrother.glash.util.display.GTextFieldUtil;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;


	/**
	 * 文本控件
	 * 	该控件的skin必须是textfield,若skin为null则创建textfield.
	 * 字体规则:
	 * 	控件将会在嵌入字体中搜索是否存在skin中或者外部设入的字体, 若存在则把textfield.embedFont = true, 反之则 = false.
	 * 	这样的好处在于使用者可以忽略对字体的控制. 文字大小,是否斜体还是沿用skin的设置.
	 * @author feng.lee
	 * @see flash.text.TextLineMetrics 当使用设备字体时, TextLineMetrics.x会不准,必须是TextField.embedFonts = true时
	 *
	 */
	public class GRichText extends GText {
		static public const textTweenScroll:Function = function(items:Array):void {
			var duration:Number = .5;
			for (var i:int = 0; i < items.length; i++) {
				var item:DisplayObject = items[i];
				item.alpha = .0;
				TweenMax.fromTo(items[i], duration, {x: item.x - 20}, {alpha: 1.0, x: item.x, rotation: 360 /*transformAroundCenter: {}*/, delay: duration * i * .5});
			}
		};

		static public const textTweenAlpha:Function = function(items:Array):void {
			var duration:Number = .5;
			for (var i:int = 0; i < items.length; i++) {
				var item:DisplayObject = items[i];
				item.alpha = .0;
				TweenLite.to(items[i], duration, {alpha: 1.0, delay: duration * i * .5});
			}
		};

		private var _textRender:GTextRender;

		/**
		 * 绘制text底纹
		 */
		public function get textRender():GTextRender {
			return _textRender;
		}

		public function set textRender(newValue:GTextRender):void {
			if (_textRender != newValue) {
				_textRender = newValue;
				repaint();
			}
		}

		private var _tween:Function;

		public function get tween():Function {
			return _tween;
		}

		public function set tween(newValue:Function):void {
			if (_tween != newValue) {
				_tween = newValue;
				repaint();
			}
		}

		private var _textfieldContainer:Sprite;

		private var _textRenderLayer:Shape;

		/**
		 * 打散的文字实例
		 */
		protected var _separateTexts:Array;

		/*override public function get tipData():* {
			if (_partTipDatas) {
				var mouseAt:int = textField.getCharIndexAtPoint(textField.mouseX, textField.mouseY);
				for each (var partTip:TextTipData in _partTipDatas) {
					if (partTip.beginIndex > mouseAt && partTip.endIndex > mouseAt)
						return partTip;
				}
				return super.tipData;
			} else {
				return super.tipData;
			}
		}*/

		public function GRichText(skin:TextField = null) {
			super(skin);

			this.skin.parent.removeChild(this.skin);
			_textfieldContainer = new Sprite();
			_textfieldContainer.addChild(_textRenderLayer = new Shape());
			_textfieldContainer.addChild(this.skin);
			mouseChildren = false;
		}

		/**
		 * 设置文本框大小
		 * @param w
		 * @param h
		 *
		 */
		public function setTextFieldSize(w:Number = NaN, h:Number = NaN, autoSize:String = TextFieldAutoSize.NONE):void {
			if (textField) {
				textField.autoSize = autoSize;

				if (!isNaN(w))
					textField.width = w;

				if (!isNaN(h))
					textField.height = h;
			}
		}

		/**
		 * 根据文本框大小设置文本字体
		 * @param adjustY	自动调整文本框的y值
		 * @param resetY	每次调整都将y设回0（否则重复设置data并调整大小会出问题）
		 *
		 */
		public function autoFontSize(adjustY:Boolean = false, resetY:Boolean = false):void {
			GTextFieldUtil.autoFontSize(textField, adjustY, resetY);
		}

		override public function paintNow():void {
			super.paintNow();

			_textRenderLayer.graphics.clear();
			if (textRender) {
				//由于BlendMode只应用于BITMAP带ALPHA通道
				//,所以在textfield.embedfonts == false的时候,使用设备字体,系统默认使用点象素的方式展现字体,内存表现为位图,适用BlendMode.ALPHA
				//,但是当TextField.embedfonts == true时,字体内存表现为flash显示对象, 便不可使用BlendMode,只能使用mask了
				//,所以为了统一转换为BitmapData
				textRender.render(_textRenderLayer, textField);
				textField.blendMode = BlendMode.ALPHA;
				_textfieldContainer.blendMode = BlendMode.LAYER;
				textField.cacheAsBitmap = true;
			} else {
				textField.blendMode = BlendMode.NORMAL;
				_textfieldContainer.blendMode = BlendMode.NORMAL;
				textField.cacheAsBitmap = false;
			}

			destoryAllTexts();
			_separateTexts = GTextFieldUtil.separate(textField, _textfieldContainer, this, true);
			if (tween != null)
				tween(_separateTexts);
			/*for each (var separatedText:DisplayObject in _separateTexts)
				separatedText.filters = [];
			for each (var textFilter:Array in textFilters) {
				var targetTexts:Array = _separateTexts.slice(textFilter[0], textFilter[1]);
				for each (var targetText:DisplayObject in targetTexts) {
					targetText.filters = [textFilter[2]];
				}
			}
			var bmd:BitmapData = new BitmapData(textField.width, textField.height, true, 0x00000000);
			bmd.draw(textField, textField.transform.matrix);
			_textBitmap.bitmapData = bmd;
			if (_textBitmap) {
				_textBitmap.bitmapData.dispose();
				_textBitmap = null;
			} else {
				_textBitmap = new Bitmap();
				addChild(_textBitmap);
			}*/
		}

		override protected function doDispose():void {
			destoryAllTexts()

			super.doDispose();
		}

		protected function destoryAllTexts():void {
			for each (var child:DisplayObject in _separateTexts) {
				if (child is Bitmap)
					(child as Bitmap).bitmapData.dispose();

				if (child.parent)
					child.parent.removeChild(child);
			}
			_separateTexts = [];
		}
	}
}
