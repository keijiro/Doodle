Shader "Doodle/Clicker"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Metallic("Metallic", Range(0, 1)) = 0.0
        _Frequency("Frequency", Float) = 1
        _Deform("Deform", Range(0, 1)) = 0
        _Offset("Offset", Vector) = (0, 0, 0)
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "SimplexNoiseGrad3D.cginc"

    struct Input
    {
        float dummy;
    };

    fixed4 _Color;
    half _Smoothness;
    half _Metallic;
    half _Frequency;
    half _Deform;
    float3 _Offset;

    void vert(inout appdata_full v)
    {
        float3 P = v.vertex.xyz;
        float3 N = v.normal;
        float3 T = v.tangent.xyz;
        float3 B = cross(N, T);

        float4 sn = snoise_grad(P * _Frequency + _Offset);
        v.vertex.x += sn.w * _Deform;

        T.x += dot(T, sn.xyz) * _Deform;
        B.x += dot(B, sn.xyz) * _Deform;

        v.normal = normalize(cross(T, B));
    }

    void surf(Input IN, inout SurfaceOutputStandard o)
    {
        o.Albedo = _Color.rgb;
        o.Metallic = _Metallic;
        o.Smoothness = _Smoothness;
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf Standard vertex:vert fullforwardshadows
        #pragma target 3.0
        ENDCG
    }
    FallBack "Diffuse"
}
