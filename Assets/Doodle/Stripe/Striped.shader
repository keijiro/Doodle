Shader "Doodle/Stripe/Striped"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _StripeTex("Stripe", 2D) = "white" {}

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

        #pragma surface surf Standard nolightmap fullforwardshadows addshadow
        #pragma target 3.0

        struct Input
        {
            float2 uv_NormalMap;
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        half3 _Color;
        sampler2D _StripeTex;

        half _Smoothness;
        half _Metallic;

        sampler2D _NormalMap;
        half _NormalScale;

        sampler2D _OcclusionMap;
        half _OcclusionStrength;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            half4 nrm = tex2D(_NormalMap, IN.uv_NormalMap);
            o.Normal = UnpackScaleNormal(nrm, _NormalScale);

            float3 uvw = IN.worldPos.xyz * 0.1 - 0.5;

            half3 stripe1 = tex2D(_StripeTex, uvw.yz);
            half3 stripe2 = tex2D(_StripeTex, frac(float2(uvw.z + uvw.y, uvw.x)));
            half3 stripe3 = tex2D(_StripeTex, uvw.xy);

            half3 N = abs(WorldNormalVector(IN, o.Normal));
            N.y = 0;
            N.x += 0.001;
            N = normalize(N);
            N *= 1 / dot(N, 1);

            half3 stripe = stripe1 * N.x + stripe2 * N.y + stripe3 * N.z;
            stripe = stripe2;

            o.Albedo = _Color * stripe;

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;


            half occ = tex2D(_OcclusionMap, IN.uv_NormalMap).g;
            o.Occlusion = LerpOneTo(occ, _OcclusionStrength);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
