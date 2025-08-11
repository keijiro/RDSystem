using UnityEngine;

namespace RDSystem {

public sealed class RDSystemUpdater : MonoBehaviour
{
    [SerializeField] CustomRenderTexture _texture = null;
    [SerializeField, Range(1, 16)] int _stepsPerFrame = 4;

    void Start()
      => _texture.Initialize();

    void Update()
      => _texture.Update(_stepsPerFrame);
}

} // namespace RDSystem
