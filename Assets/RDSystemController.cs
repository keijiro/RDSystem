using UnityEngine;

public class RDSystemController : MonoBehaviour
{
    [SerializeField] CustomRenderTexture _target;
    [SerializeField, Range(1, 10)] int _stepCount = 4;

    void Start()
    {
        _target.Initialize();
    }

    void Update()
    {
        _target.Update(_stepCount);
    }
}
