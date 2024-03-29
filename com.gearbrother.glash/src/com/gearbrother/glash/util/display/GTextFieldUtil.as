package com.gearbrother.glash.util.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;


	/**
	 * 文本框处理类
	 *
	 * @author flashyiyi
	 *
	 */
	final public class GTextFieldUtil {
		static public const TEXT_WIDTH_PADDING:int = 5;
		static public const TEXT_HEIGHT_PADDING:int = 4;

		/**
		 * 缩短文字以符合TextField的大小
		 * (如果取出的整体大小不对,先检查字体是否嵌入正确)
		 *
		 * @param textField	文本框
		 * @return 是否经过裁剪
		 *
		 */
		static public function truncateToFit(textField:TextField):Boolean {
			var text:String = textField.text;
			if (text == null || text.length == 0)
				return false;

			var bool:Boolean = false;
			var firstLine:TextLineMetrics = textField.getLineMetrics(0);
			while (firstLine.width > textField.width && text.length > 0) {
				text = text.slice(0, text.length - 1);

				textField.text = text + "...";
				bool = true;

				firstLine = textField.getLineMetrics(0);
			}
			return bool;
		}

		/**
		 * 从索引处截取一个字
		 *
		 * @param textField
		 * @param index
		 * @return
		 *
		 */
		static public function getTextFieldAtIndex(textField:TextField, index:int):TextField {
			var t:TextField = new TextField();
			t.selectable = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.embedFonts = textField.embedFonts;
			t.text = textField.text.charAt(index);
			t.setTextFormat(textField.getTextFormat(index, index + 1), 0, 1);
			var rect:Rectangle = textField.getCharBoundaries(index);
			var tRect:Rectangle = t.getCharBoundaries(0);
			if (rect && tRect) {
				t.x = rect.x - tRect.x;
				t.y = rect.y - tRect.y;
			}
			return t;
		}

		/**
		 * 将TextField按字打散到一个容器内
		 *
		 * @param textField
		 * @param cotainer
		 * @param bitmap	是否转换为位图
		 * @param extend	转换位图时的扩展面积
		 */
		static public function separate(textField:TextField, cutItem:DisplayObject = null, cotainer:DisplayObjectContainer = null, bitmaped:Boolean = false, extend:int = 0):Array {
			if (!cotainer)
				cotainer = textField.parent;
			cutItem = cutItem || textField;

			var m:Matrix = GMatrixUtil.getMatrixAt(textField, cotainer);
			var result:Array = [];

			for (var i:int = 0; i < textField.text.length; i++) {
				if (bitmaped) {
					//getCharBoundaries获取的坐标是基于textfield的左上角的距离,而不是textfield的注册点 
					var charBound:Rectangle = textField.getCharBoundaries(i);
					var bound:Rectangle = textField.getBounds(textField);
					if (charBound) {
						//所以需要转换坐标轴
						charBound.x += bound.left;
						charBound.y += bound.top;
						var bmd:BitmapData = new BitmapData(charBound.width, charBound.height, true, 0x00000000);
						bmd.draw(cutItem, new Matrix(1, 0, 0, 1, -charBound.x, -charBound.y));
						var b:Bitmap = new Bitmap(bmd);//BitmapUtil.replaceWithBitmap(t, "auto", false, extend);
						b.x = charBound.x + i * extend;
						b.y = charBound.y;
						if (cotainer)
							cotainer.addChild(b);
						result.push(b);
					}
				} else {
					var t:TextField = getTextFieldAtIndex(textField, i);
					m.concat(t.transform.matrix);
					t.transform.matrix = m;
					t.transform.colorTransform = textField.transform.colorTransform;
					t.filters = textField.filters;
					if (cotainer)
						cotainer.addChild(t);
					result.push(t);
				}
			}

			return result;
		}

		/**
		 * 复制文本框
		 * @param v
		 * @param replace 是否替换到父对象中
		 * @return
		 *
		 */
		static public function clone(v:TextField, replace:Boolean = false):TextField {
			var c:TextField = new TextField();
			c.name = v.name;
			c.type = v.type;
			c.autoSize = v.autoSize;
			c.embedFonts = v.embedFonts;
			c.defaultTextFormat = v.defaultTextFormat;
			c.text = v.text;
			for (var i:int = 0; i < v.text.length; i++) {
				c.setTextFormat(v.getTextFormat(i, i + 1), i, i + 1);
			}
			c.x = v.x;
			c.y = v.y;
			c.scaleX = v.scaleX;
			c.scaleY = v.scaleY;
			c.width = v.width;
			c.height = v.height;
			c.rotation = v.rotation;
			c.multiline = v.multiline;
			c.selectable = v.selectable;
			c.wordWrap = v.wordWrap;
			c.transform.colorTransform = v.transform.colorTransform;
			c.filters = v.filters;
			c.mouseEnabled = v.mouseEnabled;
			c.mouseWheelEnabled = v.mouseWheelEnabled;

			if (replace && v.parent) {
				var p:DisplayObjectContainer = v.parent;
				var index:int = p.getChildIndex(v);
				p.removeChild(v);
				p.addChildAt(c, index);
			}
			return c;
		}

		/**
		 * 获得一行文本的HtmlText
		 * @param textField
		 * @param lineIndex
		 * @return
		 *
		 */
		static public function getLineHtmlText(textField:TextField, lineIndex:int):String {
			var offest:int = textField.getLineOffset(lineIndex);
			var len:int = textField.getLineLength(lineIndex);
			var t:TextField = new TextField();
			for (var i:int = 0; i < len; i++) {
				t.appendText(textField.text.charAt(offest + i));
				t.setTextFormat(textField.getTextFormat(offest + i, offest + i + 1), i, i + 1);
			}
			return t.htmlText;
		}

		/**
		 * 根据文本框大小自动缩小字体
		 * @param textField 文本框
		 * @param adjustY	自动调整文本框的y值
		 * @param resetY	每次调整都将y设回0（否则重复设置data并调整大小会出问题）
		 *
		 */
		static public function autoFontSize(textField:TextField, adjustY:Boolean = false, resetY:Boolean = false):void {
			var text:String = textField.text;
			var f:TextFormat = textField.getTextFormat();
			var old_size:int = int(f.size);

			if (text == null || text.length == 0)
				return;

			var firstLine:TextLineMetrics = textField.getLineMetrics(0);
			if (firstLine.width <= textField.width - 2)
				return;

			while (firstLine.width > textField.width - 2) {
				f = textField.getTextFormat();
				f.size = int(f.size) - 1;
				if (f.size == 0)
					return;

				textField.setTextFormat(f, 0, text.length);

				firstLine = textField.getLineMetrics(0);
			}

			if (resetY)
				textField.y = 0;

			if (adjustY)
				textField.y += (old_size - int(f.size)) / 2;
		}

		/**
		 * 获得TextField某坐标下的URL
		 *
		 * @param textField
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		static public function getUrlFromTextField(textField:TextField, x:Number, y:Number):String {
			var index:int = textField.getCharIndexAtPoint(x, y);
			return index != -1 ? textField.getTextFormat(index, index + 1).url : null;
		}

		/**
		 * 获取一段文字的TextLineMetrics对象
		 * @param s
		 * @param format
		 * @return
		 *
		 */
		static public function getTextLineMetrics(s:String, format:TextFormat):TextLineMetrics {
			var t:TextField = new TextField();
			t.defaultTextFormat = format;
			t.text = s;
			return t.getLineMetrics(0);
		}

		/**
		 * 设置字体大小并调整文本框位置
		 * @param textField
		 * @param size
		 *
		 */
		static public function setTextSize(textField:TextField, size:int, adjustY:Boolean = true):void {
			var f:TextFormat = textField.defaultTextFormat;
			if (adjustY)
				textField.y += (int(f.size) - size) / 2;

			f.size = size;
			textField.defaultTextFormat = f;
			textField.setTextFormat(f, 0, textField.length);
		}

		/**
		 * 在当前光标位置插入文本
		 * @param textField
		 * @param str
		 *
		 */
		static public function insertText(textField:TextField, str:String):void {
			var index:int = textField.caretIndex;
			textField.text = textField.text.slice(0, index) + str + textField.text.slice(index);
			textField.setSelection(index + str.length, index + str.length);
		}
	}
}