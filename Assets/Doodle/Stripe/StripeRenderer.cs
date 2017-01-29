using UnityEngine;
using System.Collections.Generic;
using Klak.Chromatics;

namespace Doodle
{
    public class StripeRenderer : MonoBehaviour
    {
        [SerializeField] Vector2 _stripSize = Vector2.one * 0.01f;
        [SerializeField] float _scrollSpeed = 1;
        [SerializeField] Vector3 _distribution = new Vector3(5, 5, 1);
        [SerializeField] CosineGradient _gradient;

        #region Private fields

        [SerializeField, HideInInspector] Shader _shader;

        Mesh _mesh;
        Material _material;

        #endregion

        #region MonoBehaviour

        void Start()
        {
            _mesh = BuildBulkMesh();
            _material = new Material(_shader);
        }

        void Update()
        {
            _material.SetVector("_StripSize", _stripSize);
            _material.SetFloat("_ScrollSpeed", _scrollSpeed / _distribution.y);
            _material.SetVector("_Distribution", _distribution);
            _material.SetVector("_GradientA", _gradient.coeffsA);
            _material.SetVector("_GradientB", _gradient.coeffsB);
            _material.SetVector("_GradientC", _gradient.coeffsC2);
            _material.SetVector("_GradientD", _gradient.coeffsD2);

            Graphics.DrawMesh(
                _mesh, transform.localToWorldMatrix, _material, gameObject.layer
            );
        }

        #endregion

        #region Mesh builder

        Mesh BuildBulkMesh()
        {
            var vertices = new List<Vector3>();

            for (var i = 0; vertices.Count < 65536 - 4; i++)
            {
                vertices.Add(new Vector3(0, 0, i));
                vertices.Add(new Vector3(1, 0, i));
                vertices.Add(new Vector3(0, 1, i));
                vertices.Add(new Vector3(1, 1, i));
            }

            var indices = new List<int>();

            for (var i = 0; i < vertices.Count; i += 4)
            {
                indices.Add(i);
                indices.Add(i + 1);
                indices.Add(i + 2);

                indices.Add(i + 2);
                indices.Add(i + 1);
                indices.Add(i + 3);
            }

            var mesh = new Mesh();
            mesh.SetVertices(vertices);
            mesh.SetIndices(indices.ToArray(), MeshTopology.Triangles, 0);
            mesh.UploadMeshData(true);

            return mesh;
        }

        #endregion
    }
}
