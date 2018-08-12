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

class Meat : ScriptObject
{

    int health;

    Meat()
    {
        Print("enemy was made");
    }

    void WorldCollision(VariantMap& eventData)
    {
        Print("MASH");
    }

}

class BoxCaterpillar : Meat
{
    
    void FixedUpdate(float delta)
    {
        node.rotation = Quaternion(0, node.rotation.yaw, Sin(time_ * 180) * 30.0);
    }
}

// nothing roblox related
class BSMBullet : ScriptObject
{
//    PhysicsWorld@ physics;
    Vector3 pxt;
    String tgt;
    uint lifetime = 60;
    int damage;

    BSMBullet()
    {
        Print("bsm was made");
    }

    void FixedUpdate(float d)
    {
        //Print(b);
        Scene@ e = cast<Scene@>(node.parent);
        //cast<RigidBody@>(node.GetComponent("RigidBody")).linearVelocity = Vector3(0, 1, 0);
        PhysicsRaycastResult prr = S_Game::physics_.RaycastSingle(Ray(node.position, pxt.Normalized() * 0.1), pxt.length * 2 * d * timescale_);
        //Print("HIT: " + prr.position.ToString());
        lifetime --;
        if (prr.body !is null)
        {
            Node@ boom = prr.body.node;
            if (boom.name.StartsWith("Wall") or boom.name.StartsWith("Door"))
            {
                // A wall was hit
                //Print("AAAAA");
                lifetime = 0;
                S_Game::bulletHits_.Play(S_Game::bulletSnd_);
                S_Game::bulletHits_.frequency = 44100 * timescale_ * Random(0.9, 1.2);
            }
        } else {
            
        }
        node.position += pxt * d * timescale_;
        if (lifetime == 0)
        {
            node.Remove();
        }
    }


}


class Room
{
    bool generated;
    bool blackFloor;
    Node@ mahnode;
    int doorlink, wid, hei, metype;
    float mmx, mmy;
    //Array<Array<int>> buckets;
    Array<int> doors = {-1, -1, -1, -1}; // top right bottom left

    Room()
    {
        generated = false;
    }
    
    bool IsPlayerInside()
    {
        Vector3 TPose(mahnode.position - S_Game::player_.position);
        return (Abs(TPose.x) < wid / 2 + 2 && Abs(TPose.z) < hei / 2 + 2);
        
    }
    
    float DoorDist(int which)
    {
        if (doors[which] == -1)
            return 9999999;
        Node@ door = mahnode.GetChild("Door" + which);
        return Vector3(door.position + mahnode.position - S_Game::player_.position).length;
    }
    
    void Jenerate(int dirX, int dirY, int linkdoor, float doorX, float doorZ) {
        //buckets.Resize(20);
        doorlink = linkdoor;
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
            wid = RandomInt(2, 5) + Abs(dirY) * RandomInt(20, 40);
            hei = RandomInt(2, 5) + Abs(dirX) * RandomInt(20, 40);
            doors[Abs(dirY)] = RandomInt(0, Min(wid, hei) - 1);
            doors[Abs(dirY) + 2] = RandomInt(0, Min(wid, hei) - 1);
            break;
        }
        if (metype != 2)
        {
            doors[0] = RandomInt(0, wid - 1);
            doors[2] = RandomInt(0, wid - 1);
            doors[1] = RandomInt(0, hei - 1);
            doors[3] = RandomInt(0, hei - 1);
        }
        //if (linkdoor != -1)
        //{
        //    int oppositeDoor = (linkdoor + 2) & 4;
        //}
        mmx = doorX;
        mmy = doorZ;
        Print("Wid: " + wid + " Hei: " + hei + " Type: " + metype);
        Print("d: " + doors[0] + " " + doors[1] + " " + doors[2] + " " + doors[3]);
    }

    void MakeWall(Vector2 start, Vector2 dir, int amt, int door, int doorAng, Model@ model, Material@ mate)
    {
        
        //Clone(CreateMode = REPLICATED)
        uint i = 0;
        while (i < amt) {
            if (i != doors[door])
            {
                Node@ wall = mahnode.CreateChild("Wall" + doorAng);
                wall.CreateComponent("RigidBody");
                CollisionShape@ cs = wall.CreateComponent("CollisionShape");
                cs.SetBox(Vector3::ONE);
                cs.size = Vector3(1, 2, 1);
                StaticModel@ minecraft = wall.CreateComponent("StaticModel");
                minecraft.castShadows = true;
                minecraft.model = model;
                minecraft.material = mate;
                wall.position = Vector3(start.x + dir.x * i, 1, start.y + dir.y * i);
                
            } else {
                Vector2 sohcahtoa(Sin(doorAng), Cos(doorAng));
                sohcahtoa *= 0.5;
                Node@ aDoorAble = scene_.InstantiateXML(cache.GetResource("XMLFile", "Objects/Door.xml"), Vector3(start.x + dir.x * (float(i) + 0.5) + sohcahtoa.x, 1, start.y + dir.y * (float(i) + 0.5) + sohcahtoa.y), Quaternion(0, doorAng, 0));
                aDoorAble.name = "Door" + door;
                mahnode.AddChild(aDoorAble);
                i ++; // add twice becuase doors are bigger
            }
            i ++;
        }
        
        
    }

    void AddStuffToNode(Node@ aaa) {
        
        //RigidBody@ rb = aaa.CreateComponent("RigidBody");
        
        //CollisionShape@ cs = aaa.CreateComponent("CollisionShape");
        //cs.SetBox(Vector3::ONE);
        //cs.size = Vector3(wid, 1, hei);
        //cs.position = Vector3(0, -0.5, 0);
        mahnode = aaa;
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
                aa.position = Vector3(float(x) - float(wid) / 2 + 0.5, 0, float(y) - float(hei) / 2 + 0.5);
                S_Game::SpawnEnemy("BoxCaterpillar", 70, 0, aa.position + Vector3(0, 1, 0), Quaternion(0, 0, 0));
            }
        }
        Material@ wallmart = cache.GetResource("Material", "Materials/Wall" + (0) + ".xml");
        Model@ wallmod = cache.GetResource("Model", "Models/Wall.mdl");
        // Top wall
        MakeWall(Vector2(-float(wid) / 2 + 0.5, float(hei) / 2 + 0.5), Vector2(1, 0), wid, 0, 0, wallmod, wallmart);
        // Bottom wall
        MakeWall(Vector2(-float(wid) / 2 + 0.5, -float(hei) / 2 - 0.5), Vector2(1, 0), wid, 2, 180, wallmod, wallmart);
        // Right wall
        MakeWall(Vector2(float(wid) / 2 + 0.5, -float(hei) / 2 + 0.5), Vector2(0, 1), hei, 1, 90, wallmod, wallmart);
        // Left wall
        MakeWall(Vector2(-float(wid) / 2 - 0.5, -float(hei) / 2 + 0.5), Vector2(0, 1), hei, 3, 270, wallmod, wallmart);
        
        // Move to the right place
        if (doorlink != -1)
        {
            int oppositeDoor = (doorlink + 2) % 4;
            Print("OPPOSITE DOOR: " + oppositeDoor);
            Node@ theDoor = mahnode.GetChild("Door" + oppositeDoor);
            mahnode.position = Vector3(mmx - theDoor.position.x, 0, mmy - theDoor.position.z);
        }
    }

}

class Gun
{
    int back, barrel, handle;
    int bulletsPerShot;
    int rarity;
    float recoil, damage, rof, muzzVelocity;
    float barrelLength;
    float lastshot;
    float mytier;
    float soundPitch;
    bool laser;
    bool paralell;
    String nom;
    SoundSource@ notsrc;
    Sound@ gunSound;

    Gun()
    {
    };

    void Update()
    {
        lastshot += delta_;
        S_Game::muzzleFlash_.brightness = Max(0.00001, S_Game::muzzleFlash_.brightness - 0.3);
    }

    void Shoot()
    {
        if (lastshot < 1.0 / rof)
        {
            return;
        }
        Model@ bulletmdl = cache.GetResource("Model", "Models/Bullet.mdl");
        Material@ bulletmtl = cache.GetResource("Material", "Materials/Bullet" + bint(laser) + ".xml");
        for (int i = 0; i < bulletsPerShot; i ++)
        {
            Node@ n = scene_.CreateChild("Laran");
            n.position = S_Game::gunThing_.LocalToWorld(Vector3(0, 0, barrelLength));
            n.rotation = S_Game::gunThing_.worldRotation * Quaternion(Random(-recoil, recoil) * 0.2, Random(-recoil, recoil), 0);
            StaticModel@ model = n.CreateComponent("StaticModel");
            model.model = bulletmdl;
            model.material = bulletmtl;
            BSMBullet@ so = cast<BSMBullet@>(n.CreateScriptObject(scriptFile, "BSMBullet", LOCAL));
            so.pxt = n.rotation * Vector3(0, 0, 20) + S_Game::playerRB_.linearVelocity;
            so.lifetime = 120;
            //so.b = 3;
        }
        S_Game::muzzleFlash_.brightness = mytier / 8 + float(bulletsPerShot) / 14;
        S_Game::muzzleFlash_.color = laser ? Color(0.2, 0.8, 1.0) : Color(1.0, 0.8, 0.2);
        shakey_ += laser ? 0.1 : float(bulletsPerShot) / 14;
        notsrc.frequency = timescale_ * soundPitch * 44100;
        notsrc.Play(gunSound);
        lastshot = 0;
    }

    void Jenerate(StringHash seed, float tier)
    {
        SetRandomSeed(seed.value);
        rarity = bint(RandomInt(0, 101) < 6) + bint(RandomInt(0, 101) < 6);
        back = RandomInt(0, 4);
        barrel = RandomInt(0, 6);
        handle = RandomInt(0, 6);
        mytier = tier;
        soundPitch = Random(0.9, 1.3);
        paralell = false;
        
        switch (barrel)
        {
        case 0:
            bulletsPerShot = 12.0 * tier + RandomInt(0, 4) + rarity * RandomInt(6, 10);
            rof = 0.8 + Random(0.2, 0.3 * tier);
            recoil = Random(8, 10);
            paralell = false;
            muzzVelocity = 40;
            barrelLength = 0.3;
            laser = false;
            gunSound = cache.GetResource("Sound", "Sounds/Shotgun0.ogg");
            break;
        case 1:
            if (RandomInt(0, 2) == 1)
            {
                bulletsPerShot = 1.0 + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 6.8 + Random(0, tier);
                recoil = Random(1, 6);
                muzzVelocity = 60;
                gunSound = cache.GetResource("Sound", "Sounds/Machgun0.ogg");
            } else {
                bulletsPerShot = 12.0 * tier + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 0.8 + Random(0.2, 0.3 * tier);
                recoil = Random(9, 17);
                muzzVelocity = 50;
                gunSound = cache.GetResource("Sound", "Sounds/Shotgun1.ogg");
            }
            barrelLength = 0.3;
            paralell = RandomInt(0, 2) == 1;
            laser = false;
            break;
        case 2:
            if (RandomInt(0, 2) == 1)
            {
                bulletsPerShot = 5.0 + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 18.8 + Random(0, tier);
                recoil = Random(1, 6);
                muzzVelocity = 60;
                gunSound = cache.GetResource("Sound", "Sounds/Machgun0.ogg");
            } else {
                bulletsPerShot = 26.0 * tier + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 0.2 + Random(0.2, 0.3 * tier);
                recoil = Random(15, 25);
                muzzVelocity = 50;
                gunSound = cache.GetResource("Sound", "Sounds/Shotgun2.ogg");
            }
            barrelLength = 0.3;
            paralell = RandomInt(0, 2) == 1;
            laser = false;
            break;
        case 3:
        default:
            if (RandomInt(0, 2) == 1)
            {
                bulletsPerShot = 1;
                rof = 12.8 + Random(0, tier);
                recoil = Random(1, 6);
                
                muzzVelocity = 65;
                gunSound = cache.GetResource("Sound", "Sounds/Laser0.ogg");
                paralell = false;
            } else {
                bulletsPerShot = 12;
                rof = 0.8 + Random(0.2, 0.3 * tier);
                recoil = Random(9, 17);
                muzzVelocity = 60;
                gunSound = cache.GetResource("Sound", "Sounds/Laser1.ogg");
                paralell = true;
            }
            
            laser = true;
            barrelLength = 0.3;
            paralell = RandomInt(0, 2) == 1;
            break;
        }
        damage = 100 * (tier) / bulletsPerShot / rof + rarity * 10 + recoil * 3;
        nom = generosity[rarity] + seed.ToString() + " " + (laser ? "Laser Weapon" : "Conventional Weapon");
    }
    
    void NodeApply(Node@ mchandle)
    {
        mchandle.RemoveAllComponents();
        notsrc = mchandle.CreateComponent("SoundSource");
        Material@ shinyGun = cache.GetResource("Material", "Materials/Gun" + rarity + ".xml");
        Model@ mback = cache.GetResource("Model", "Models/Back" + back + ".mdl");
        Model@ mbarrel = cache.GetResource("Model", "Models/Barrel" + barrel + ".mdl");
        Model@ mhandle = cache.GetResource("Model", "Models/Handle" + handle + ".mdl");
        Model@ mbase = cache.GetResource("Model", "Models/GunBase.mdl");
        StaticModel@ smback = mchandle.CreateComponent("StaticModel");
        StaticModel@ smbarrel = mchandle.CreateComponent("StaticModel");
        StaticModel@ smhandle = mchandle.CreateComponent("StaticModel");
        StaticModel@ smbase = mchandle.CreateComponent("StaticModel");
        smback.castShadows = true;
        smback.model = mback;
        smback.material = shinyGun;
        smbarrel.castShadows = true;
        smbarrel.model = mbarrel;
        smbarrel.material = shinyGun;
        smhandle.castShadows = true;
        smhandle.model = mhandle;
        smhandle.material = shinyGun;
        smbase.castShadows = true;
        smbase.model = mbase;
        smbase.material = shinyGun;
    }
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

Array<Gun> gunStack_;
Array<Node@> enemies_;
float accelF_ = 0;
float accelR_ = 0;
Node@ camera_;
Node@ gunThing_;
Node@ player_;
Node@ tiltme_;
Light@ muzzleFlash_;
PhysicsWorld@ physics_;
RigidBody@ playerRB_;
Room@ currentRoom_;
SoundSource@ drill_;
SoundSource@ bulletHits_;
Sound@ bulletSnd_;
Vector3 prevVel_;

void SpawnEnemy(String name, int health, int colour, Vector3 pos, Quaternion rot)
{
    Node@ enemy = scene_.InstantiateXML(cache.GetResource("XMLFile", "Objects/" + name + ".xml"), pos, rot);
    cast<StaticModel>(enemy.GetComponent("StaticModel")).material = cache.GetResource("Material", "Materials/Enemy" + colour + ".xml");
    Meat@ so = cast<Meat@>(enemy.CreateScriptObject(scriptFile, name, LOCAL));
    so.health = health;
    
    scene_.AddChild(enemy);
    enemies_.Push(enemy);
}

// Game stuff go here
void Salamander(int stats)
{
    if (stats == 1)
    {
        scene_.LoadXML(cache.GetFile("Scenes/Scene1.xml"));
        

        //RigidBody@ rb = n.CreateComponent("RigidBody");
        //rb.mass = 1.0f;
        //rb.friction = 1.0f;
        //CollisionShape@ cs = n.CreateComponent("CollisionShape");
        //cs.SetBox(Vector3::ONE);


        
        player_ = scene_.GetChild("Player");
        playerRB_ = player_.GetComponent("RigidBody");
        drill_ = player_.GetComponent("SoundSource");
        tiltme_ = player_.GetChild("TiltMe");
        camera_ = scene_.GetChild("CameraNode");
        gunThing_ = tiltme_.GetChild("GunNode");
        physics_ = scene_.GetComponent("PhysicsWorld");
        muzzleFlash_ = gunThing_.GetChild("LightThing").GetComponent("Light");

        camera_.position = player_.position + Vector3(-10, 16, -5);
        camera_.LookAt(player_.position, Vector3::UP, TS_WORLD);

        drill_.sound.looped = true;
        drill_.Play(drill_.sound);
        

        Node@ nnnnn = scene_.CreateChild("Laran");
        @currentRoom_ = Room();
        currentRoom_.Jenerate(1, 0, -1, 0.0, 0.0);
        currentRoom_.AddStuffToNode(nnnnn);

        Viewport@ viewport = Viewport(scene_, camera_.GetComponent("Camera"));
        renderer.viewports[0] = viewport;

        menuSounds_ = scene_.CreateComponent("SoundSource");
        menuSounds_.soundType = SOUND_MUSIC;
        Sound@ a = cache.GetResource("Sound", "Sounds/EFAction.ogg");
        a.looped = true;
        menuSounds_.Play(a);
        menuSounds_.frequency *= timescale_;

        bulletHits_ = scene_.CreateComponent("SoundSource");
        bulletSnd_ = cache.GetResource("Sound", "Sounds/BulletHit.wav");

        gunStack_.Resize(1);
        gunStack_[0].Jenerate(StringHash(log_), 7.0f);
        gunStack_[0].NodeApply(gunThing_);



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
        
        // Smash sound
        Vector3 deltavee(playerRB_.linearVelocity - prevVel_);
        if (deltavee.length > 2)
        {
            SoundSource@ ss = tiltme_.GetComponent("SoundSource");
            ss.Play(ss.sound);
        }
        
        playerRB_.angularVelocity = Vector3(0, accelR_, 0);
        playerRB_.linearVelocity = playerRB_.linearVelocity.Lerp(playerRB_.rotation * Vector3::FORWARD * accelF_ + Vector3(0, playerRB_.linearVelocity.y, 0), 0.5);
        prevVel_ = playerRB_.linearVelocity;
        tiltme_.rotation = tiltme_.rotation.Nlerp(Quaternion(Clamp(accelF_ * 2.0, -70.0, 70.0), 0, Clamp(-accelR_ * accelF_ * 0.8, -70.0, 70.0)), 0.2, true);
        // * ((Sign(accelF_) != Sign(mcjoy.y) && mcjoy.y != 0) ? -1 : 1)
        
        // Sound
        drill_.frequency = (44100 * timescale_) * (Abs(accelF_) / 10 + 1) * (Abs(accelR_) / 10 + 1) * 0.5;
        drill_.gain = Lerp(drill_.gain, Clamp(Abs(accelF_ / 15) + Abs(accelR_ / 20), 0, 0.7), 0.7);
    
    
        gunStack_[0].Update();
        
        if (input.keyDown[KEY_J])
        {
            gunStack_[0].Shoot();
        }
        // LOOK AT PLAYER
        camera_.position = player_.position + Vector3(-5 * zoom_, 8 * zoom_, -2.5 * zoom_);
        camera_.LookAt(player_.position, Vector3::UP, TS_WORLD);
        camera_.Rotate(Quaternion(Random(-1, 1) * shakey_, Random(-1, 1) * shakey_, 0), TS_LOCAL);
        //Print(currentRoom_.IsPlayerInside());
        zoom_ = Lerp(zoom_, currentRoom_.metype == 1 ? 1.4 : 1.0, 0.05);
        if (!currentRoom_.IsPlayerInside())
        {
            // if player is not in room
            gunStack_[0].Jenerate(StringHash(log_), 1.0f);
            gunStack_[0].NodeApply(tiltme_.GetChild("GunNode"));
            uint closest = -1;
            float smallest = 10000000;
            for (uint i = 0; i < 4; i ++)
            {
                float d = currentRoom_.DoorDist(i);
                if (d < smallest)
                {
                    closest = i;
                    smallest = d;
                }
            }
            Node@ theDoor = currentRoom_.mahnode.GetChild("Door" + closest);
            Node@ nnnnn = scene_.CreateChild("Laran");
            Vector3 dpos = theDoor.position + currentRoom_.mahnode.position;
            Print("CLOSES: " + closest);
            currentRoom_.mahnode.Remove();
            
            if (("" + log_[log_.length - 1]) != ("" + ((closest + 2) % 4))[0])
            {
                log_ += closest;
            } else {
                Print("SAME DOOR!");
                log_.Resize(log_.length - 1);
            }
            Print(log_);
            @currentRoom_ = Room();
            currentRoom_.Jenerate(bint(closest == 0) - bint(closest == 2), bint(closest == 1) - bint(closest == 3), closest, dpos.x, dpos.z);
            currentRoom_.AddStuffToNode(nnnnn);
        }
    }
}

}
