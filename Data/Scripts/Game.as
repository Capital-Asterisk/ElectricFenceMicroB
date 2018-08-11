#include "CommonStuff.as"

class Hubhub : ScriptObject
{

    Hubhub()
    {
        Print("hubhub was made");
    }

    void FixedUpdate(float delta)
    {
        Print(RandomInt(0, 3));
        cast<RigidBody@>(node.GetComponent("RigidBody")).linearVelocity = Vector3(0, 1, 0);
    }


}

class Room
{
    bool generated;
    int x, y, wid, hei, metype;
    Array<Array<int>> buckets;

    Room()
    {
        generated = false;
    }
    
    void Jenerate(int entX, int entY, float doorX, float doorZ) {
        buckets.Resize(20);
        log_ = "coriolis motorcycle";
        StringHash hash(log_);
        Print(hash.value);
        SetRandomSeed(hash.value);
        metype = RandomInt(0, 3);
        switch ()
        {
        case 0:
            // small boi
            break;
        case 1:
            // big boi
            break;
        case 2:
            // long boi
            break;
        }
    }

}

void GenerateGunModel()
{


}



void PlayTheDamnGame()
{
    ChangeScene(@S_Game::Salamander);
}

namespace S_Menu
{
// Game stuff go here
void Salamander(int stats)
{
    if (stats == 1)
    {
        scene_.LoadXML(cache.GetFile("Scenes/MenuScene.xml"));
        
        UIElement@ menuUI = ui.LoadLayout(cache.GetResource("XMLFile", "UI/Menu.xml"));
        menuUI.SetSize(1280, 720);
        menuUI.SetPosition((graphics.width - menuUI.width) / 2, (graphics.height - menuUI.height) / 2);
        
        ui.root.AddChild(menuUI);

        menuSounds_ = scene_.CreateComponent("SoundSource");
        menuSounds_.soundType = SOUND_MUSIC;

        Sound@ a = cache.GetResource("Sound", "Sounds/EFMBMenu.ogg");
        a.looped = true;
        menuSounds_.Play(a);
        menuSounds_.frequency *= timescale_;

        Viewport@ viewport = Viewport(scene_, scene_.GetChild("CameraNode").GetComponent("Camera"));
        renderer.viewports[0] = viewport;

        Button@ buttplay = menuUI.GetChild("ButtPlay", true);
        SubscribeToEvent(buttplay, "Released", "PlayTheDamnGame");

    } else {
        scene_.GetChild("SpinMe").Rotate(Quaternion(0, 0, delta_ * 5), TS_LOCAL);
    }
    //Print(RandomInt(11, 124));
}
}


namespace S_Game
{

// Game stuff go here
void Salamander(int stats)
{
    if (stats == 1)
    {
        scene_.LoadXML(cache.GetFile("Scenes/Scene1.xml"));
        
        Node@ n = scene_.CreateChild("Laran");
        StaticModel@ model = n.CreateComponent("StaticModel");
        model.model = cache.GetResource("Model", "Models/ezsphere.mdl");
        ScriptObject@ so = n.CreateScriptObject("Scripts/Game.as", "Hubhub");
        RigidBody@ rb = n.CreateComponent("RigidBody");
        rb.mass = 1.0f;
        rb.friction = 1.0f;
        CollisionShape@ cs = n.CreateComponent("CollisionShape");
        cs.SetBox(Vector3::ONE);

        Viewport@ viewport = Viewport(scene_, scene_.GetChild("CameraNode").GetComponent("Camera"));
        renderer.viewports[0] = viewport;

        Room r;
        r.Jenerate(int entX, int entY, 0.0, 0.0) ;

    }
    //Print(RandomInt(11, 124));
}

}
