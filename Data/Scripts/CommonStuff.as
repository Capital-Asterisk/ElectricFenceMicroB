funcdef void SCENEFUNCTION(int);

Scene@ scene_;
SoundSource@ menuSounds_;
SCENEFUNCTION@ sceneFunc_;
String log_ = "Coriolis Motorcyc";
Array<Room> rooms_;
bool ffirst_;
float delta_;
float time_ = 0;
float timescale_ = 1.0;


void ChangeScene(SCENEFUNCTION@ to)
{
    ui.root.RemoveAllChildren();
    scene_.RemoveAllChildren();
    //ui.root.defaultStyle = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    sceneFunc_ = to;
    time_ = 0;
    ffirst_ = true;
}

int bint(bool b)
{
    return b ? 1 : 0;
}
