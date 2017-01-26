using UnityEngine;

namespace Doodle
{
    public class WordToWaveform : MonoBehaviour
    {
        [SerializeField] GameObject _word;
        [SerializeField] GameObject _waveform;

        [Space]
        [SerializeField, Range(0, 1)] float _parameter;

        Vector3 _wordScale;
        Vector3 _waveformScale;

        void Start()
        {
            _wordScale = _word.transform.localScale;
            _waveformScale = _waveform.transform.localScale;
        }

        void Update()
        {
            var s1 = _wordScale;
            var s2 = _waveformScale;

            s1.x *= 1 + _parameter;
            s1.y *= Mathf.Max(0, (0.4f - _parameter) / 0.4f);
            s2.y *= Mathf.Max(0, (_parameter - 0.6f) / 0.4f);

            _word.transform.localScale = s1;
            _waveform.transform.localScale = s2;

            _word.SetActive(_parameter < 0.5f);
            _waveform.SetActive(_parameter >= 0.5f);
        }
    }
}
