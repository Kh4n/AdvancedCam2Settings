bool ShowWindow = false;

class Cam2Settings_V1 {
    CMwNod@ cam2Nod;
    string SETTINGS_FILE_NAME = "cam2.settings";

    Cam2Settings_V1() {}

    void Init() {
        CSystemFidsFolder@ folder = Fids::GetGameFolder("GameData/Vehicles/Cars/CarSport/Camera");
        print(folder.FullDirName);
        print(folder.Leaves[1].FileName);
        @cam2Nod = Fids::Preload(folder.Leaves[1]);

        // check sanity
        if (Dev::GetOffsetFloat(cam2Nod, FOV_OFFSET) != FOV_DEFAULT)  {
            throw("sanity check failed, could not get FOV at offset " + FOV_OFFSET);
        }
        Load();
    }

    void Save() {
        string path = IO::FromStorageFolder(SETTINGS_FILE_NAME);
        IO::File fw(path, IO::FileMode::Write);
        fw.Write(VERSION);
        fw.Write(fov);
        fw.Write(camAngle);
        fw.Write(camHeight);
        fw.Write(camDist);
        fw.Write(camStiffness);
        fw.Write(camAerialTransitionTimeMS);
        fw.Close();
    }

    void Load() {
        string path = IO::FromStorageFolder(SETTINGS_FILE_NAME);
        if (!IO::FileExists(path)) {
            Save();
        }

        IO::File fr(path, IO::FileMode::Read);
        MemoryBuffer@ mem = fr.Read(fr.Size());
        uint ver = mem.ReadUInt32();
        if (ver != VERSION) throw("expected version to be " + VERSION + ", got: " + ver);

        fov = mem.ReadFloat();
        camAngle = mem.ReadFloat();
        camHeight = mem.ReadFloat();
        camDist = mem.ReadFloat();
        camStiffness = mem.ReadFloat();
        camAerialTransitionTimeMS = mem.ReadUInt32();
        fr.Close();

        Set();
    }

    void Set() {
        Dev::SetOffset(cam2Nod, FOV_OFFSET, fov);
        Dev::SetOffset(cam2Nod, CAM_ANGLE_OFFSET, camAngle);
        Dev::SetOffset(cam2Nod, CAM_HEIGHT_OFFSET, camHeight);
        Dev::SetOffset(cam2Nod, CAM_DIST_OFFSET, camDist);
        Dev::SetOffset(cam2Nod, CAM_STIFFNESS_OFFSET, camStiffness);
        Dev::SetOffset(cam2Nod, CAM_AERIAL_TRANSITION_TIME_MS_OFFSET, camAerialTransitionTimeMS);
    }

    void DrawUI() {
        UI::SetNextItemWidth(300);
        if (UI::Button("Reset FOV")) {
            Dev::SetOffset(cam2Nod, FOV_OFFSET, FOV_DEFAULT);
        }
        fov = UI::InputFloat("FOV", Dev::GetOffsetFloat(cam2Nod, FOV_OFFSET), 0.05f);

        UI::SetNextItemWidth(300);
        if (UI::Button("Reset Angle")) {
            Dev::SetOffset(cam2Nod, CAM_ANGLE_OFFSET, CAM_ANGLE_DEFAULT);
        }
        camAngle = UI::InputFloat("Angle", Dev::GetOffsetFloat(cam2Nod, CAM_ANGLE_OFFSET), 0.05f);

        UI::SetNextItemWidth(300);
        if (UI::Button("Reset Height")) {
            Dev::SetOffset(cam2Nod, CAM_HEIGHT_OFFSET, CAM_HEIGHT_DEFAULT);
        }
        camHeight = UI::InputFloat("Height", Dev::GetOffsetFloat(cam2Nod, CAM_HEIGHT_OFFSET), 0.05f);

        UI::SetNextItemWidth(300);
        if (UI::Button("Reset Distance")) {
            Dev::SetOffset(cam2Nod, CAM_DIST_OFFSET, CAM_DIST_DEFAULT);
        }
        camDist = UI::InputFloat("Distance", Dev::GetOffsetFloat(cam2Nod, CAM_DIST_OFFSET), 0.05f);

        UI::SetNextItemWidth(300);
        if (UI::Button("Reset Stiffness")) {
            Dev::SetOffset(cam2Nod, CAM_STIFFNESS_OFFSET, CAM_STIFFNESS_DEFAULT);
        }
        camStiffness = UI::InputFloat("Stiffness", Dev::GetOffsetFloat(cam2Nod, CAM_STIFFNESS_OFFSET), 0.05f);

        UI::SetNextItemWidth(300);
        if (UI::Button("Reset Aerial Transition Time")) {
            Dev::SetOffset(cam2Nod, CAM_AERIAL_TRANSITION_TIME_MS_OFFSET, CAM_AERIAL_TRANSITION_TIME_MS_DEFAULT);
        }
        camAerialTransitionTimeMS = UI::InputInt(
            "Aerial Transition time (milliseconds)",
            Dev::GetOffsetUint32(cam2Nod, CAM_AERIAL_TRANSITION_TIME_MS_OFFSET)
        );

        Set();

        if (UI::Button("Save Settings")) {
            Save();
        }
    }

    uint VERSION = 1;

    float FOV_DEFAULT = 75.0f;
    uint FOV_OFFSET = 56;
    float fov = FOV_DEFAULT;

    float CAM_ANGLE_DEFAULT = 0.88f;
    uint CAM_ANGLE_OFFSET = 52;
    float camAngle = CAM_ANGLE_DEFAULT;

    float CAM_HEIGHT_DEFAULT = 2.2;
    uint CAM_HEIGHT_OFFSET = 76;
    float camHeight = CAM_HEIGHT_DEFAULT;

    float CAM_DIST_DEFAULT = 4.5;
    uint CAM_DIST_OFFSET = 80;
    float camDist = CAM_DIST_DEFAULT;

    float CAM_STIFFNESS_DEFAULT = 5.0f;
    uint CAM_STIFFNESS_OFFSET = 92;
    float camStiffness = CAM_STIFFNESS_DEFAULT;

    uint CAM_AERIAL_TRANSITION_TIME_MS_DEFAULT = 100;
    uint CAM_AERIAL_TRANSITION_TIME_MS_OFFSET = 124;
    uint camAerialTransitionTimeMS = CAM_AERIAL_TRANSITION_TIME_MS_DEFAULT;
}

Cam2Settings_V1 settings();

void Main() {
    settings.Init();
}

void RenderMenu() {
    if (UI::MenuItem("Advanced Cam 2 Settings")) ShowWindow = !ShowWindow;
}

void Render() {
    if (!ShowWindow) return;
    UI::SetNextWindowSize(600, 400, UI::Cond::Appearing);
    if (UI::Begin("Advanced Cam 2 Settings", ShowWindow, 0)) {
        settings.DrawUI();
    }
    UI::End();
}