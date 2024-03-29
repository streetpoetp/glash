package com.gearbrother.glash.display.control {
	import com.gearbrother.glash.GMain;
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.common.oper.ext.GBmdDefinition;
	import com.gearbrother.glash.common.oper.ext.GDefinition;
	import com.gearbrother.glash.common.oper.ext.GFile;
	import com.gearbrother.glash.common.oper.ext.GLoadOper;
	import com.gearbrother.glash.common.utils.GClassFactory;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.container.GContainer;
	import com.gearbrother.glash.display.layout.impl.PreferredLayout;
	import com.gearbrother.glash.display.propertyHandler.GPropertyDataHandler;
	import com.gearbrother.glash.display.propertyHandler.GPropertyPoolOperHandler;
	import com.gearbrother.glash.ui.control.GUiLoader_SKIN_ERROR;
	import com.gearbrother.glash.ui.control.GUiLoader_SKIN_LOADING;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;


	[Event(name = "complete", type = "flash.events.Event")]

	/**
	 * 用于替换fla设计中的加载元件
	 *
	 * @author feng.lee
	 * create on 2012-8-20 下午1:33:05
	 */
	public class GLoader extends GContainer {
		/**
		 * 加载时显示的图标
		 */
		static public var loadingIcon:Class = GUiLoader_SKIN_LOADING;

		/**
		 * 加载错误时显示的图标
		 */
		static public var errorIcon:Class = GUiLoader_SKIN_ERROR;

		static public const SCALE_POLICY_NONE:int = 0;
		
		static public const SCALE_POLICY_SCALE:int = 2;

		static public const SCALE_POLICY_FILL:int = 1;

		private var _loadedDisplay:GNoScale;

		public function get loadedDisplay():GNoScale {
			return _loadedDisplay;
		}

		public function set loadedDisplay(newValue:GNoScale):void {
			if (_loadedDisplay != newValue) {
				if (_loadedDisplay)
					removeChild(_loadedDisplay);
				_loadedDisplay = newValue;
				if (_loadedDisplay) {
					addChild(_loadedDisplay);
				}
			}
		}

		private var _sourceHandler:GPropertyPoolOperHandler;
		public function get source():* {
			return _sourceHandler ? _sourceHandler.value : null;
		}
		public function set source(newValue:*):void {
			if ((newValue == null || newValue is GFile || newValue is GDefinition) == false)
				throw new ArgumentError("Source only accept \"GFile\" or \"GDefinition\"");

			var t:GLoader = this;
			function succHandler(handler:GPropertyPoolOperHandler):void {
				if (t.source is GFile) {
					var file:GFile = t.source as GFile;
					if (file.type == GFile.TYPE_IMAGE)
						t.loadedDisplay = new GNoScale(new Bitmap((_sourceHandler.cachedOper.result as Bitmap).bitmapData, "auto", true));
					else
						throw new Error("unknown file type");
				} else if (file is GBmdDefinition) {
					
				}
				t.dispatchEvent(new Event(Event.COMPLETE));
			};
			function failHandler():void {
				if (errorIcon)
					t.loadedDisplay = new GNoScale(new errorIcon());
				else
					t.loadedDisplay = null;
			};
			function processHandler():void {
				if (loadingIcon)
					t.loadedDisplay = new GNoScale(new loadingIcon());
				else
					t.loadedDisplay = null;
			};
			_sourceHandler ||= new GPropertyPoolOperHandler(GMain.instance.pool, GLoadOper.queue, false, this, newValue);
			_sourceHandler.succHandler = succHandler;
			_sourceHandler.failHandler = failHandler;
			_sourceHandler.processHandler = processHandler;
			_sourceHandler.value = newValue;
			if (!_sourceHandler.value) {
				loadedDisplay = null;
			}
		}
		
		public var scalePolicy:int;

		public function GLoader() {
			super();
			
			layout = new PreferredLayout();
			scalePolicy = SCALE_POLICY_SCALE;
		}
		
		override protected function doValidateLayout():void {
			/*graphics.clear();
			graphics.beginFill(0x00ff00, .3);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();*/
			if (loadedDisplay) {
				switch (scalePolicy) {
					case SCALE_POLICY_FILL:
						loadedDisplay.x = loadedDisplay.y = 0;
						loadedDisplay.scaleToWidth = width;
						loadedDisplay.scaleToHeight = height;
						break;
					case SCALE_POLICY_SCALE:
						if (loadedDisplay.width / loadedDisplay.height < width / height) {
							loadedDisplay.scaleToHeight = height;
							loadedDisplay.scaleX = loadedDisplay.scaleY;
						} else {
							loadedDisplay.scaleToWidth = width;
							loadedDisplay.scaleY = loadedDisplay.scaleX;
						}
						loadedDisplay.x = (width - loadedDisplay.width) >> 1;
						loadedDisplay.y = (height - loadedDisplay.height) >> 1;
						break;
					case SCALE_POLICY_NONE:
						loadedDisplay.x = loadedDisplay.y = 0;
						this.scrollRect = new Rectangle(0, 0, width, height);
						break;
				}
			}
		}
	}
}
