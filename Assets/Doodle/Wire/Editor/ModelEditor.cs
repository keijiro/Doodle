using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using System.Linq;

namespace Doodle.Wire
{
    public static class MeshConverter
    {
        static Mesh[] SelectedMeshAssets {
            get {
                var assets = Selection.GetFiltered(typeof(Mesh), SelectionMode.Deep);
                return assets.Select(x => (Mesh)x).ToArray();
            }
        }

        [MenuItem("Assets/Doodle/Wire/Convert Mesh", true)]
        static bool ValidateAssets()
        {
            return SelectedMeshAssets.Length > 0;
        }

        [MenuItem("Assets/Doodle/Wire/Convert Mesh")]
        static void ConvertAssets()
        {
            var converted = new List<Object>();

            foreach (var source in SelectedMeshAssets)
            {
                // Destination file path.
                var dirPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(source));
                var assetPath = AssetDatabase.GenerateUniqueAssetPath(dirPath + "/Converted Model.asset");

                // Create a converted mesh asset.
                var temp = ConvertMesh(source);
                AssetDatabase.CreateAsset(temp, assetPath);

                converted.Add(temp);
            }

            // Save the generated assets.
            AssetDatabase.SaveAssets();

            // Select the generated assets.
            EditorUtility.FocusProjectWindow();
            Selection.objects = converted.ToArray();
        }

        static int IndicesToHash(int i1, int i2)
        {
            if (i1 < i2)
                return (i2 << 16) + i1;
            else
                return (i1 << 16) + i2;
        }

        static Mesh ConvertMesh(Mesh source)
        {
            var inIndices = source.GetIndices(0);
            var hashes = new HashSet<int>();

            for (var i = 0; i < inIndices.Length; i += 3)
            {
                var hash1 = IndicesToHash(inIndices[i + 0], inIndices[i + 1]);
                var hash2 = IndicesToHash(inIndices[i + 1], inIndices[i + 2]);
                var hash3 = IndicesToHash(inIndices[i + 2], inIndices[i + 0]);
                if (!hashes.Contains(hash1)) hashes.Add(hash1);
                if (!hashes.Contains(hash2)) hashes.Add(hash2);
                if (!hashes.Contains(hash3)) hashes.Add(hash3);
            }

            var outIndices = new List<int>();

            foreach (var hash in hashes)
            {
                outIndices.Add(hash & 0xffff);
                outIndices.Add(hash >> 16);
            }

            var mesh = new Mesh();
            mesh.name = source.name;
            mesh.vertices = source.vertices;
            mesh.uv = source.uv;
            mesh.subMeshCount = 1;
            mesh.SetIndices(outIndices.ToArray(), MeshTopology.Lines, 0);
            mesh.UploadMeshData(true);

            return mesh;
        }
    }
}
