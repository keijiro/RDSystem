Shader "RDSystem/RDSystem"
{
    Properties
    {
        [Header(Initialization), Space]
        [Space]
        _Pop("Population", Range(0, 1)) = 0.1
        _Seed("Random Seed", Integer) = 1234
        
        [Header(Reaction Diffusion)]
        [Space]
        _Du("Diffusion (u)", Range(0, 1)) = 1
        _Dv("Diffusion (v)", Range(0, 1)) = 0.4
        _Feed("Feed", Range(0, 0.1)) = 0.05
        _Kill("Kill", Range(0, 0.1)) = 0.05
    }

    HLSLINCLUDE

    #include "CustomRenderTexture.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Random.hlsl"

    // Initialization parameters
    float _Pop;
    uint _Seed;
    
    // Update parameters
    half _Du, _Dv;
    half _Feed, _Kill;

    // Pass 0: Init
    half4 fragInit(InitCustomRenderTextureVaryings i) : SV_Target
    {
        uint x = i.texcoord.x * _CustomRenderTextureWidth;
        uint y = i.texcoord.y * _CustomRenderTextureHeight;
        float rnd = GenerateHashedRandomFloat(uint3(x, y, _Seed));
        return half4(1, rnd < _Pop * _Pop * 0.01, 0, 0);
    }

    // Pass 1: Update
    half4 fragUpdate(CustomRenderTextureVaryings i) : SV_Target
    {
        float tw = 1 / _CustomRenderTextureWidth;
        float th = 1 / _CustomRenderTextureHeight;

        float2 uv = i.globalTexcoord.xy;
        float4 duv = float4(tw, th, -tw, 0);

        half2 q = SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv).xy;

        half2 dq = -q;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv - duv.xy).xy * 0.05;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv - duv.wy).xy * 0.20;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv - duv.zy).xy * 0.05;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv + duv.zw).xy * 0.20;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv + duv.xw).xy * 0.20;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv + duv.zy).xy * 0.05;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv + duv.wy).xy * 0.20;
        dq += SAMPLE_TEXTURE2D(_SelfTexture2D, sampler_SelfTexture2D, uv + duv.xy).xy * 0.05;

        half ABB = q.x * q.y * q.y;

        q += float2(dq.x * _Du - ABB + _Feed * (1 - q.x),
                    dq.y * _Dv + ABB - (_Kill + _Feed) * q.y);

        return half4(saturate(q), 0, 0);
    }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        
        // Pass 0: Init
        Pass
        {
            Name "Init"
            HLSLPROGRAM
            #pragma vertex InitCustomRenderTextureVertexShader
            #pragma fragment fragInit
            ENDHLSL
        }
        
        // Pass 1: Update
        Pass
        {
            Name "Update"
            HLSLPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment fragUpdate
            ENDHLSL
        }
    }
}