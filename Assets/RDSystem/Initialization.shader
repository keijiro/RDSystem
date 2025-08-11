Shader "RDSystem/Initialization"
{
    Properties
    {
        _Pop("Population", Range(0, 1)) = 0.1
        _Seed("Random Seed", Integer) = 1234
    }

    HLSLINCLUDE

    #include "CustomRenderTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Random.hlsl"

    float _Pop;
    uint _Seed;

    half4 frag(v2f_init_customrendertexture i) : SV_Target
    {
        uint x = i.texcoord.x * _CustomRenderTextureWidth;
        uint y = i.texcoord.y * _CustomRenderTextureHeight;
        float rnd = GenerateHashedRandomFloat(uint3(x, y, _Seed));
        return half4(1, rnd < _Pop * _Pop * 0.01, 0, 0);
    }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "Init"
            HLSLPROGRAM
            #pragma vertex InitCustomRenderTextureVertexShader
            #pragma fragment frag
            ENDHLSL
        }
    }
}
