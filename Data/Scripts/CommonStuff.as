funcdef void SCENEFUNCTION(int);

Array<Room> rooms_;
//Array<String> companies = {"Delikhoi", "Gotzietek", "Xokeshi Industries", "Vendoralenger", "Notcirronede", "Notkaytrav"}
Array<String> generosity = {"Fresh ", "Rare ", "Vintage $200 "};
bool ffirst_;
float delta_;
float time_ = 0;
float timescale_ = 1.0;
float shakey_ = 0;
float zoom_ = 1.0;
SCENEFUNCTION@ sceneFunc_;
Scene@ scene_;
SoundSource@ menuSounds_;
String log_ = "Coriolis Motorcycle";

void ChangeScene(SCENEFUNCTION@ to)
{
    ui.root.RemoveAllChildren();
    scene_.RemoveAllChildren();
    //ui.root.defaultStyle = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    sceneFunc_ = to;
    time_ = 0;
    ffirst_ = true;
}

void Detox(Sprite@ t, String res)
{
    t.texture = Texture2D();
    t.texture.SetNumLevels(1);
    t.texture.Load(res);
}

int bint(bool b)
{
    return b ? 1 : 0;
}
