// Some simple base code for Urho3d
// Programming Simulator style

#include "CommonStuff.as"
#include "Game.as"

void Start()
{

    // enable cursor
    input.mouseVisible = true;
    graphics.windowTitle = "Electric Fence - Micro-B";

    // Set default UI style
    XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    ui.root.defaultStyle = style;

    scene_ = Scene();

    input.mouseMode = MM_FREE;

    SubscribeToEvent(scene_, "SceneUpdate", "HandleUpdate");

    // make some randomness random
    SetRandomSeed(time.systemTime);

    ChangeScene(@S_VIntro::Salamander);

}

void HandleKeyDown(StringHash eventType, VariantMap& eventData)
{
  
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    int stat = 0;
    if (ffirst_)
    {
        stat = 1;
        time_ = 0;
        ffirst_ = false;
    }
    delta_ = eventData["TimeStep"].GetFloat();
    time_ += delta_ * timescale_;
    sceneFunc_(stat);
    shakey_ = shakey_ * 0.7;
}

namespace S_VIntro
{

Sprite@ aAAAAAAA;
Sprite@ bA;
Sprite@ cAAAAw;
Text@ dAAAAAAA;

Array<String> phrase = {
    "Inspiring quote goes here",
    "play my gamez",
    "my ********* are becoming ******",
    "%INSPIRING QUOTE%",
    "Feed your fish, get it right.",
    "great, another Vendalenger game.",
    "Expect something",
    "I can count to 2",
    "No Durian",
    "don't check out my gamejolt",
    "I barely have a tumblr",
    "subscribe to mah youtube channel",
    "smash that like button",
    "ADD LOTS OF STARS",
    "No birds allowed",
    "neat one",
    "This game has no fish",
    "Don't expect anything to work",
    "the way it's suppose to.",
    "Also try Boundless Power",
    "Also try Innotgeneric",
    "Also try Rook vs Rook",
    "Also try 200 Bit Fish",
    "I won coriolis three more motorcycle",
    "The earth is a curved hexagon.",
    "Pinch cat at back of neck.",
    "colourful clocks clicking cautiously",
    "When computerized trees wave around in the wind.",
    "sudo rm -rf /"
};

// The Vendalenger screen
void Salamander(int stats)
{
    if (stats == 1)
    {
    
        menuSounds_ = scene_.CreateComponent("SoundSource");
        menuSounds_.soundType = SOUND_MUSIC;
    
        Sprite@ background = ui.root.CreateChild("Sprite", "Background");
        background.color = Color(0.03, 0.03, 0.03);
        background.SetSize(graphics.width, graphics.height);
        
        aAAAAAAA = ui.root.CreateChild("Sprite", "VendalengerText");
        aAAAAAAA.texture = Texture2D();
        aAAAAAAA.texture.SetNumLevels(1);
        aAAAAAAA.texture.filterMode = FILTER_NEAREST;
        aAAAAAAA.texture.Load("Data/Textures/vendalenger.png");
        aAAAAAAA.SetSize(240, 29);
        aAAAAAAA.imageRect = IntRect (0, 0, 240, 29);
        aAAAAAAA.blendMode = BLEND_ADD;
        

        cAAAAw = aAAAAAAA.CreateChild("Sprite", "VendalengerText");
        cAAAAw.texture = null;

        dAAAAAAA = ui.root.CreateChild("Text", "MachinerineMackreywon");
        dAAAAAAA.SetFont(cache.GetResource("Font", "Fonts/Louis George Cafe.ttf"), 16);
        dAAAAAAA.text = "Game by Capital_Asterisk\n" + phrase[RandomInt(0, phrase.length - 1)];
        dAAAAAAA.textAlignment = HA_CENTER;
        dAAAAAAA.color = Color(0.2, 0.2, 0.2);

        bA = ui.root.CreateChild("Sprite", "Square2");  
        bA.texture = null;
        bA.color = Color(0.4, 1.0, 0.0);
        bA.SetSize(40, 40);
        Sprite@ bB = bA.CreateChild("Sprite", "Square1");
        bB.texture = null;
        bB.color = Color(0.4, 1.0, 0.0);
        bB.SetSize(40, 40);
        bB.SetPosition(-40, -40);
        Sprite@ bC = bA.CreateChild("Sprite", "Square3");
        bC.texture = null;
        bC.color = Color(0.4, 1.0, 0.0);
        bC.SetSize(40, 40);
        bC.SetPosition(40, -80);
        
        menuSounds_.Seek(0);
        menuSounds_.Play(cache.GetResource("Sound", "Sounds/vendalenger.ogg"));
        menuSounds_.frequency *= timescale_;
        
        time_ = 0;
        
        cache.BackgroundLoadResource("Model", "Models/ezsphere.mdl");
        
    } else {
        
        aAAAAAAA.SetPosition((graphics.width - aAAAAAAA.width) / 2, (time_ > 0.5) ? (graphics.height - aAAAAAAA.height) / 2 + 75 : -1000000000);
        dAAAAAAA.SetPosition((graphics.width - dAAAAAAA.width) / 2, (time_ > 1.2) ? (graphics.height - dAAAAAAA.height) / 2 + 200 : -1000000000);
        
        float eggs = 32 * (0.7 - time_) * 9;  
        float rock = 240 * Pow(time_ - 0.5, 2) * 80 + 240;
        cAAAAw.SetSize(rock, eggs);
        cAAAAw.SetPosition((-rock + aAAAAAAA.width) / 2, (-eggs + aAAAAAAA.height) / 2);
        float quadratic = 12000.0f * Pow(Min(time_, 0.5f) - 0.47f, 2);
        bA.SetPosition((graphics.width - bA.width) / 2, quadratic + (graphics.height - bA.height) / 2);
        
        if (cache.numBackgroundLoadResources == 0 && time_ > 3)
        {
            ChangeScene(@S_Menu::Salamander);
        }
        
    }
}

}
