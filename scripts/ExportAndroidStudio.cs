using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using System.IO;
using System.Linq;

public class ExportAndroidStudio
{
    [MenuItem("Tools/Export Android Studio Project")]
    public static void Export()
    {
        Debug.Log("🔄 Bắt đầu export dự án sang Android Studio...");
        try
        {
            // Lấy đường dẫn xuất từ command-line arguments (mặc định nếu không có đối số)
            string exportPath = "Builds/Android";
            string[] args = System.Environment.GetCommandLineArgs();
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == "-exportPath" && i + 1 < args.Length)
                {
                    exportPath = args[i + 1];
                    break;
                }
            }
            Debug.Log($"📂 Đường dẫn xuất: {exportPath}");

            // Xóa thư mục build cũ nếu có và tạo lại thư mục mới
            if (Directory.Exists(exportPath))
            {
                Debug.Log("🗑 Xóa thư mục build cũ...");
                Directory.Delete(exportPath, true);
            }
            Directory.CreateDirectory(exportPath);

            // Chuyển nền tảng sang Android
            Debug.Log("🔄 Chuyển nền tảng sang Android...");
            if (!EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android))
            {
                Debug.LogError("❌ Không thể chuyển nền tảng sang Android!");
                return;
            }

            // Bật tùy chọn Export as Google Android Project
            Debug.Log("✅ Bật tùy chọn Export as Google Android Project...");
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;

            // Lấy danh sách các scene được bật trong Build Settings
            string[] scenes = EditorBuildSettings.scenes
                .Where(scene => scene.enabled)
                .Select(scene => scene.path)
                .ToArray();

            if (scenes.Length == 0)
            {
                Debug.LogError("❌ Không có scene nào được thêm vào Build Settings!");
                return;
            }

            // Cấu hình build
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = exportPath,
                target = BuildTarget.Android,
                options = BuildOptions.AcceptExternalModificationsToPlayer
            };

            Debug.Log("🚀 Bắt đầu build...");
            BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            BuildSummary summary = report.summary;
            if (summary.result == BuildResult.Succeeded)
            {
                Debug.Log($"🎉 Export Android Studio Project thành công! 📂 {exportPath}");
            }
            else
            {
                Debug.LogError($"❌ Build thất bại! Lỗi: {summary.result}");
            }
        }
        catch (System.Exception e)
        {
            Debug.LogError("❌ Lỗi khi export dự án: " + e.ToString());
        }
    }
}
