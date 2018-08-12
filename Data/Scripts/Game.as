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

    float health;

    Meat()
    {
        Print("enemy was made");
    }



}

class BoxCaterpillar : Meat
{
    int randoms;
    int deathAnimation = 40;
    
    BoxCaterpillar()
    {
        randoms = RandomInt(0, 360);
    }
    
    void DelayedStart()
    {
        SubscribeToEvent(node, "NodeCollision", "HandleNodeCollision");
    }
    
    void HandleNodeCollision(StringHash evtType, VariantMap& evtData)
    {
        Node@ smashed = evtData["OtherNode"].GetPtr();
        if (smashed is S_Game::player_)
        {
            S_Game::integrity_ -= 0.02;
            cast<RigidBody>(node.GetComponent("RigidBody")).ApplyImpulse(node.rotation * Vector3::BACK);
        }
    }
    
    void FixedUpdate(float data)
    {
        
        if (health <= 0)
        {
            deathAnimation --;
            if (deathAnimation == 39)
            {
                node.RemoveComponent("RigidBody");
                node.RemoveComponent("StaticModel");
                cast<SoundSource>(node.GetComponent("SoundSource")).Play(cache.GetResource("Sound", "Sounds/EnemyExplode.ogg"));
                cast<ParticleEmitter>(node.GetComponent("ParticleEmitter")).emitting = true;
            } else if (deathAnimation == 0)
            {
                node.Remove();
            }
            
        } else {
            node.LookAt(S_Game::player_.position, Vector3::UP, TS_WORLD);
            cast<RigidBody>(node.GetComponent("RigidBody")).ApplyForce(node.rotation * Vector3::FORWARD * 0.5);
            node.position = Vector3(node.position.x, 0.5, node.position.z);
            node.rotation = Quaternion(0, node.rotation.yaw, Sin(time_ * 180 + randoms) * 30.0);
        }
    }
}

class Barriochop : Meat
{
    int randoms;
    int deathAnimation = 40;
    
    Barriochop()
    {
        randoms = RandomInt(0, 360);
    }
    
    void DelayedStart()
    {
        SubscribeToEvent(node, "NodeCollision", "HandleNodeCollision");
    }
    
    void HandleNodeCollision(StringHash evtType, VariantMap& evtData)
    {
        Node@ smashed = evtData["OtherNode"].GetPtr();
        if (smashed is S_Game::player_)
        {
            S_Game::integrity_ -= 0.01;
            //cast<RigidBody>(S_Game::player_.GetComponent("RigidBody")).ApplyImpulse(node.rotation * Vector3::BACK);
        }
    }
    
    void FixedUpdate(float data)
    {
        
        if (health <= 0)
        {
            deathAnimation --;
            if (deathAnimation == 39)
            {
                node.RemoveComponent("RigidBody");
                node.RemoveComponent("StaticModel");
                cast<SoundSource>(node.GetComponent("SoundSource")).Play(cache.GetResource("Sound", "Sounds/EnemyExplode.ogg"));
                cast<ParticleEmitter>(node.GetComponent("ParticleEmitter")).emitting = true;
            } else if (deathAnimation == 0)
            {
                node.Remove();
            }
            
        } else {
            
        }
    }
}

class Generator : Meat
{
    int randoms;
    int deathAnimation = 40;
    
    Generator()
    {
        randoms = RandomInt(0, 360);
    }
    
    void FixedUpdate(float data)
    {
        
        if (health <= 0)
        {
            deathAnimation --;
            if (deathAnimation == 39)
            {
                node.RemoveComponent("RigidBody");
                node.RemoveComponent("StaticModel");
                cast<SoundSource>(node.GetComponent("SoundSource")).Play(cache.GetResource("Sound", "Sounds/EnemyExplode.ogg"));
                cast<ParticleEmitter>(node.GetComponent("ParticleEmitter")).emitting = true;
            } else if (deathAnimation == 0)
            {
               
                
                S_Game::currentRoom_.DoorLock(false);
                S_Game::gameHUD_.GetChild("Minimap").GetChild(S_Game::currentTarget_.name).Remove();
                S_Game::currentTarget_.Remove();
                if (scene_.GetChild("Targets").GetChildren().length == 0)
                {
                    ChangeScene(WinFunc);
                }
                @S_Game::currentTarget_ = @(scene_.GetChild("Targets").GetChildren()[0]);
                
                
                
                S_Game::barrierSize_ = (node.position - S_Game::currentTarget_.position).length + 300;
                
                node.Remove();
            }
            
        } else {
            //node.LookAt(S_Game::player_.position, Vector3::UP, TS_WORLD);
            //cast<RigidBody>(node.GetComponent("RigidBody")).ApplyForce(node.rotation * Vector3::FORWARD);
            //node.position = Vector3(node.position.x, 0.5, node.position.z);
            //node.rotation = Quaternion(0, node.rotation.yaw, Sin(time_ * 180 + randoms) * 30.0);
        }
    }
}

// nothing roblox related
class BSMBullet : ScriptObject
{
//    PhysicsWorld@ physics;
    Vector3 pxt;
    String tgt;
    uint lifetime = 60;
    float damage;

    BSMBullet()
    {
        //Print("bsm was made");
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
            } else if (boom.name.StartsWith("Enemy"))
            {
                lifetime = 0;
                
                S_Game::bulletHits_.Play(S_Game::bulletHitmarker_);
                S_Game::bulletHits_.frequency = 44100;
                Meat@ m = cast<Meat@>(boom.GetScriptObject());
                m.health -= damage;
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
    int doorlink, wid, hei, metype, enemyCount;
    uint birbseeds;
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
    
    void DoorLock(bool lock)
    {
        for (int i = 0; i < 4; i ++)
        {
            if (doors[i] != -1)
            {
                cast<CollisionShape>(mahnode.GetChild("Door" + i).GetComponents()[3]).position = Vector3(0, 2 * bint(!lock), 0);
            }
        }
    }
    void DoorEnemySpawn()
    {
        for (int i = 0; i < 4; i ++)
        {
            if (doors[i] != -1 && i != (doorlink + 2) % 4 && metype != 1 && RandomInt(0, 2) == 0)
            {
                Node@ door = mahnode.GetChild("Door" + i);
                S_Game::SpawnEnemy("Barriochop", 300, 0, mahnode.position + door.position + door.rotation * Vector3(0, -0.2, -2), door.rotation * Quaternion(0, 180, 0));
            }
        }
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
        birbseeds = hash.value;
        SetRandomSeed(hash.value);
        blackFloor = (RandomInt(0, 11) <= 2); // 20% chance of black floor
        metype = RandomInt(0, 3);
        switch (metype)
        {
        case 0:
            // small boia
            wid = RandomInt(6, 10);
            hei = RandomInt(6, 10);
            enemyCount = RandomInt(0, wid * hei * 0.1);
            break;
        case 1:
            // big boi
            wid = RandomInt(12, 32);
            hei = RandomInt(12, 32);
            enemyCount = RandomInt(0, wid * hei * 0.1);
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
        
        
        DoorEnemySpawn();
        if ((S_Game::currentTarget_.position - mahnode.position).length < 40)
        {
            DoorLock(true);
            S_Game::SpawnEnemy("Generator", 1000, 0, mahnode.position, Quaternion(0, 0, 0));
        }
        
        // Stuff spawning
        switch (metype) {
        case 0:
            
            for (uint i = 0; i < enemyCount ; i ++)
            {
                S_Game::SpawnEnemy("BoxCaterpillar", 40, 0, mahnode.position + Vector3(RandomInt(-3, 3), 0, RandomInt(-3, 3)), Quaternion(0, 0, 0));
            }
            break;
        case 1:
            
            for (uint i = 0; i < enemyCount ; i ++)
            {
                S_Game::SpawnEnemy("BoxCaterpillar", 40, 0, mahnode.position + Vector3(RandomInt(-wid / 2, wid / 2), 0, RandomInt(-hei / 2, hei / 2)), Quaternion(0, 0, 0));
            }
            break;
        
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
            so.damage = damage;
            //so.b = 3;
        }
        Print("DamagePerShot: " + damage);
        S_Game::muzzleFlash_.brightness = mytier / 8 + float(bulletsPerShot) / 14;
        S_Game::muzzleFlash_.color = laser ? Color(0.2, 0.8, 1.0) : Color(1.0, 0.8, 0.2);
        shakey_ += laser ? 0.1 : float(bulletsPerShot) / 14;
        notsrc.frequency = timescale_ * soundPitch * 44100;
        notsrc.Play(gunSound);
        lastshot = 0;
    }

    void Default()
    {
        rarity = 0;
        back = 0;
        barrel = 0;
        handle = 0;
        mytier = 1;
        soundPitch = 1.4;
        paralell = false;
        bulletsPerShot = 1;
        rof = 15;
        recoil = 3;
        muzzVelocity = 60;
        gunSound = cache.GetResource("Sound", "Sounds/Machgun0.ogg");
        damage = 100 / bulletsPerShot / rof + rarity * 10;
        nom = "Gotzietek LD42 Autorifle";
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
        String techType;
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
            techType = "Auto Double Shotgun";
            break;
        case 1:
            if (RandomInt(0, 2) == 1)
            {
                bulletsPerShot = 1.0 + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 6.8 + Random(0, tier);
                recoil = Random(1, 6);
                muzzVelocity = 60;
                gunSound = cache.GetResource("Sound", "Sounds/Machgun0.ogg");
                techType = "Multi Machinegun";
            } else {
                bulletsPerShot = 12.0 * tier + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 0.8 + Random(0.2, 0.3 * tier);
                recoil = Random(9, 17);
                muzzVelocity = 50;
                gunSound = cache.GetResource("Sound", "Sounds/Shotgun1.ogg");
                techType = "Auto Triple Shotgun";
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
                techType = "Machine Shotgun";
            } else {
                bulletsPerShot = 26.0 * tier + RandomInt(0, 4) + rarity * RandomInt(6, 10);
                rof = 0.2 + Random(0.2, 0.3 * tier);
                recoil = Random(15, 25);
                muzzVelocity = 50;
                gunSound = cache.GetResource("Sound", "Sounds/Shotgun2.ogg");
                techType = "9 Barrel Shotgun";
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
                techType = "Laser Assault Rifle";
            } else {
                bulletsPerShot = 12;
                rof = 0.8 + Random(0.2, 0.3 * tier);
                recoil = Random(9, 17);
                muzzVelocity = 60;
                gunSound = cache.GetResource("Sound", "Sounds/Laser1.ogg");
                paralell = true;
                techType = "Big Thing";
            }
            
            laser = true;
            barrelLength = 0.3;
            paralell = RandomInt(0, 2) == 1;
            break;
        }
        damage = 100 * (tier) / bulletsPerShot / rof + rarity * 10;
        nom = generosity[rarity] + "Model " + seed.ToString() + " " + techType;
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
        log_ = "Coriolis Motorcycle";
        
        UIElement@ menuUI = ui.LoadLayout(cache.GetResource("XMLFile", "UI/Menu.xml"));
        menuUI.SetSize(1280, 720);
        menuUI.SetPosition((graphics.width - menuUI.width) / 2, (graphics.height - menuUI.height) / 2);
        Detox(cast<Sprite>(menuUI.GetChild("Logo")), "Data/Textures/MenuLogo.png");
        
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
float barrierSize_ = 600;
float barrierRate_ = 2;
float integrity_ = 1;
Gun@ currentGun_;
Light@ muzzleFlash_;
Node@ camera_;
Node@ gunThing_;
Node@ player_;
Node@ tiltme_;
Node@ currentTarget_;
PhysicsWorld@ physics_;
RigidBody@ playerRB_;
Room@ currentRoom_;
Sound@ bulletHitmarker_;
Sound@ bulletSnd_;
SoundSource@ bulletHits_;
SoundSource@ drill_;
Sprite@ barrier_;
Sprite@ healthBar_;
Sprite@ gameHUD_;
UIElement@ minimapGuy_;
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
        accelF_ = 0;
        accelR_ = 0;
        barrierSize_ = 600;
        barrierRate_ = 2;
        integrity_ = 1;
        
        
        scene_.LoadXML(cache.GetFile("Scenes/Scene1.xml"));
        

        //RigidBody@ rb = n.CreateComponent("RigidBody");
        //rb.mass = 1.0f;
        //rb.friction = 1.0f;
        //CollisionShape@ cs = n.CreateComponent("CollisionShape");
        //cs.SetBox(Vector3::ONE);
        currentTarget_ = scene_.GetChild("Targets").GetChild("0");

        gameHUD_ = ui.LoadLayout(cache.GetResource("XMLFile", "UI/GameUI.xml"));
        gameHUD_.SetSize(1280, 720);
        gameHUD_.SetPosition((graphics.width - gameHUD_.width) / 2, (graphics.height - gameHUD_.height) / 2);
        gameHUD_.texture = Texture2D();
        gameHUD_.texture.SetNumLevels(1);
        gameHUD_.texture.Load("Data/Textures/GameUI.png");
        barrier_ = gameHUD_.GetChild("Minimap").GetChild("Circle");
        healthBar_ = gameHUD_.GetChild("HealthBar");
        ui.root.AddChild(gameHUD_);
        
        minimapGuy_ = gameHUD_.GetChild("Minimap").GetChild("You");
        
        player_ = scene_.GetChild("Player");
        playerRB_ = player_.GetComponent("RigidBody");
        drill_ = player_.GetComponent("SoundSource");
        tiltme_ = player_.GetChild("TiltMe");
        camera_ = scene_.GetChild("CameraNode");
        gunThing_ = tiltme_.GetChild("GunNode");
        physics_ = scene_.GetComponent("PhysicsWorld");
        muzzleFlash_ = gunThing_.GetChild("LightThing").GetComponent("Light");

        camera_.position = player_.position + Vector3(-5, 16, -10);
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
        bulletHitmarker_ = cache.GetResource("Sound", "Sounds/hitmarker.ogg");

        gunStack_.Resize(1);
        @currentGun_ = @gunStack_[0];
        //currentGun_.Jenerate(StringHash(log_), 7.0f);
        currentGun_.NodeApply(gunThing_);
        currentGun_.Default();
        cast<Text>(gameHUD_.GetChild("GunName")).text = currentGun_.nom + " [Lvl. " + int(currentGun_.mytier * 20 - 19) + "]";

    } else {
        //Print(RandomInt(11, 124));
        // Player code becuase i'm lazy
        
        if (integrity_ <= 0)
        {
            if (player_.HasComponent("RigidBody"))
            {
                playerRB_.Remove();
                tiltme_.Remove();
                cast<ParticleEmitter>(player_.GetComponent("ParticleEmitter")).emitting = true;
                menuSounds_.frequency = 44100 * 0.5;
                menuSounds_.gain = 1;
                menuSounds_.Play(cache.GetResource("Sound", "Sounds/EnemyExplode.ogg"));
                integrity_ = 0;
            }
            integrity_ -= delta_;
            
            if (integrity_ <= -2)
            {
                ChangeScene(S_Menu::Salamander);
            }
            return;
        }
        
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
        camera_.position = player_.position + Vector3(2.5 * zoom_, 8 * zoom_, -5 * zoom_);
        camera_.LookAt(player_.position, Vector3::UP, TS_WORLD);
        camera_.Rotate(Quaternion(Random(-1, 1) * shakey_, Random(-1, 1) * shakey_, 0), TS_LOCAL);
        
        // Update HUD
        minimapGuy_.position = IntVector2(player_.position.x * 0.2, -player_.position.z * 0.2);
        barrier_.size = IntVector2(barrierSize_ * 2 * 0.2, barrierSize_ * 2 * 0.2);
        barrierSize_ -= delta_ * barrierRate_;
        barrier_.SetPosition(currentTarget_.position.x * 0.2 - barrier_.size.x / 2, -currentTarget_.position.z * 0.2 - barrier_.size.y / 2);
        healthBar_.SetSize(integrity_ * 377.0, 33);
        healthBar_.color = Color(0.5 - integrity_ * 0.5, integrity_ * 0.5, 0);
        integrity_ = Min(1.0, integrity_ + delta_ * 0.01);
        if (barrierSize_ < (player_.position - currentTarget_.position).length)
        {
            integrity_ -= delta_ * 5;
        }

        //Print(currentRoom_.IsPlayerInside());
        zoom_ = Lerp(zoom_, currentRoom_.metype == 1 ? 1.4 : 1.0, 0.05);
        if (!currentRoom_.IsPlayerInside())
        {
            // if player is not in room
            currentGun_.Jenerate(StringHash(log_), 1.0f + float(log_.length - 15) / 20);
            currentGun_.NodeApply(tiltme_.GetChild("GunNode"));
            cast<Text>(gameHUD_.GetChild("GunName")).text = currentGun_.nom + " [Lvl. " + int(currentGun_.mytier * 20 - 19) + "]";
            cast<Text>(gameHUD_.GetChild("Depth")).text = log_.length - 17;
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
            
            for (uint i = 0; i < enemies_.length; i ++)
            {
                enemies_[i].Remove();
            }
            enemies_.Clear();
            
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

void WinFunc(int stats)
{
    if (stats == 1)
    {
        UIElement@ menuUI = ui.LoadLayout(cache.GetResource("XMLFile", "UI/YouWin.xml"));
        ui.root.AddChild(menuUI);
    } else {

    }
    //Print(RandomInt(11, 124));
}
