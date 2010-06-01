package
{
    import flash.geom.Point;

    import org.flixel.FlxG;
    import org.flixel.FlxSprite;

    public class Frog extends FlxSprite
    {

        [Embed(source="data/frog_sprites.png")]
        private var SpriteImage:Class;
        private var startPosition:Point;
        private var moveX:int;
        private var maxMoveX:int;
        private var maxMoveY:int;
        private var targetX:Number;
        private var targetY:Number;
        private var animationFrames:int = 8;
        private var moveY:Number;
        private var state:PlayState;
        public var isMoving:Boolean;

        public function Frog(X:Number, Y:Number)
        {
            super(X, Y);

            startPosition = new Point(X, Y);
            loadGraphic(SpriteImage, true, false, 40, 40);

            moveX = 5;
            moveY = 5;
            maxMoveX = moveX * animationFrames;
            maxMoveY = moveY * animationFrames;

            targetX = X;
            targetY = Y;


            addAnimation("idle" + UP, [0], 0, false);
            addAnimation("idle" + RIGHT, [2], 0, false);
            addAnimation("idle" + DOWN, [4], 0, false);
            addAnimation("idle" + LEFT, [6], 0, false);
            addAnimation("walk" + UP, [0,1], 10, true);
            addAnimation("walk" + RIGHT, [2,3], 10, true);
            addAnimation("walk" + DOWN, [4,5], 10, true);
            addAnimation("walk" + LEFT, [6,7], 10, true);
            addAnimation("die", [8, 9, 10, 11], 2, false);

            facing = FlxSprite.UP;

            state = FlxG.state as PlayState;
        }

        override public function set facing(value:uint):void
        {
            super.facing = value;

            if(value == UP || value == DOWN)
            {
                width = 32;
                height = 25;
                offset.x = 4;
                offset.y = 6;
            }
            else
            {
                width = 25;
                height = 32;
                offset.x = 6;
                offset.y = 4;
            }
        }

        override public function update():void
        {


            if (state.gameState == PlayState.COLLISION_STATE)
            {
                if (frame == 11)
                {
                    state.gameState = PlayState.DEATH_OVER;
                }
            }
            else
            {

                if (x == targetX && y == targetY)
                {
                    play("idle" + facing);

                    if (FlxG.keys.LEFT)
                    {
                        targetX = x - maxMoveX;
                        facing = LEFT;
                    } else if (FlxG.keys.RIGHT)
                    {
                        targetX = x + maxMoveX;
                        facing = RIGHT;
                    }
                    else if (FlxG.keys.UP)
                    {
                        targetY = y - maxMoveY;
                        facing = UP;
                    }
                    else if (FlxG.keys.DOWN)
                    {
                        targetY = y + maxMoveY;
                        facing = DOWN;
                    }

                    isMoving = false;


                }
                else
                {
                    if (facing == LEFT)
                    {
                        x -= moveX;
                    } else if (facing == RIGHT)
                    {
                        x += moveX;
                    } else if (facing == UP)
                    {
                        y -= moveY;
                    } else if (facing == DOWN)
                    {
                        y += moveY;
                    }

                    // Make sure Frog doesn't go out of bounds
                    if(x > FlxG.width - frameWidth)
                    {
                        x = FlxG.width - frameWidth;
                        targetX = x;
                    }
                    else if(x < 0 )
                    {
                        x = 0;
                        targetX = x;
                    }

                    play("walk" + facing);

                    isMoving = true;
                }

            }

            //Default object physics update
            super.update();
        }

        public function death():void
        {
            play("die");
        }

        public function restart():void
        {
            isMoving = false;
            x = startPosition.x;
            y = startPosition.y;
            targetX = startPosition.x;
            targetY = startPosition.y;
            facing = UP;
            play("idle" + facing);

        }

        public function float(speed:int, facing:uint):void
        {
            if (isMoving != true && state.gameState != PlayState.COLLISION_STATE)
            {
                x += (facing == RIGHT) ? speed : -speed;
                targetX = x;
                isMoving = true;
            }
        }
    }
}