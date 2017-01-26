using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Doodle
{
    public class ClickerController : MonoBehaviour
    {
        #region Exposed properties

        [SerializeField] Clicker _template;
        [SerializeField] int _instanceCount = 10;
        [SerializeField] Bounds _bounds = new Bounds(Vector3.zero, Vector3.one * 10);

        #endregion

        #region Private members

        List<Clicker> _clickers;

        #endregion

        #region MonoBehaviour functions

        IEnumerator Start()
        {
            _clickers = new List<Clicker>();

            var bmin = _bounds.min;
            var bmax = _bounds.max;

            for (var i = 0; i < _instanceCount; i++)
            {
                var x = Mathf.Floor(Random.Range(bmin.x, bmax.x));
                var y = Mathf.Floor(Random.Range(bmin.y, bmax.y));
                var z = Mathf.Floor(Random.Range(bmin.z, bmax.z));
                var p = transform.TransformPoint(new Vector3(x, y, z));
                var r = transform.rotation;
                var cl = Instantiate(_template, p, r, transform);
                cl.bounds = _bounds;
                _clickers.Add(cl);
            }

            _clickers.Add(_template);

            while (true)
            {
                yield return new WaitForSeconds(0.3f);

                foreach (var cl in _clickers) cl.StartNextMove();
                yield return new WaitForSeconds(0.3f);

                foreach (var cl in _clickers) cl.StartNextMove();
                yield return new WaitForSeconds(0.3f);

                foreach (var cl in _clickers) cl.Hit();
                yield return new WaitForSeconds(0.1f);

                foreach (var cl in _clickers) cl.StartNextMove();
            }
        }

        #endregion
    }
}
