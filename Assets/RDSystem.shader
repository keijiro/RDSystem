Shader "RDSystem"
{
    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"

    float UVRandom(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    half4 frag_init(v2f_img i) : SV_Target
    {
        return half4(1, step(0.9, UVRandom(i.uv)), 0, 0);
    }

    half4 frag_update(v2f_img i) : SV_Target
    {
        float2 texelSize = 1 / float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
        float4 duv = float4(1, 1, -1, 0) * texelSize.xyxy;

        float2 s = tex2D(_SelfTexture2D, i.uv).xy;

        float2 lpc =
            tex2D(_SelfTexture2D, i.uv - duv.xy).xy * 0.05 +
            tex2D(_SelfTexture2D, i.uv - duv.wy).xy * 0.20 +
            tex2D(_SelfTexture2D, i.uv - duv.zy).xy * 0.05 +

            tex2D(_SelfTexture2D, i.uv + duv.zw).xy * 0.20 +
            s * -1 +
            tex2D(_SelfTexture2D, i.uv + duv.xw).xy * 0.20 +

            tex2D(_SelfTexture2D, i.uv + duv.zy).xy * 0.05 +
            tex2D(_SelfTexture2D, i.uv + duv.wy).xy * 0.20 +
            tex2D(_SelfTexture2D, i.uv + duv.xy).xy * 0.05;

        const float F = 0.0554;
        const float K = 0.0620;

        float2 next = s + float2(
            lpc.x * 1.0 - s.x * s.y * s.y + F * (1 - s.x),
            lpc.y * 0.4 + s.x * s.y * s.y - (K + F) * s.y
        );

        return saturate(next.xyxy);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "Init"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_init
            ENDCG
        }
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_update
            ENDCG
        }
    }
}
