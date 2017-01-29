Shader "Hidden/Doodle/Stripe"
{
    CGINCLUDE

    #include "UnityCG.cginc"

    half2 _StripSize;
    half _ScrollSpeed;
    half3 _Distribution;

    half3 _GradientA;
    half3 _GradientB;
    half3 _GradientC;
    half3 _GradientD;

    struct Input
    {
        half3 Color : COLOR;
    };

    // PRNG function
    float UVRandom(float id, float salt)
    {
        float2 uv = float2(id, salt);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    void vert(inout appdata_full v)
    {
        float id = v.vertex.z;

        float2 vp = v.vertex.xy * _StripSize;

        // Random point in |-0.5, 0.5|
        float3 dp = float3(UVRandom(id, 0), UVRandom(id, 1), UVRandom(id, 2));

        // Scrolling with wrapping around
        float speed = _ScrollSpeed * lerp(0.5, 1, UVRandom(id, 3));
        dp.y = frac(dp.y + speed * _Time.y);

        // Cosine gradient
        float pal = UVRandom(id, 4);
        half3 rgb = saturate(_GradientA + _GradientB * cos(_GradientC * pal + _GradientD));
        rgb = GammaToLinearSpace(rgb);

        v.vertex.xyz = float3(vp, 0) + (dp - 0.5) * _Distribution;
        v.normal = float3(0, 0, 1);
        v.color.rgb = rgb;
    }

    void surf(Input IN, inout SurfaceOutputStandard o)
    {
        o.Albedo = 0;
        o.Metallic = 0;
        o.Smoothness = 0;
        o.Emission = IN.Color;
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf Standard vertex:vert addshadow
        #pragma target 3.0
        ENDCG
    }
    FallBack "Diffuse"
}
