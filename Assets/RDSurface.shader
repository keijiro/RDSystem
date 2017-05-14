Shader "RDSurface"
{
    Properties
    {
        _MainTex("RD Texture", 2D) = "white" {}

        _Color0("Color 0", Color) = (1,1,1,1)
        _Color1("Color 1", Color) = (1,1,1,1)

        _Smoothness0("Smoothness 0", Range(0, 1)) = 0.5
        _Smoothness1("Smoothness 1", Range(0, 1)) = 0.5

        _Metallic0("Metallic 0", Range(0, 1)) = 0.0
        _Metallic1("Metallic 1", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard
        #pragma target 3.0

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;

        struct Input {
            float2 uv_MainTex;
        };

        fixed4 _Color0, _Color1;
        half _Smoothness0, _Smoothness1;
        half _Metallic0, _Metallic1;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            half2 rd = tex2D(_MainTex, IN.uv_MainTex).xy;
            half s = smoothstep(0.1, 0.3, rd.y);

            float3 duv = float3(_MainTex_TexelSize.xy, 0);
            half rd1 = tex2D(_MainTex, IN.uv_MainTex - duv.xz).y;
            half rd2 = tex2D(_MainTex, IN.uv_MainTex + duv.xz).y;
            half rd3 = tex2D(_MainTex, IN.uv_MainTex - duv.zy).y;
            half rd4 = tex2D(_MainTex, IN.uv_MainTex + duv.zy).y;

            o.Normal = normalize(float3(rd2 - rd1, rd4 - rd3, 0.1));

            o.Albedo = lerp(_Color0.rgb, _Color1.rgb, s);
            o.Smoothness = lerp(_Smoothness0, _Smoothness1, s);
            o.Metallic = lerp(_Metallic0, _Metallic1, s);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
