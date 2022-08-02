package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var randombg = 0;
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;
	public static var thebuttonyoupressed = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'play',
		'freeplay',
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	
	var overlapingbutton = false;
	var oldoverlap = false;
	var mousesprite:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();
		Highscore.load();

		if(!initialized) {
			if(FlxG.save.data != null && FlxG.save.data.fullscreen) {
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null) {
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if desktop
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end

		if (!initialized && FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
	
		Conductor.changeBPM(102);
		persistentUpdate = true;

		WeekData.loadTheFirstEnabledMod();

		mousesprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/mouse'));
		FlxG.mouse.load(mousesprite.pixels);
		FlxG.mouse.visible = true;

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if(!initialized) initialized = true;

		var yellowbg:FlxSprite = new FlxSprite(-117, -118);
		yellowbg.loadGraphic(Paths.image('mainmenu/background yellow'));
		add(yellowbg);

		var frontbg:FlxSprite = new FlxSprite(150, 100);
		frontbg.loadGraphic(Paths.image('mainmenu/background front'));
		add(frontbg);
		
		var qmc:FlxSprite = new FlxSprite(180, 126);
		qmc.loadGraphic(Paths.image('mainmenu/pop qmc'));
		add(qmc);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(326 + (i * 182), 145);
			menuItem.loadGraphic(Paths.image('mainmenu/' + optionShit[i]));
			menuItem.ID = i;
			menuItems.add(menuItem);
		}

		camFollowPos.x += ((FlxG.width / 2) - 1);
		camFollowPos.y += 360;
		camFollow.x += camFollowPos.x;
		camFollow.y = camFollowPos.y;

		FlxG.camera.follow(camFollowPos, null, 0);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin) {
			overlapingbutton = false;

			menuItems.forEach(function(spr:FlxSprite) {
				if(FlxG.mouse.overlaps(spr)) {
					overlapingbutton = true;
					if(FlxG.mouse.justPressed) {
						thebuttonyoupressed = spr.ID;
						FlxG.mouse.unload();
						FlxG.mouse.visible = false;
						switch(optionShit[thebuttonyoupressed]) {
							case 'play':
								PlayState.storyPlaylist = ["poverty-line", "chuzzlin", "readnplead", "bucket"];
								PlayState.isStoryMode = true;
								PlayState.storyDifficulty = 1;
								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
								PlayState.campaignScore = 0;
								LoadingState.loadAndSwitchState(new PlayState(), true);
								FreeplayState.destroyFreeplayVocals();
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								LoadingState.loadAndSwitchState(new options.OptionsState());
						}
					}
				}
			});

			if(oldoverlap != overlapingbutton) {
				oldoverlap = overlapingbutton;
				if(overlapingbutton) {
					mousesprite.loadGraphic(Paths.image('mainmenu/mouseselect'));
					FlxG.mouse.load(mousesprite.pixels);
				} else {
					mousesprite.loadGraphic(Paths.image('mainmenu/mouse'));
					FlxG.mouse.load(mousesprite.pixels);
				}
			}

			#if desktop
			if (FlxG.keys.anyJustPressed(debugKeys)) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}
}