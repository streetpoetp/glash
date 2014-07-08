package com.gearbrother.glash.display.control.text {
	import com.gearbrother.glash.GMain;
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.common.utils.GClassFactory;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.manager.GFontManager;
	import com.gearbrother.glash.util.display.GTextFieldUtil;
	import com.gearbrother.glash.util.lang.GObjectUtil;
	import com.gearbrother.glash.util.lang.GTextUtil;
	import com.gearbrother.glash.util.lang.UBB;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	[Event(name = "change", type = "flash.events.Event")]

	/**
	 * 标签规则
	 * 	默认不使用系统自带字体名,
	 *  同一种字体只能存在一个字体名
	 *
	 * @author feng.lee
	 * create on 2012-12-27 上午11:56:34
	 */
	public class GText extends GNoScale {
		static public const logger:ILogger = getLogger(GText);

		static public var defaultSkin:GClassFactory = new GClassFactory(TextField, null, {autoSize: TextFieldAutoSize.LEFT});

		static public const defaultTextRender:Function = function(data:*):String {
			return String(data);
		}

		/**
		 * 应用字体样式
		 *
		 * @param f	为空则取默认字体样式
		 * @param overwriteDefault	是否覆盖默认字体样式
		 *
		 */
		static public function applyTextFormat(textField:TextField, f:TextFormat = null, overwriteDefault:Boolean = true):void {
			var format:TextFormat = f || textField.defaultTextFormat;
			var embedFontName:String = GFontManager.instance.getEmbedFontName(format.font);
			if (embedFontName)
				format.font = embedFontName;
			else
				logger.warn("fail to get font \"{0}\" in embed fonts", [format.font]);
			if (overwriteDefault)
				textField.defaultTextFormat = format;
			textField.setTextFormat(format);
			textField.embedFonts = embedFontName == null ? false : true;
		}

		/**
		 * 将它设置为true，将会自动重建所有Embed的TextField以便通过外部嵌入字体，否则使用SWF内的字体
		 */
		static public var autoRebuildEmbedText:Boolean = false;

		/**
		 * 将它设置为true，将会自动重建所有非Embed的TextField，以便处理某些IDE无法修改设备字体的字体的问题
		 */
		static public var autoRebuildText:Boolean = false;

		private var _text:*;

		/**
		 * displayText与text可能不同, 在设置了enableTruncateToFit = true后会对text截取
		 * @return
		 *
		 */
		public function get text():* {
			return _text;
		}

		public function set text(newValue:*):void {
			if (getQualifiedClassName(_text) != getQualifiedClassName(newValue) || _text != newValue) {
				_text = newValue;
				dispatchEvent(new Event(Event.CHANGE));
				revalidateLayout();
				repaint();
			}
		}

		private var _valueFomater:Function;

		public function get valueFormater():Function {
			return _valueFomater;
		}

		public function set valueFormater(newValue:Function):void {
			_valueFomater = newValue;
			revalidateLayout();
			repaint();
		}

		/**
		 * 设置格式文本
		 * @param v
		 *
		 */
		public function set htmlText(newValue:String):void {
			this.text = newValue ? ("<html>" + GMain.instance.language.getValue(newValue) + "</html>") : null;
		}

		public function get align():String {
			return textField.defaultTextFormat.align;
		}

		public function set align(newValue:String):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.align = newValue;
			textField.defaultTextFormat = format;
		}

		public function get autoSize():String {
			return textField.autoSize;
		}

		/**
		 * 如果想要文本自动适配大小,必须设置wordWrap = false;
		 * @param value
		 * @see wordWrap
		 */
		public function set autoSize(value:String):void {
			textField.autoSize = value;
		}

		/**
		 * 是否自动断行
		 * @return
		 *
		 */
		public function get wordWrap():Boolean {
			return textField.wordWrap;
		}

		public function set wordWrap(value:Boolean):void {
			textField.wordWrap = value;
		}

		/**
		 * 是否多行显示（可激活回车换行）
		 * @return
		 *
		 */
		public function get multiline():Boolean {
			return textField.multiline;
		}

		public function set multiline(value:Boolean):void {
			textField.multiline = value;
		}

		private var _vertical:Boolean;

		/**
		 * 文字是否竖排
		 */
		public function get vertical():Boolean {
			return _vertical;
		}

		public function set vertical(value:Boolean):void {
			_vertical = value;
			repaint();
		}

		public function get font():String {
			return textField.defaultTextFormat.font;
		}

		/**
		 * 系统会搜索全局嵌入字体中是否存在当前设置的字体, 如果存在则将textfield.embedfonts = true, 否则将textfield.embedfonts = false,
		 * 不管哪一种情况字体都会被设置成当前字体.
		 * 如果会存在无法显示的情况只能是当前字没有被嵌入
		 * @param value
		 * @see com.gearbrother.glash.display.manager.GFontManager
		 *
		 */
		public function set font(newValue:String):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.font = newValue;
			applyTextFormat(textField, format);
		}

		public function get fontSize():int {
			return textField.defaultTextFormat.size as int;
		}

		public function set fontSize(value:int):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.size = value;
			textField.defaultTextFormat = format;
			textField.setTextFormat(format);
		}

		public function get fontColor():uint {
			return textField.defaultTextFormat.color as uint;
		}

		public function set fontColor(value:uint):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.color = value;
			textField.defaultTextFormat = format;
			textField.setTextFormat(format);
		}

		public function get fontBold():Boolean {
			return textField.defaultTextFormat.bold == true;
		}

		public function set fontBold(value:Boolean):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.bold = value;
			textField.defaultTextFormat = format;
			textField.setTextFormat(format);
		}

		public function get fontItalic():Boolean {
			return textField.defaultTextFormat.italic == true;
		}

		public function set fontItalic(value:Boolean):void {
			var format:TextFormat = textField.defaultTextFormat;
			format.italic = value;
			textField.defaultTextFormat = format;
			textField.setTextFormat(format);
		}

		private var _enableTruncateToFit:Boolean;

		/**
		 * 是否激活截断文本
		 */
		public function get enableTruncateToFit():Boolean {
			return _enableTruncateToFit;
		}

		public function set enableTruncateToFit(newValue:Boolean):void {
			if (_enableTruncateToFit != newValue) {
				_enableTruncateToFit = newValue;
				repaint();
			}
		}

		/**
		 * 文字输入限制
		 * @return
		 *
		 */
		public function get restrict():String {
			return textField.restrict;
		}

		public function set restrict(newValue:String):void {
			textField.restrict = newValue;
		}

		/**
		 * 是否可选
		 *
		 */
		public function get selectable():Boolean {
			return textField.selectable;
		}

		public function set selectable(value:Boolean):void {
			textField.selectable = textField.mouseEnabled = value;
		}

		/**
		 * 是否强制使用HTML文本
		 */
		public var useHtml:Boolean;

		/**
		 * 是否转换UBB(只在HTML文本中有效),例如"[size=6]文字[/size=6] 6号字 , [font=仿宋]文字[/font=仿宋] 仿宋体 "
		 */
		public var ubb:Boolean;

		public function get textField():TextField {
			return skin as TextField;
		}

		private var _cachedPreferredSize:GDimension;

		override public function get preferredSize():GDimension {
			if (_cachedPreferredSize) {
				return _cachedPreferredSize;
			} else {
				var str:String = valueFormater(text);
				if (vertical)
					str = GTextUtil.vertical(str);
				if (textField) {
					if (useHtml || str.indexOf("<html>") != -1) {
						if (ubb)
							str = UBB.decode(str);

						textField.htmlText = str;
					} else
						textField.text = str;
				}
				return _cachedPreferredSize = new GDimension(textField.width, textField.height);
			}
		}

		override public function invalidateLayout():void {
			_cachedPreferredSize = null;
			super.invalidateLayout();
		}

		public function GText(skin:TextField = null) {
			super(skin ||= defaultSkin.newInstance());

			if (skin is TextField == false)
				throw new ArgumentError("illegal skin, only accept skin is textfield");
			text = (skin as TextField).text;
			valueFormater = defaultTextRender;
//			var value:TextField = skin as TextField;
//			if (autoRebuildEmbedText && (value as TextField).embedFonts || autoRebuildText && !(value as TextField).embedFonts) { //如果需要用Embed标签来定义嵌入字体，则必须重新创建文本框
//				value.parent.removeChild(value);
//				super.skin = GTextFieldUtil.clone(value as TextField, true); //将TextField重新创建避免出现显示错误
//			} else {
//				super.skin = value;
//			}
			applyTextFormat(textField, textField.defaultTextFormat); //设置皮肤字体,系统会使用嵌入字体替换
			CONFIG::debug {
				textField.border = true;
			}
		}
		
		override public function paintNow():void {
			textField.width = width;
			textField.height = height;
			var str:String = valueFormater(text);
			if (vertical)
				str = GTextUtil.vertical(str);
			if (useHtml || str.indexOf("<html>") != -1) {
				if (ubb)
					str = UBB.decode(str);
				textField.htmlText = str;
			} else {
				textField.text = str;
			}
			if (enableTruncateToFit) {
				textField.scrollH = 0;
				if (GTextFieldUtil.truncateToFit(textField))
					tipData = text;
			}
			CONFIG::debug {
				graphics.clear();
				graphics.beginFill(0x0000ff, .3);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			}
		}
	}
}