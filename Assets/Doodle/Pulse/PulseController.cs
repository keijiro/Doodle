using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class PulseController : MonoBehaviour
{
    [SerializeField] Transform _origin;

    [Space]
    [SerializeField] float _gridInterval = 1;
    [SerializeField] float _gridWidth = 0.01f;
    [SerializeField] Vector2 _gridScroll;
    [SerializeField] float _gridBlink = 1;
    [SerializeField, ColorUsage(false, true, 0, 8, 0.125f, 3)] Color _gridColor = Color.white;

    [Space]
    [SerializeField] float _line1Width = 0.1f;
    [SerializeField] float _line1Speed = 10;
    [SerializeField, ColorUsage(false, true, 0, 8, 0.125f, 3)] Color _line1Color = Color.blue;

    [Space]
    [SerializeField] float _line2Width = 0.1f;
    [SerializeField] float _line2Speed = 10;
    [SerializeField, ColorUsage(false, true, 0, 8, 0.125f, 3)] Color _line2Color = Color.red;

    Vector2 _gridOffset;
    float _line1Offset;
    float _line2Offset;

    IEnumerator Start()
    {
        while (true)
        {
            yield return new WaitForSeconds(0.3f);
            _line1Offset = 0;

            yield return new WaitForSeconds(0.5f);
            _line2Offset = 0;
        }
    }

    void Update()
    {
        if (Application.isPlaying)
        {
            _gridOffset += _gridScroll * Time.deltaTime;
            _line1Offset += _line1Speed * Time.deltaTime;
            _line2Offset += _line2Speed * Time.deltaTime;
        }

        if (_origin != null)
            Shader.SetGlobalVector("_Pulse_Origin", _origin.position);

        var blink = 0.5f + 0.5f * Mathf.Cos(Time.time / _gridBlink * Mathf.PI * 2);

        Shader.SetGlobalVector("_Pulse_Grid", new Vector4(
            _gridInterval, _gridWidth, _gridOffset.x, _gridOffset.y
        ));
        Shader.SetGlobalColor("_Pulse_GridColor", _gridColor.linear * blink);

        Shader.SetGlobalVector("_Pulse_Line1", new Vector2(
            _line1Width, _line1Offset
        ));
        Shader.SetGlobalColor("_Pulse_Line1Color", _line1Color.linear);

        Shader.SetGlobalVector("_Pulse_Line2", new Vector2(
            _line2Width, _line2Offset
        ));
        Shader.SetGlobalColor("_Pulse_Line2Color", _line2Color.linear);
    }
}
