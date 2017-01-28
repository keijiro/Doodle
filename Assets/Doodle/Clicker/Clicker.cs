using UnityEngine;
using Klak.Chromatics;

namespace Doodle
{
    public class Clicker : MonoBehaviour
    {
        #region Configuration

        [System.Serializable]
        public class Config
        {
            public AnimationCurve spawnAnimation = AnimationCurve.Linear(0, 0, 1, 1);
            public AnimationCurve moveAnimation = AnimationCurve.Linear(0, 0, 1, 1);
            public AnimationCurve hitAnimation = AnimationCurve.Linear(0, 1, 1, 0);
            public Bounds bounds = new Bounds(Vector3.zero, Vector3.one * 10);
            public CosineGradient gradient;
            public float gradientFrequency = 1;
        }

        public Config config { get; set; }

        #endregion

        #region Public methods

        public void StartNextMove()
        {
            _currentPosition = _nextPosition;
            _currentRotation = _nextRotation;
            _moveTime = 0;
            ChooseNext();
        }

        public void Hit()
        {
            _hitTime = 0;
        }

        #endregion

        #region Private members

        Renderer _renderer;

        Vector3 _currentPosition;
        Vector3 _nextPosition;

        Quaternion _currentRotation;
        Quaternion _nextRotation;

        Vector3 _originalScale;

        float _spawnTime;
        float _moveTime;
        float _hitTime;

        void ChooseNext()
        {
            var dir = Random.Range(0, 6);

            var x = _currentPosition.x;
            var y = _currentPosition.y;
            var z = _currentPosition.z;

            var i = (dir == 0 ? -1 : (dir == 1 ? 1 : 0));
            var j = (dir == 2 ? -1 : (dir == 3 ? 1 : 0));
            var k = (dir == 4 ? -1 : (dir == 5 ? 1 : 0));

            var dx = i * _originalScale.x;
            var dy = j * _originalScale.y;
            var dz = k * _originalScale.z;

            var bmin = config.bounds.min;
            var bmax = config.bounds.max;

            if (x + dx < bmin.x || x + dx >= bmax.x) { i = -i; dx = -dx; }
            if (y + dy < bmin.y || y + dy >= bmax.y) { j = -j; dy = -dy; }
            if (z + dz < bmin.z || z + dz >= bmax.z) { k = -k; dz = -dz; }

            _nextPosition = _currentPosition + new Vector3(dx, dy, dz);

            _nextRotation =
                Quaternion.AngleAxis(i * 90, -Vector3.up) *
                Quaternion.AngleAxis(j * 90, Vector3.right) *
                Quaternion.AngleAxis(k * 90, Vector3.forward) *
                _currentRotation;
        }

        #endregion

        #region MonoBehaviour functions

        void Start()
        {
            _renderer = GetComponent<Renderer>();

            _nextPosition = transform.localPosition;
            _nextRotation = transform.localRotation;

            _originalScale = transform.localScale;
            transform.localScale = Vector3.zero;

            _spawnTime = 0;
            _moveTime = 1e+6f;
            _hitTime = 1e+6f;
        }

        void Update()
        {
            _spawnTime += Time.deltaTime;
            _moveTime += Time.deltaTime;
            _hitTime += Time.deltaTime;

            var spawn = config.spawnAnimation.Evaluate(_spawnTime);
            var move = config.moveAnimation.Evaluate(_moveTime);
            var hit = config.hitAnimation.Evaluate(_hitTime);

            transform.localPosition = Vector3.Lerp(_currentPosition, _nextPosition, move);
            transform.localRotation = Quaternion.Lerp(_currentRotation, _nextRotation, move);

            var rcphit = 1 / (1 + hit);
            var scale = new Vector3(1 + hit, rcphit, rcphit) * spawn;
            transform.localScale = Vector3.Scale(_originalScale, scale);

            var param = config.gradientFrequency * transform.localPosition.magnitude;
            _renderer.material.color = config.gradient.Evaluate(param);
        }

        #endregion
    }
}
