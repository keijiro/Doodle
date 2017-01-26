using UnityEngine;

namespace Doodle
{
    public class Clicker : MonoBehaviour
    {
        #region Exposed properties

        [SerializeField] float _speed = 1;

        public Bounds bounds { get; set; }

        #endregion

        #region Public methods

        public void StartNextMove()
        {
            _currentPosition = _nextPosition;
            _currentRotation = _nextRotation;
            _time01 = 0;
            ChooseNext();
        }

        public void Hit()
        {
            _distortion = 8;
        }

        #endregion

        #region Private members

        Vector3 _currentPosition;
        Vector3 _nextPosition;

        Quaternion _currentRotation;
        Quaternion _nextRotation;

        float _distortion;
        float _time01;

        void ChooseNext()
        {
            var dir = Random.Range(0, 6);

            var x = _currentPosition.x;
            var y = _currentPosition.y;
            var z = _currentPosition.z;

            var dx = (dir == 0 ? -1 : (dir == 1 ? 1 : 0));
            var dy = (dir == 2 ? -1 : (dir == 3 ? 1 : 0));
            var dz = (dir == 4 ? -1 : (dir == 5 ? 1 : 0));

            var bmin = bounds.min;
            var bmax = bounds.max;

            if (x + dx < bmin.x || x + dx >= bmax.x) dx *= -1;
            if (y + dy < bmin.y || y + dy >= bmax.y) dy *= -1;
            if (z + dz < bmin.z || z + dz >= bmax.z) dz *= -1;

            _nextPosition = _currentPosition + new Vector3(dx, dy, dz);

            _nextRotation =
                Quaternion.AngleAxis(dx * 90, -Vector3.up) *
                Quaternion.AngleAxis(dy * 90, Vector3.right) *
                Quaternion.AngleAxis(dz * 90, Vector3.forward) *
                _currentRotation;
        }

        #endregion

        #region MonoBehaviour functions

        void Start()
        {
            _currentPosition = transform.localPosition;
            _currentRotation = transform.localRotation;
            ChooseNext();
        }

        void Update()
        {
            _distortion *= Mathf.Exp(-16.0f * Time.deltaTime);

            _time01 = Mathf.Clamp01(_time01 + Time.deltaTime * _speed);
            transform.localPosition = Vector3.Lerp(_currentPosition, _nextPosition, _time01);
            transform.localRotation = Quaternion.Lerp(_currentRotation, _nextRotation, _time01);
            transform.localScale = new Vector3(1 + _distortion, 1 / (1 + _distortion), 1 / (1 + _distortion));
        }

        #endregion
    }
}
