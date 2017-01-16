Shader "Custom/Comb2"
{
    Properties
    {
        _Color1("Color 1", Color) = (1, 1, 1, 1)
        _Color2("Color 2", Color) = (1, 1, 1, 1)

        [Space]
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metallic", Range(0, 1)) = 0

        [Space]
        _NormalMap("Normal Map", 2D) = "bump"{}
        _NormalScale("Normal Scale", Range(0, 2)) = 1

        [Space]
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionStrength("Strength", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows addshadow
        #pragma target 3.0

        struct Input
        {
            float2 uv_NormalMap;
            float3 worldPos;
        };

        fixed4 _Color1;
        fixed4 _Color2;

        half _Smoothness;
        half _Metallic;

        sampler2D _NormalMap;
        half _NormalScale;

        sampler2D _OcclusionMap;
        half _OcclusionStrength;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float rot = _Time.y * 0.1;
            const float3 dir = normalize(float3(cos(rot), sin(rot), 0.3));

            float wid = (sin(IN.worldPos.z * 3 - _Time.y*4) + 1) * 0.2;
            float dd = frac(dot(IN.worldPos.xyz, dir) * 10);
            half3 color = smoothstep(0.0 + wid, 0.05 + wid, dd) * smoothstep(0.0 + wid, 0.05 + wid, 1 - dd);

            o.Albedo = lerp(_Color1.rgb, _Color2.rgb, color);

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            half4 nrm = tex2D(_NormalMap, IN.uv_NormalMap);
            o.Normal = UnpackScaleNormal(nrm, _NormalScale);

            half occ = tex2D(_OcclusionMap, IN.uv_NormalMap).g;
            o.Occlusion = LerpOneTo(occ, _OcclusionStrength);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
