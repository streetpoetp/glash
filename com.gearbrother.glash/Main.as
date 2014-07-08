﻿package 
{
	import Main.*;
	import __AS3__.vec.*;
	import away3d.containers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import awayphysics.collision.shapes.*;
	import awayphysics.dynamics.*;
	import awayphysics.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	public class Main extends Sprite
	{
		public var FB:Class;
		public var slugTm:TextureMaterial;
		public var FS:Class;
		public var slugFtm:TextureMaterial;
		public var fbt:TextureMaterial;
		public var view3d:View3D;
		public var maze:Map00;
		public var gun:Gun;
		public var plight:PointLight;
		public var dlight:DirectionalLight;
		public var awpworld:AWPDynamicsWorld;
		public var maze_awp:AWPRigidBody;
		public var ball_awp:AWPRigidBody;
		public var ball_gv:Number;
		public var ball_g:Number;
		public var tm_awp:AWPBvhTriangleMeshShape;
		public var ss_awp:AWPSphereShape;
		public var speed:int;
		public var rotat:int;
		public var up:int;
		private var isjump:Boolean;
		private var tp:Number;
		private var slugs:Vector.<Slug>;
		private var plights:Array;
		private var isfire:Boolean;
		
		public function Main() : void
		{
			this.FB = Main_FB;
			this.FS = Main_FS;
			if (stage)
			{
				this.init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, this.init);
			}
			return;
		}// end function
		
		private function init(event:Event = null) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this.init);
			this.slugTm = new TextureMaterial(new BitmapTexture(new this.FB().bitmapData));
			this.slugTm.alphaBlending = true;
			this.slugTm.blendMode = BlendMode.ADD;
			this.slugs = new Vector.<Slug>;
			this.slugFtm = new TextureMaterial(new BitmapTexture(new this.FS().bitmapData));
			this.slugFtm.alphaBlending = true;
			this.slugFtm.blendMode = BlendMode.ADD;
			this.view3d = new View3D();
			this.view3d.camera.z = -50;
			this.view3d.camera.y = -30;
			this.view3d.camera.lens.near = 0.1;
			this.view3d.camera.lens.far = 5000;
			this.view3d.antiAlias = 10;
			addChild(this.view3d);
			addChild(new AwayStats(this.view3d));
			this.createInfor();
			this.plight = new PointLight();
			this.plight.ambient = 0.5;
			this.plight.ambientColor = 6710886;
			this.plight.color = 13421772;
			this.plight.diffuse = 1.5;
			this.plight.specular = 0;
			this.plight.fallOff = 1000;
			this.plight.radius = 100;
			this.view3d.scene.addChild(this.plight);
			this.plights = [this.plight];
			this.dlight = new DirectionalLight();
			this.dlight.x = -10000;
			this.dlight.y = 15000;
			this.dlight.z = -10000;
			this.dlight.ambient = 0.3;
			this.dlight.lookAt(new Vector3D());
			this.view3d.scene.addChild(this.dlight);
			this.isjump = true;
			this.isfire = true;
			this.gun = new Gun(this.dlight);
			this.maze = new Map00(this.plight);
			this.maze.onCreated = this.gameSceneCreated;
			return;
		}// end function
		
		private function createInfor() : void
		{
			var _loc_1:* = new TextField();
			_loc_1.textColor = 16777215;
			_loc_1.autoSize = "left";
			_loc_1.filters = [new GlowFilter(0, 1, 3, 3)];
			_loc_1.text = "控制方式: [W、S]前进和后退 [A、D]左右视角 [Q、E]上下视角  [F]射击 [空格]跳跃" + "\n" + "只是场景演示，无人物和怪物！";
			_loc_1.y = 600 - _loc_1.height;
			addChild(_loc_1);
			return;
		}// end function
		
		private function gameSceneCreated() : void
		{
			this.view3d.scene.addChild(this.maze);
			this.view3d.scene.addChild(this.gun);
			this.awpworld = AWPDynamicsWorld.getInstance();
			this.awpworld.initWithDbvtBroadphase();
			this.awpworld.collisionCallbackOn = true;
			this.awpworld.gravity = new Vector3D(0, -10, 0);
			var _loc_1:* = new WireframeSphere(20);
			_loc_1.visible = false;
			this.view3d.scene.addChild(_loc_1);
			this.tm_awp = new AWPBvhTriangleMeshShape(this.maze.geometry);
			this.ss_awp = new AWPSphereShape(20);
			this.maze_awp = new AWPRigidBody(this.tm_awp, this.maze);
			this.ball_awp = new AWPRigidBody(this.ss_awp, _loc_1, 1);
			this.ball_awp.friction = 1;
			this.maze_awp.friction = 1;
			this.ball_gv = 0.1;
			this.ball_g = 0;
			this.awpworld.addRigidBody(this.maze_awp);
			this.awpworld.addRigidBody(this.ball_awp);
			var _loc_2:int = 0;
			this.up = 0;
			var _loc_2:* = _loc_2;
			this.rotat = _loc_2;
			this.speed = _loc_2;
			this.tp = 1 / 40;
			this.addEventListener(Event.ENTER_FRAME, this.updateHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyHandler);
			return;
		}// end function
		
		private function onKeyHandler(event:KeyboardEvent) : void
		{
			var _loc_2:* = String.fromCharCode(event.charCode);
			if (event.type == KeyboardEvent.KEY_DOWN)
			{
				if (_loc_2 == "a")
				{
					this.rotat = -2;
				}
				if (_loc_2 == "d")
				{
					this.rotat = 2;
				}
				if (_loc_2 == "w")
				{
					this.speed = 2;
				}
				if (_loc_2 == "s")
				{
					this.speed = -2;
				}
				if (_loc_2 == "q")
				{
					this.up = -2;
				}
				if (_loc_2 == "e")
				{
					this.up = 2;
				}
				if (event.keyCode == 32)
				{
					if (this.ball_awp.linearVelocity.y >= 0)
					{
					}
					if (this.isjump)
					{
						this.ball_awp.linearVelocity = new Vector3D(0, 3.5, 0);
						this.isjump = false;
					}
				}
				this.ball_awp.activate(true);
				if (_loc_2 == "f")
				{
					if (this.slugs.length < 5)
					{
					}
					if (this.isfire)
					{
						this.createSlug();
						this.isfire = false;
						setTimeout(this.resumeFire, 300);
					}
				}
			}
			else
			{
				if (_loc_2 == "a")
				{
					this.rotat = 0;
				}
				if (_loc_2 == "d")
				{
					this.rotat = 0;
				}
				if (_loc_2 == "w")
				{
					this.speed = 0;
				}
				if (_loc_2 == "s")
				{
					this.speed = 0;
				}
				if (_loc_2 == "q")
				{
					this.up = 0;
				}
				if (_loc_2 == "e")
				{
					this.up = 0;
				}
			}
			return;
		}// end function
		
		private function createSlug() : void
		{
			var _loc_1:* = (-this.view3d.camera.rotationY - 10 + 90) * Math.PI / 180;
			var _loc_2:* = (this.view3d.camera.rotationX + 90) * Math.PI / 180;
			var _loc_3:* = Math.cos(_loc_1) * 10;
			var _loc_4:* = Math.sin(_loc_1) * 10;
			var _loc_5:* = Math.cos(_loc_2) * 10;
			var _loc_6:* = new Slug(this.slugTm);
			_loc_6.x = this.gun.x + _loc_3;
			_loc_6.y = this.gun.y + _loc_5;
			_loc_6.z = this.gun.z + _loc_4;
			var _loc_7:* = new Sprite3D(this.slugFtm, 10, 10);
			_loc_7.position = _loc_6.position;
			this.view3d.scene.addChild(_loc_7);
			setTimeout(this.removeFireEffect, 100, _loc_7);
			_loc_6.rigidBody.position = _loc_6.position;
			_loc_6.light.position = _loc_6.position;
			_loc_6.life = 100;
			this.awpworld.addRigidBody(_loc_6.rigidBody);
			this.view3d.scene.addChild(_loc_6);
			this.view3d.scene.addChild(_loc_6.light);
			_loc_6.xv = _loc_3;
			_loc_6.yv = _loc_5;
			_loc_6.zv = _loc_4;
			_loc_6.rigidBody.addEventListener(AWPEvent.COLLISION_ADDED, this.onCollisionWithWall);
			this.plights.push(_loc_6.light);
			this.slugs.push(_loc_6);
			this.maze.changeLight(this.plights);
			return;
		}// end function
		
		private function onCollisionWithWall(event:AWPEvent) : void
		{
			var _loc_2:* = undefined;
			if (event.collisionObject == this.maze_awp)
			{
				for (_loc_2 in this.slugs)
				{
					
					if (this.slugs[_loc_2].rigidBody == event.target)
					{
						this.removedSlug(this.slugs[_loc_2], _loc_2);
						return;
					}
				}
			}
			return;
		}// end function
		
		private function removedSlug(obj:Slug, index:int) : void
		{
			var _loc_3:* = undefined;
			for (_loc_3 in this.plights)
			{
				
				if (this.plights[_loc_3] == obj.light)
				{
					this.plights.splice(_loc_3, 1);
					break;
				}
			}
			obj.rigidBody.removeEventListener(AWPEvent.COLLISION_ADDED, this.onCollisionWithWall);
			this.maze.changeLight(this.plights);
			this.awpworld.removeRigidBody(obj.rigidBody);
			this.view3d.scene.removeChild(obj.light);
			this.view3d.scene.removeChild(obj);
			obj.rigidBody = null;
			obj.light = null;
			this.slugs.splice(index, 1);
			obj = null;
			return;
		}// end function
		
		private function updateHandler(event:Event) : void
		{
			var _loc_3:* = undefined;
			var _loc_4:Number = NaN;
			if (this.rotat != 0)
			{
				this.view3d.camera.rotationY = this.view3d.camera.rotationY + this.rotat;
			}
			var _loc_2:* = this.ball_awp.linearVelocity.y;
			if (!this.isjump)
			{
				if (_loc_2 <= 0)
				{
					this.isjump = true;
					this.ball_g = 0;
				}
			}
			if (this.speed != 0)
			{
				_loc_4 = (-this.view3d.camera.rotationY + 90) * Math.PI / 180;
				this.ball_awp.linearVelocity = new Vector3D(Math.cos(_loc_4) * this.speed, _loc_2, Math.sin(_loc_4) * this.speed);
			}
			else
			{
				this.ball_awp.linearVelocity = new Vector3D(0, _loc_2, 0);
			}
			if (this.up != 0)
			{
				this.view3d.camera.rotationX = this.view3d.camera.rotationX + this.up;
				if (this.view3d.camera.rotationX < -45)
				{
					this.view3d.camera.rotationX = -45;
				}
				if (this.view3d.camera.rotationX > 30)
				{
					this.view3d.camera.rotationX = 30;
				}
			}
			this.view3d.camera.x = this.ball_awp.skin.position.x;
			this.view3d.camera.z = this.ball_awp.skin.position.z;
			this.view3d.camera.y = this.ball_awp.skin.position.y + 10;
			this.gun.x = this.ball_awp.skin.position.x;
			this.gun.y = this.ball_awp.skin.position.y + 9;
			this.gun.z = this.ball_awp.skin.position.z;
			this.gun.rotationY = this.view3d.camera.rotationY;
			this.gun.rotationX = this.view3d.camera.rotationX;
			this.plight.position = this.view3d.camera.position;
			this.awpworld.step(this.tp);
			for (_loc_3 in this.slugs)
			{
				
				this.slugs[_loc_3].rigidBody.linearVelocity = new Vector3D(this.slugs[_loc_3].xv, this.slugs[_loc_3].yv, this.slugs[_loc_3].zv);
				this.slugs[_loc_3].position = this.slugs[_loc_3].rigidBody.position;
				this.slugs[_loc_3].light.position = this.slugs[_loc_3].position;
				var _loc_7:* = this.slugs[_loc_3];
				var _loc_8:* = this.slugs[_loc_3].life - 1;
				_loc_7.life = _loc_8;
				if (this.slugs[_loc_3].life < 0)
				{
					this.removedSlug(this.slugs[_loc_3], _loc_3);
				}
			}
			this.view3d.render();
			return;
		}// end function
		
		private function removeFireEffect(target:Sprite3D)
		{
			this.view3d.scene.removeChild(target);
			target = null;
			return;
		}// end function
		
		private function resumeFire()
		{
			this.isfire = true;
			return;
		}// end function
		
	}
}
