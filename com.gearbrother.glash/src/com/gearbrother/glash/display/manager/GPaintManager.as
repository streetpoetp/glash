package com.gearbrother.glash.display.manager {
	import com.gearbrother.glash.display.GNoScale;
	import com.gearbrother.glash.display.IGPaintManagable;
	import com.gearbrother.glash.display.IGPropertyManagable;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.as3commons.collections.Set;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.as3commons.logging.level.DEBUG;

	/**
	 *
	 * @author yi.zhang
	 *
	 */
	public class GPaintManager {
		static public const logger:ILogger = getLogger(GPaintManager);

		static public const instance:GPaintManager = new GPaintManager();
		
		private var _validatePropertiesQueue:Set;

		/**
		 * similar to repaintQueue
		 */
		private var _updateLayoutQueue:Set;

		/**
		 * Although it's a set in fact, but it work more like a queue
		 * The IPaintManageable will not be added twice into the repaintQueue (one time a IPaintManageable do not need more than one painting)
		 */
		private var _updateRepaintQueue:Set;

		public var tickChannel:GTick;

		public var tickGameChannel:GTick;

		private var _stage:Stage;
		public function set stage(value:Stage):void {
			_stage = value;
			_stage.addEventListener(Event.RENDER, _render);
			_stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}

		/**
		 * Singleton class,
		 * Don't create instance directly, in stead you should call <code>getInstance()</code>.
		 */
		public function GPaintManager() {
			if (instance != null) {
				throw new Error("Singleton can't be create more than once!");
			}
			//tickGameChannel.maxTick = 1000 / 10; //min fps on GameChannel, fix bug for some big tick's interval, for example: some case people move by tick, some big tick will make people a large movement.
			_validatePropertiesQueue = new Set();
			_updateLayoutQueue = new Set();
			_updateRepaintQueue = new Set();
			tickChannel = new GTick();
			tickGameChannel= new GTick();
		}

		protected function handleEnterFrame(e:Event):void {
			//some Event like "LOADER_EVENT" is triggered after "ENTER_FRAME" 
			_stage.invalidate();	//sometimes items will be revalidateProperties() while calling Repaint(), so if this line be commeted will be problem
			if (logger.debugEnabled) {
				var begin:int = getTimer();
				tickChannel.tick();
				tickGameChannel.tick();
				logger.debug("tick cause {0} milliseconds", [getTimer() - begin]);
			} else {
				tickChannel.tick();
				tickGameChannel.tick();
			}
		}

		public function addInvalidProperties(view:IGPropertyManagable):void {
			_validatePropertiesQueue.add(view);
			if (_stage)
				_stage.invalidate();
		}

		/**
		 * Find the IPaintManageable's validate root parent and regist it need to validate.
		 * @see org.aswing.IPaintManageable#revalidate()
		 * @see org.aswing.IPaintManageable#validate()
		 * @see org.aswing.IPaintManageable#invalidate()
		 */
		public function addInvalidLayoutComponent(com:GNoScale):void {
//			logger.debug("GPaintManager.addInvalidLayoutComponent({0})", [com]);
			var validateRoot:GNoScale = getValidateRootComponent(com);
			if (validateRoot) {
				_updateLayoutQueue.add(validateRoot);
				if (_stage)
					_stage.invalidate();
			}
		}

		/**
		 * If the ancestor of the IPaintManageable has no parent or it is isValidateRoot
		 * and it's parent are visible, then it will be the validate root IPaintManageable,
		 * else it has no validate root IPaintManageable.
		 */
		private function getValidateRootComponent(sprite:GNoScale):GNoScale {
			var validateRoot:GNoScale = null;
			var i:DisplayObjectContainer;
			for (i = sprite; i != null; i = i.parent) {
				if (i is GNoScale) {
					if ((i as GNoScale).isLayoutRoot) {
						validateRoot = i as GNoScale;
						break;
					}
				} else {
					break;
				}
			}

			//var root:IPaintManageable = null;
			//TODO: check if the root here is needed, if not delte the var declar
			/*for (i = validateRoot; i != null; i = i.parentCom as IGValidatable) {
				if (!i.isVisible()) {
					//return null;
				}
			}*/
			return validateRoot;
		}

		/**
		 * Regist A IPaintManageable need to repaint.
		 * @see org.aswing.IPaintManageable#repaint()
		 */
		public function addRepaintComponent(item:IGPaintManagable):void {
			_updateRepaintQueue.add(item);
			if (_stage)
				_stage.invalidate();
		}

		/**
		 * Every frame this method will be executed to invoke the painting of components needed.
		 */
		private function _render(e:Event):void {
			CONFIG::debug {
				if (logger.debugEnabled && (_validatePropertiesQueue.size > 0 || _updateLayoutQueue.size > 0 || _updateRepaintQueue.size > 0)) {
					logger.debug("/**");
					logger.debug(" * GPaintManager.render");
					var needEnd:Boolean = true;
				}
			}

			//TODO how to handle add item when validate layout?
			while (_validatePropertiesQueue.size) {
				var time:Number = getTimer();
				var processViews:Array = _validatePropertiesQueue.toArray();
				//must clear here, because there maybe addRepaintComponent at below operation
				_validatePropertiesQueue.clear();
				for (var i:int = 0; i < processViews.length; i++) {
					var item3:IGPropertyManagable = processViews[i];
					(item3 as IGPropertyManagable).validateNow();
//					logger.debug("/* {0} update */", [item]);
				}
				CONFIG::debug {
					if (logger.debugEnabled && processViews.length > 0) {
						logger.debug(" * {0} validateProperties, cost {1} milliseconds", [processViews.length, getTimer() - time]);
					}
				}
			}

			time = getTimer();
			var validateLayouts:Array = _updateLayoutQueue.toArray();
			//must clear here, because there maybe addRepaintComponent at below operation
			_updateLayoutQueue.clear();
			for (var j:int = 0; j < validateLayouts.length; j++) {
				var item:DisplayObject = validateLayouts[j];
				if (item.stage)
					(item as GNoScale).validateLayoutNow();
				CONFIG::debug {
					logger.debug(" * {0} validateLayout", [getQualifiedClassName(item)]);
				}
			}
			CONFIG::debug {
				if (logger.debugEnabled && validateLayouts.length > 0) {
					logger.debug(" * {0} validateLayout, cost {1} milliseconds", [validateLayouts.length, getTimer() - time]);
				}
			}

			time = getTimer();
			var processRepaints:Array = _updateRepaintQueue.toArray();
			//must clear here, because there maybe addInvalidComponent at below operation
			_updateRepaintQueue.clear();
			for (var k:int = 0; k < processRepaints.length; k++) {
				var paintItem:DisplayObject = processRepaints[k];
				if (paintItem.stage /* && paintItem.isVisible()*/)
					(paintItem as IGPaintManagable).paintNow();
			}
			CONFIG::debug {
				if (logger.debugEnabled && processRepaints.length > 0) {
					logger.debug(" * {0} paint, cost {1} milliseconds", [processRepaints.length, getTimer() - time]);
				}
				if (needEnd) {
					logger.debug(" */");
				}
			}
		}
	}
}
