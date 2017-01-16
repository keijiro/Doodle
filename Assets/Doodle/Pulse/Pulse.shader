Shader "Doodle/Pulse"
{
    Properties
    {
        _Albedo("Albedo", Color) = (0.5, 0.5, 0.5)
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

        #pragma surface surf Standard nolightmap
        #pragma target 3.0

        struct Input
        {
            float2 uv_NormalMap;
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        float3 _Pulse_Origin;

        float4 _Pulse_Grid;
        float3 _Pulse_GridColor;

        float2 _Pulse_Line1;
        float3 _Pulse_Line1Color;

        float3 _Pulse_Line2Color;
        float2 _Pulse_Line2;

        fixed3 _Albedo;
        half _Smoothness;
        half _Metallic;

        sampler2D _NormalMap;
        half _NormalScale;

        sampler2D _OcclusionMap;
        half _OcclusionStrength;

        half3 LineColor(float3 wp)
        {
            float3 acc = 0;

            // Grid line X/Z
            float2 grid = frac((wp.xz + _Pulse_Grid.zw) / _Pulse_Grid.x) - 0.5;
            acc += (1 - smoothstep(0, _Pulse_Grid.y, abs(grid.x))) * _Pulse_GridColor;
            acc += (1 - smoothstep(0, _Pulse_Grid.y, abs(grid.y))) * _Pulse_GridColor;

            // Line 1
            float l1 = abs(length(wp - _Pulse_Origin) - _Pulse_Line1.y);
            acc += _Pulse_Line1Color * (1 - smoothstep(0, _Pulse_Line1.x, l1));

            // Line 2
            float l2 = abs(length(wp - _Pulse_Origin) - _Pulse_Line2.y);
            acc += _Pulse_Line2Color * (1 - smoothstep(0, _Pulse_Line2.x, l2));

            return acc;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Albedo;
            o.Smoothness = _Smoothness;
            o.Metallic = _Metallic;

            half4 nrm = tex2D(_NormalMap, IN.uv_NormalMap);
            o.Normal = UnpackScaleNormal(nrm, _NormalScale);

            half occ = tex2D(_OcclusionMap, IN.uv_NormalMap).g;
            o.Occlusion = LerpOneTo(occ, _OcclusionStrength);

            half3 lc = LineColor(IN.worldPos);
            half3 wn = WorldNormalVector(IN, o.Normal);
            o.Emission = lc * saturate(wn.y);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
