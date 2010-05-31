package
{
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxSprite;
    import org.flixel.FlxState;
    import org.flixel.FlxText;
    import org.flixel.FlxU;

    public class PlayState extends FlxState
    {

        [Embed(source="data/background.png")]
        private var LevelSprite:Class;

        [Embed(source="data/lives.png")]
        private var LivesSprite:Class;

        public static const WELCOME_STATE:uint = 0;
        public static const PLAYING_STATE:uint = 1;
        public static const COLLISION_STATE:uint = 2;
        public static const RESTART_STATE:uint = 3;
        public static const GAME_OVER_STATE:uint = 4;
        public static const DEATH_OVER:uint = 5;

        public var collision:Boolean;
        public var gameState:uint;

        private const TILE_SIZE:int = 40;

        private var _player:Frog;
        private var logGroup:FlxGroup;
        private var carGroup:FlxGroup;
        private var turtleGroup:FlxGroup;
        private var timerBar:FlxSprite;
        private var gameTime:int = 1800;
        private var timer:int;
        private var waterY:int;
        private var lifeSprites:Array = [];
        private const LIFE_X:int = 20;
        private const LIFE_Y:int = 600;
        private var bonusGroup:FlxGroup;
        private var timerBarBackground:FlxSprite;
        private var timeTxt:FlxText;
        private const TIMER_BAR_WIDTH:int = 300;

        override public function create():void
        {
            FlxG.showBounds = true;

            timer = gameTime;

            waterY = TILE_SIZE * 8;
            var bg:FlxSprite = new FlxSprite(0, 0, LevelSprite);
            add(bg);


            var demoTXT:FlxText = add(new FlxText(0, 0, 480, "Flixel Frogger Demo").setFormat(null, 24, 0xffffff, "center", 0x000000)) as FlxText;
            var credits:FlxText = add(new FlxText(0, demoTXT.height, 480, "by Jesse Freeman").setFormat(null, 10, 0xffffff, "center", 0x000000)) as FlxText;


            createLives(3);

            // Bonus

            bonusGroup = new FlxGroup();

            bonusGroup.add(new Bonus(calculateColumn(0) + 15, calculateRow(2), 200, 200));
            bonusGroup.add(new Bonus(calculateColumn(3) - 5, calculateRow(2), 200, 200));
            bonusGroup.add(new Bonus(calculateColumn(5) + 20, calculateRow(2), 200, 200));
            bonusGroup.add(new Bonus(calculateColumn(8), calculateRow(2), 200, 200));
            bonusGroup.add(new Bonus(calculateColumn(11) - 15, calculateRow(2), 200, 200));

            add(bonusGroup);

            // Create Logs

            logGroup = new FlxGroup();
            turtleGroup = new FlxGroup();

            logGroup.add(new Log(0, calculateRow(3), Log.TypeC, FlxSprite.RIGHT, 40));
            logGroup.add(new Log(Log.TypeCWidth + 77, calculateRow(3), Log.TypeC, FlxSprite.RIGHT, 40));
            logGroup.add(new Log((Log.TypeCWidth + 77) * 2, calculateRow(3), Log.TypeC, FlxSprite.RIGHT, 40));

            turtleGroup.add(new TurtlesA(0, calculateRow(4), -1, -1, FlxSprite.LEFT, 40));
            turtleGroup.add(new TurtlesA((TurtlesA.SPRITE_WIDTH + 123) * 1, calculateRow(4), TurtlesA.DEFAULT_TIME, 200, FlxSprite.LEFT, 40));
            turtleGroup.add(new TurtlesA((TurtlesA.SPRITE_WIDTH + 123) * 2, calculateRow(4), -1, -1, FlxSprite.LEFT, 40));

            logGroup.add(new Log(0, calculateRow(5), Log.TypeB, FlxSprite.RIGHT, 40));
            logGroup.add(new Log(Log.TypeBWidth + 70, calculateRow(5), Log.TypeB, FlxSprite.RIGHT, 40));

            logGroup.add(new Log(0, calculateRow(6), Log.TypeA, FlxSprite.RIGHT, 40));
            logGroup.add(new Log(Log.TypeAWidth + 77, calculateRow(6), Log.TypeA, FlxSprite.RIGHT, 40));
            logGroup.add(new Log((Log.TypeAWidth + 77) * 2, calculateRow(6), Log.TypeA, FlxSprite.RIGHT, 40));

            turtleGroup.add(new TurtlesB(0, calculateRow(7), TurtlesA.DEFAULT_TIME, 0, FlxSprite.LEFT, 40));
            turtleGroup.add(new TurtlesB((TurtlesB.SPRITE_WIDTH + 95) * 1, calculateRow(7), -1, -1, FlxSprite.LEFT, 40));
            turtleGroup.add(new TurtlesB((TurtlesB.SPRITE_WIDTH + 95) * 2, calculateRow(7), -1, -1, FlxSprite.LEFT, 40));


            add(logGroup);
            add(turtleGroup);

            _player = add(new Frog(TILE_SIZE * 1, TILE_SIZE * 14 + 2)) as Frog;

            // Cars
            carGroup = new FlxGroup();

            carGroup.add(new Truck(0, calculateRow(9), FlxSprite.LEFT, 40));
            carGroup.add(new Truck(270, calculateRow(9), FlxSprite.LEFT, 40));

            carGroup.add(new Car(0, calculateRow(10), Car.TYPE_C, FlxSprite.RIGHT, 40));
            carGroup.add(new Car(270, calculateRow(10), Car.TYPE_C, FlxSprite.RIGHT, 40));

            carGroup.add(new Car(0, calculateRow(11), Car.TYPE_D, FlxSprite.LEFT, 40));
            carGroup.add(new Car(270, calculateRow(11), Car.TYPE_D, FlxSprite.LEFT, 40));


            carGroup.add(new Car(0, calculateRow(12), Car.TYPE_B, FlxSprite.RIGHT, 40));
            carGroup.add(new Car((Car.SPRITE_WIDTH + 138) * 1, calculateRow(12), Car.TYPE_B, FlxSprite.RIGHT, 40));
            carGroup.add(new Car((Car.SPRITE_WIDTH + 138) * 2, calculateRow(12), Car.TYPE_B, FlxSprite.RIGHT, 40));

            carGroup.add(new Car(0, calculateRow(13), Car.TYPE_A, FlxSprite.LEFT, 40));
            carGroup.add(new Car((Car.SPRITE_WIDTH + 138) * 1, calculateRow(13), Car.TYPE_A, FlxSprite.LEFT, 40));
            carGroup.add(new Car((Car.SPRITE_WIDTH + 138) * 2, calculateRow(13), Car.TYPE_A, FlxSprite.LEFT, 40));

            add(carGroup);

            gameState = PLAYING_STATE;

            timeTxt = new FlxText(bg.width - 70, LIFE_Y+18, 60, "TIME").setFormat(null, 14, 0xffff00, "right");
            add(timeTxt);

            timerBarBackground = new FlxSprite(timeTxt.x - TIMER_BAR_WIDTH + 5, LIFE_Y+20);
            timerBarBackground.createGraphic(TIMER_BAR_WIDTH, 16, 0xff21de00);
            add(timerBarBackground);

            timerBar = new FlxSprite(timerBarBackground.x, timerBarBackground.y);
            timerBar.createGraphic(1, 16, 0xFF000000);
            timerBar.scrollFactor.x = timerBar.scrollFactor.y = 0;
            timerBar.origin.x = timerBar.origin.y = 0;
            timerBar.scale.x = 40;
            add(timerBar);

        }

        public function calculateColumn(value:int):int
        {
            return value * TILE_SIZE;
        }

        public function calculateRow(value:int):int
        {
            return calculateColumn(value);
        }

        override public function update():void
        {

            timer -= FlxG.elapsed;

            //timerBar.scale.x = TIMER_BAR_WIDTH - Math.round((timer / gameTime * TIMER_BAR_WIDTH));

            if (timer == 0)
            {

                killPlayer();
            }
            //Updates all the objects appropriately
            super.update();

            if (gameState == DEATH_OVER)
            {
                restart();
            }

            else
            {
                FlxU.overlap(carGroup, _player, death);
                FlxU.overlap(logGroup, _player, float);
                FlxU.overlap(turtleGroup, _player, float);

                if (_player.x < 0 || _player.x > (FlxG.width - _player.frameWidth))
                {

                    if (_player.y < waterY)
                        killPlayer();
                }
            }

        }

        private function float(Collision:WrappingSprite, Player:Frog):void
        {

            if (!(FlxG.keys.LEFT || FlxG.keys.RIGHT))
            {
                //Player.velocity.x = Collision.velocity.x;
            }
        }

        private function restart():void
        {


            _player.restart();
            timer = gameTime;
            PlayState(FlxG.state).gameState = PlayState.PLAYING_STATE;

        }

        public function death(Collision:FlxSprite, Player:Frog):void
        {
            killPlayer();
        }

        private function killPlayer():void
        {

            if (gameState != COLLISION_STATE)
            {
                gameState = COLLISION_STATE;

                _player.death();

                removeLife(1);

                if (totalLives == 0)
                {
                    gameOver();
                }
            }
        }

        private function gameOver():void
        {

        }

        private function createLives(value:int):void
        {
            for (var i:int = 0; i < value; i++)
            {
                addLife(1);
            }
        }

        private function addLife(value:int):void
        {
            var flxLife:FlxSprite = new FlxSprite(LIFE_X * totalLives, LIFE_Y, LivesSprite);
            add(flxLife);
            lifeSprites.push(flxLife);
        }

        private function removeLife(value:int):void
        {
            var id:int = totalLives - 1;
            var sprite:FlxSprite = lifeSprites[id];
            sprite.kill();
            lifeSprites.splice(id, 1);
        }

        private function get totalLives():int
        {
            trace("life:", lifeSprites.length);
            return lifeSprites.length;
        }
    }
}