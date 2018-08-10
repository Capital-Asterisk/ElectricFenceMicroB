#include "CommonStuff.as"

class Hubhub : ScriptObject
{

    Hubhub()
    {
        Print("hubhub was made");
    }

    void FixedUpdate(float delta)
    {
        Print(RandomInt(200, 300));
        cast<RigidBody@>(node.GetComponent("RigidBody")).linearVelocity = Vector3(0, 1, 0);
    }


}

namespace S_Menu
{
// Game stuff go here
void Salamander(int stats)
{
    if (stats == 1)
    {
        //scene_.LoadXML(cache.GetFile("Scenes/Scene1.xml"));
        
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


        //Viewport@ viewport = Viewport(scene_, scene_.GetChild("CameraNode").GetComponent("Camera"));
        //renderer.viewports[0] = viewport;

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

    }
    Print(RandomInt(11, 124));
}

}
