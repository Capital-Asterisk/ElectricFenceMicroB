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
    bool blackFloor;
    int mmx, mmy, wid, hei, metype;
    Array<Array<int>> buckets;
    Array<int> doors = {-1, -1, -1, -1}; // top right bottom left

    Room()
    {
        generated = false;
    }
    
    void Jenerate(int dirX, int dirY, float doorX, float doorZ) {
        buckets.Resize(20);
        StringHash hash(log_);
        Print(hash.value);
        SetRandomSeed(hash.value);
        blackFloor = (RandomInt(0, 11) <= 2); // 20% chance of black floor
        metype = RandomInt(0, 3);
        switch (metype)
        {
        case 0:
            // small boia
            wid = RandomInt(6, 10);
            hei = RandomInt(6, 10);
            break;
        case 1:
            // big boi
            wid = RandomInt(12, 32);
            hei = RandomInt(12, 32);
            break;
        case 2:
            // long boi
            wid = RandomInt(2, 5) + Abs(dirX) * RandomInt(20, 40);
            hei = RandomInt(2, 5) + Abs(dirY) * RandomInt(20, 40);
            doors[Abs(dirX)] = RandomInt(0, Min(wid, hei) - 1);
            doors[Abs(dirX) + 2] = RandomInt(0, Min(wid, hei) - 1);
            break;
        }
        if (metype != 2)
        {
            doors[0] = RandomInt(0, wid - 1);
            doors[2] = RandomInt(0, wid - 1);
            doors[1] = RandomInt(0, hei - 1);
            doors[3] = RandomInt(0, hei - 1);
        }
        Print("Wid: " + wid + " Hei: " + hei + " Type: " + metype);
        
    }

    void AddStuffToNode(Node@ aaa) {
        
        RigidBody@ rb = aaa.CreateComponent("RigidBody");
        
        CollisionShape@ cs = aaa.CreateComponent("CollisionShape");
        cs.SetBox(Vector3::ONE);
        cs.size = Vector3(wid, 1, hei);
        cs.position = Vector3(0, -0.5, 0);
        
        Material@ floorMat = cache.GetResource("Material", "Materials/Floor" + (blackFloor ? 1 : 0) + ".xml");
        Model@ floorMod = cache.GetResource("Model", "Models/Plane.mdl");
        for (uint x = 0; x < wid; x ++)
        {
            for (uint y = 0; y < hei; y ++)
            {
                Node@ aa = aaa.CreateChild("floor" + x + "," + y);
                StaticModel@ minecraft = aa.CreateComponent("StaticModel");
                minecraft.model = floorMod;
                minecraft.material = floorMat;
                aa.position = Vector3(float(x + mmx) - float(wid) / 2 + 0.5, 0, float(y + mmy) - float(hei) / 2 + 0.5);
                
                
            }
        }
        
        Node@ a = scene_.InstantiateXML(cache.GetResource("XMLFile", "Objects/Door.xml"), Vector3(0, 1, 5), Quaternion(0, 0, 0));
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
        cast<Sprite>(menuUI.GetChild("Logo")).texture = Texture2D();
        cast<Sprite>(menuUI.GetChild("Logo")).texture.SetNumLevels(1);
        cast<Sprite>(menuUI.GetChild("Logo")).texture.Load("Data/Textures/MenuLogo.png");
        
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

Node@ camera_;
Node@ player_;
Node@ tiltme_;
SoundSource@ drill_;
Vector3 prevVel_;
RigidBody@ playerRB_;

float accelR_ = 0;
float accelF_ = 0;

// Game stuff go here
void Salamander(int stats)
{
    if (stats == 1)
    {
        scene_.LoadXML(cache.GetFile("Scenes/Scene1.xml"));
        
        //Node@ n = scene_.CreateChild("Laran");
        //StaticModel@ model = n.CreateComponent("StaticModel");
        //model.model = cache.GetResource("Model", "Models/ezsphere.mdl");
        //ScriptObject@ so = n.CreateScriptObject("Scripts/Game.as", "Hubhub");
        //RigidBody@ rb = n.CreateComponent("RigidBody");
        //rb.mass = 1.0f;
        //rb.friction = 1.0f;
        //CollisionShape@ cs = n.CreateComponent("CollisionShape");
        //cs.SetBox(Vector3::ONE);

        Node@ nnnnn = scene_.CreateChild("Laran");
        Room r;
        r.Jenerate(1, 0, 0.0, 0.0);
        r.AddStuffToNode(nnnnn);
        
        player_ = scene_.GetChild("Player");
        playerRB_ = player_.GetComponent("RigidBody");
        drill_ = player_.GetComponent("SoundSource");
        tiltme_ = player_.GetChild("TiltMe");
        camera_ = scene_.GetChild("CameraNode");

        camera_.position = player_.position + Vector3(-10, 16, -5);
        camera_.LookAt(player_.position, Vector3::UP, TS_WORLD);

        drill_.sound.looped = true;
        drill_.Play(drill_.sound);

        Viewport@ viewport = Viewport(scene_, camera_.GetComponent("Camera"));
        renderer.viewports[0] = viewport;

    } else {
        //Print(RandomInt(11, 124));
        // Player code becuase i'm lazy
        
        // Controls
        Vector2 mcjoy(bint(input.keyDown[KEY_D]) - bint(input.keyDown[KEY_A]), bint(input.keyDown[KEY_W]) - bint(input.keyDown[KEY_S]));
        
        accelF_ = (playerRB_.rotation * Vector3::FORWARD).DotProduct(playerRB_.linearVelocity - Vector3(0, playerRB_.linearVelocity.y, 0));
        // mess of movement
        if (mcjoy.y == 0)
        {
            accelF_ -= Sign(accelF_) * delta_ * 10;
            if (Abs(accelF_) <= delta_ * 10)
            {
                accelF_ = 0;
            }
        } else {
            accelF_ = Clamp(accelF_ + mcjoy.y * delta_ * 10.0 * (Sign(accelF_) != Sign(mcjoy.y) ? 6 : 1), -20.0, 20.0);
        }
        
        if (mcjoy.x == 0)
        {
            accelR_ -= Sign(accelR_) * delta_ * 20;
            if (Abs(accelR_) <= delta_ * 20)
            {
                accelR_ = 0;
            }
        } else {
            accelR_ = Clamp(accelR_ + mcjoy.x * delta_ * 10.0 * (Sign(accelR_) != Sign(mcjoy.x) ? 6 : 1), -30.0, 30.0);
        }
        

        playerRB_.angularVelocity = Vector3(0, accelR_, 0);
        playerRB_.linearVelocity = playerRB_.linearVelocity.Lerp(playerRB_.rotation * Vector3::FORWARD * accelF_ + Vector3(0, playerRB_.linearVelocity.y, 0), 0.5);
        prevVel_ = playerRB_.linearVelocity;
        tiltme_.rotation = tiltme_.rotation.Nlerp(Quaternion(Clamp(accelF_ * 2.0, -70.0, 70.0), 0, Clamp(-accelR_ * accelF_ * 0.8, -70.0, 70.0)), 0.2, true);
        // * ((Sign(accelF_) != Sign(mcjoy.y) && mcjoy.y != 0) ? -1 : 1)
        
        // Sound
        drill_.frequency = (44100 * timescale_) * (Abs(accelF_) / 10 + 1) * (Abs(accelR_) / 10 + 1) * 0.5;
        drill_.gain = Lerp(drill_.gain, Clamp(Abs(accelF_ / 15) + Abs(accelR_ / 20), 0, 0.7), 0.7);
    
        // LOOK AT PLAYER
        camera_.position = player_.position + Vector3(-5, 8, -2.5);
        camera_.LookAt(player_.position, Vector3::UP, TS_WORLD);
    
    
    }
}

}
