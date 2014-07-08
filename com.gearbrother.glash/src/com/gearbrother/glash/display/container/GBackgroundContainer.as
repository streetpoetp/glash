package com.gearbrother.glash.display.container {
	import com.gearbrother.glash.common.geom.GDimension;
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.control.GBackground;
	import com.gearbrother.glash.util.display.GDisplayUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;


	/**
	 * 带九宫格背景
	 * @author feng.lee
	 * @create on 2013-4-29
	 */
	public class GBackgroundContainer extends GContainer {
		//background
		private var _background:GNoScale;

		public function get background():GNoScale {
			return _background;
		}

		public function set background(newValue:GNoScale):void {
			if (_background)
				removeChild(_background);
			_background = newValue;
			if (_background)
				if (_background.parent)
					_background.parent.removeChild(_background);
				if (_content)
					GDisplayUtil.addChildBefore(_background, _content);
				else
					addChild(_background);
		}

		private var _content:GNoScale;

		public function get content():GNoScale {
			return _content;
		}

		public function set content(newValue:GNoScale):void {
			if (_content)
				removeChild(_content);
			_content = newValue;
			if (_content)
				if (_content.parent)
					_content.parent.removeChild(_content);
				if (_background)
					GDisplayUtil.addChildAfter(_content, _background);
				else
					addChild(_content);
		}

		public var outerRectangle:Rectangle;

		public var innerRectangle:Rectangle;

		public function GBackgroundContainer(skin:DisplayObjectContainer = null) {
			super();

			layout = new Scale9GridLayout();
			if (skin && skin.getChildByName("background"))
				background = new GBackground(skin["background"]);
		}
	}
}
import com.gearbrother.glash.common.algorithm.GBoxsGrid2;
import com.gearbrother.glash.common.geom.GDimension;
import com.gearbrother.glash.display.container.GBackgroundContainer;
import com.gearbrother.glash.display.container.GContainer;
import com.gearbrother.glash.display.layout.impl.EmptyLayout;

import flash.geom.Rectangle;

class Scale9GridLayout extends EmptyLayout {
	override public function preferredLayoutSize(target:GContainer):GDimension {
		var b:GBackgroundContainer = target as GBackgroundContainer;
		return new GDimension(b.outerRectangle.width - b.innerRectangle.width + b.content.preferredSize.width
			, b.outerRectangle.height - b.innerRectangle.height + b.content.preferredSize.height);
	}

	override public function layoutContainer(target:GContainer, boxsGrid:GBoxsGrid2):void {
		var b:GBackgroundContainer = target as GBackgroundContainer;
		b.content.x = b.innerRectangle.x;
		b.content.y = b.innerRectangle.y;
		b.content.width = b.width + b.innerRectangle.width - b.outerRectangle.width;
		b.content.height = b.height + b.innerRectangle.height - b.outerRectangle.height;
		b.background.width = b.width;
		b.background.height = b.height;
	}
}