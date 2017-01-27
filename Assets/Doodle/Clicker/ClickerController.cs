using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Doodle
{
    public class ClickerController : MonoBehaviour
    {
        #region Exposed properties

        [SerializeField] Clicker _clickerPrefab;
        [SerializeField] Bounds _scanRange = new Bounds(Vector3.zero, Vector3.one * 5);
        [SerializeField] float _scanTime = 1;

        [Space]
        [SerializeField] Clicker.Config _clickerConfig;

        #endregion

        #region Private members

        List<Clicker> _clickers;

        IEnumerator PopulateClickers()
        {
            _clickers = new List<Clicker>();

            var min = _scanRange.min;
            var max = _scanRange.max;
            var step = _clickerPrefab.transform.localScale;
            var colliders = new Collider[1];
            var time = Time.deltaTime;

            for (var z = min.z; z < max.z; z += step.z)
            {
                if (Mathf.Lerp(min.z, max.z, time / _scanTime) < z)
                {
                    yield return null;
                    time += Time.deltaTime;
                }

                for (var y = min.y; y < max.y; y += step.y)
                {
                    for (var x = min.x; x < max.x; x += step.x)
                    {
                        var p = transform.TransformPoint(new Vector3(x, y, z));
                        var r = transform.rotation;

                        var count = Physics.OverlapBoxNonAlloc(p, step * 0.5f, colliders);
                        if (count == 0) continue;

                        var cl = Instantiate(_clickerPrefab, p, r, transform);
                        cl.config = _clickerConfig;
                        _clickers.Add(cl);
                    }
                }
            }
        }

        #endregion

        #region MonoBehaviour functions

        IEnumerator Start()
        {
            yield return PopulateClickers();

            while (true)
            {
                yield return new WaitForSeconds(0.21f);

                foreach (var cl in _clickers) cl.StartNextMove();
                yield return new WaitForSeconds(0.21f);

                foreach (var cl in _clickers) cl.StartNextMove();
                yield return new WaitForSeconds(0.21f);

                foreach (var cl in _clickers) cl.Hit();
                yield return new WaitForSeconds(0.1f);

                foreach (var cl in _clickers) cl.StartNextMove();
            }
        }

        #endregion

        #region Gizmo display function

        void OnDrawGizmos()
        {
            Gizmos.matrix = transform.localToWorldMatrix;

            Gizmos.color = Color.yellow;
            Gizmos.DrawWireCube(_scanRange.center, _scanRange.extents);

            var range = _clickerConfig.bounds;
            Gizmos.color = Color.cyan;
            Gizmos.DrawWireCube(range.center, range.extents);
        }

        #endregion
    }
}
