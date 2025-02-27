using UnityEditor;
using System.IO;
using UnityEngine;

public class ExportiOS
{
    [MenuItem("Tools/Export iOS Project")]
    public static void Export()
    {
        // Đường dẫn xuất ra (cần giống với biến EXPORT_PATH trong shell script)
        string exportPath = "../unity_ios_build";

        // Nếu thư mục đã tồn tại, xóa để tránh lỗi
        if (Directory.Exists(exportPath))
        {
            Directory.Delete(exportPath, true);
        }
        Directory.CreateDirectory(exportPath);

        Debug.Log("🔹 Exporting iOS project to: " + exportPath);

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
        {
            scenes = new string[] { "Assets/Scenes/SampleScene.unity" }, // Cập nhật theo scene của bạn
            locationPathName = exportPath,
            target = BuildTarget.iOS,
            options = BuildOptions.None
        };

        // Thực hiện export
        BuildPipeline.BuildPlayer(buildPlayerOptions);
        Debug.Log("✅ Export iOS Project thành công! Thư mục: " + exportPath);
    }
}
