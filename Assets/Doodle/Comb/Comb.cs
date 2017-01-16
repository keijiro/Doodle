using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Comb : MonoBehaviour
{
    [SerializeField] Shader _shader;

    Material _material;

    void OnDestroy()
    {
        if (Application.isPlaying)
            Destroy(_material);
        else
            DestroyImmediate(_material);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null)
        {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        var matrix = GetComponent<Camera>().cameraToWorldMatrix;
        _material.SetMatrix("_InverseView", matrix);

        Graphics.Blit(source, destination, _material);
    }
}
