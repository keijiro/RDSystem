using UnityEngine;

namespace RDSystem
{
    public class RDSystemUpdater : MonoBehaviour
    {
        [SerializeField] CustomRenderTexture _texture;
        [SerializeField, Range(1, 16)] int _stepsPerFrame = 4;

        void Start()
        {
            _texture.Initialize();
        }

        void Update()
        {
            _texture.Update(_stepsPerFrame);
        }
    }
}
