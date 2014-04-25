package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.CbTypeList;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.MassMode;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	/**
	 * ...
	 * @author Jaiko
	 */
	public class ViewManager extends Sprite
	{
		private const K:Number = 1000;
		private var space:Space;
		private var debug:BitmapDebug;
		private var container:Sprite;

		private var cbType:CbType
		
		private var cx:Number;
		private var cy:Number;
		
		private var bodyList:Array;
		
		public function ViewManager()
		{
			super();
			if (stage)
				init(null);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//
			layout();
		}
		
		private function layout():void
		{

			// 空間を作成
			cx = stage.stageWidth * 0.5;
			cy = stage.stageHeight * 0.5;
			space = new Space(new Vec2(0, 0));
			space.worldAngularDrag = 0;
			space.worldLinearDrag = 0.0;
			space.worldLinearDrag = 2;
			
			// デバッグ表示を設定
			debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xFFFFFF);
			addChild(debug.display);
			
			cbType = new CbType();
			//space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, cbType));
			
			bodyList = [];
			
			container = new Sprite();
			addChild(container);
			
			addBody(cx,cy - 220);
			stage.addEventListener(MouseEvent.CLICK,clickHandler);
			// フレーム処理を開始
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			addBody(cx,cy - 220);
		}
		
		private function addBody(_x:Number,_y:Number):void 
		{
			var obj:Object;
			var distance:Number;
			var theta:Number;
			var v:Number;
			var vx:Number;
			var vy:Number;
			var sprite:Sprite;
			var circleShape:Circle;
			var body:Body;
			//
			sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			g.beginFill(0xFF0000);
			g.drawRect(-20, -20, 40, 40);
			container.addChild(sprite);
			
			body = new Body();
			circleShape = new Circle(40);
			body.shapes.add(circleShape); // 形状をBodyへ追加
			body.position.setxy(_x, _y); // 空間内の座標
			
			theta = -(Math.PI * 0.5) + Math.atan2(cy - body.position.y , cx - body.position.x);
			distance = Math.sqrt(Math.pow(cx - body.position.x , 2) + Math.pow(cy - body.position.y, 2));
			
			v = Math.sqrt(K / body.mass) * distance;
			vx = v * Math.cos(theta);
			vy = v * Math.sin(theta);
			body.velocity.setxy(vx, vy);
			
			space.bodies.add(body);
			sprite.x = body.position.x;
			sprite.y = body.position.y;
			
			obj = new Object();
			obj.body = body;
			obj.sprite = sprite;
			bodyList.push(obj);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			var i:uint;
			var n:uint;
			var obj:Object;
			var body:Body;
			var sprite:Sprite;
			var distance:Number
			var theta:Number;
			var force:Number;
			var fx:Number;
			var fy:Number;
			//
			space.step(1 / stage.frameRate);
			// デバッグ用の表示
			debug.clear();
			debug.draw(space);
			debug.flush();
			
			n = bodyList.length;
			for (i = 0; i < n; i++)
			{
				obj = bodyList[i];
				body = obj.body;
				sprite = obj.sprite;
				
				distance = Math.sqrt(Math.pow(body.position.x - cx, 2) + Math.pow(body.position.y - cy, 2));
				theta = Math.atan2( cy - body.position.y ,   cx - body.position.x);
				
				force = K * distance;
				if (force < 300)
				{
					force = 0;
					body.velocity.setxy(0, 0);
				}
				
				fx = force * Math.cos(theta);
				fy = force * Math.sin(theta);
				body.force = new Vec2(fx, fy);
				//
				sprite.x = body.position.x
				sprite.y = body.position.y;
				theta = (body.rotation * 180 / Math.PI) % (360);
				sprite.rotation = theta;
			}
			checkPostion();
		}
		private function checkPostion():void 
		{
			var i:uint;
			var n:uint;
			var obj:Object;
			var body:Body;
			var sprite:Sprite;
			n = bodyList.length;
			for (i = 0; i < n; i++)
			{
				obj = bodyList[i];
				body = obj.body;
				if (body.isSleeping)
				{
					sprite = obj.sprite;
					//
					space.bodies.remove(body);
					container.removeChild(sprite);
					bodyList.splice(i, 1);
					checkPostion();
					break;
				}
				
				
			}
		}
	}

}