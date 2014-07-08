package com.gearbrother.glash.display.control {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;


	[Event(name = "change", type = "flash.events.Event")]

	/**
	 * 单选框组对象。
	 * 请用getGroupByName方法创建并获取。
	 *
	 * @author feng.lee
	 *
	 */
	public class GSelectGroup extends EventDispatcher {
		/**
		 * 包含的单选框
		 */
		private var _items:Array;

		private var _selectedItem:GRadioButton;

		/**
		 * 选择的组
		 */
		public function get selectedItem():GRadioButton {
			return _selectedItem;
		}

		public function set selectedItem(newValue:GRadioButton):void {
			if (_selectedItem != newValue) {
				_selectedItem = newValue;

				for (var i:int = 0; i < _items.length; i++) {
					var item:GRadioButton = _items[i] as GRadioButton;
					item.selected = (_selectedItem == item);
				}

				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		public function GSelectGroup(canSelectNum:int = 1) {
		}

		/**
		 * 增加
		 * @param item
		 *
		 */
		public function addItem(item:GRadioButton):void {
			if (!_items)
				_items = [item];
			else
				_items.push(item);
		}

		/**
		 * 删除
		 * @param item
		 *
		 */
		public function removeItem(item:GRadioButton):void {
			if (_items) {
				if (_items.indexOf(item) != -1)
					_items.splice(_items.indexOf(item), 1);
			}
		}
	}
}
