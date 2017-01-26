Shader "Doodle/Wire2"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Amplitude("Amplitude", Float) = 0.05
        _Deform("Deform", Range(0, 1)) = 0
        [HideInInspector] _WaveformTex("", 2D) = "black"{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    half4 _Color;
    half _Amplitude;
    half _Deform;
    sampler2D _WaveformTex;

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
    };

    float UVRandom(float2 uv)
    {
        float f = dot(float2(12.9898, 78.233), uv);
        return frac(43758.5453 * sin(f));
    }

    v2f vert(appdata v)
    {
        float3 P = v.vertex.xyz;
        float3 N = v.normal;
        float3 T = v.tangent.xyz;
        float3 BN = cross(N, T) * v.tangent.w;

        float4 tc = float4(v.uv.y + v.uv.x * 0.1, 0.5, 0, 0);
        float lv = tex2Dlod(_WaveformTex, tc).r;
        float3 disp = normalize(lerp(T, BN, UVRandom(v.uv)));
        disp = normalize(lerp(N, disp, lv * 2)) * lv * _Amplitude;

        v2f o;
        o.vertex = UnityObjectToClipPos(float4(P + disp, 1));
        UNITY_TRANSFER_FOG(o,o.vertex);
        return o;
    }

    fixed4 frag(v2f i) : SV_Target
    {
        fixed4 col = _Color;
        UNITY_APPLY_FOG(i.fogCoord, col);
        return col;
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            ENDCG
        }
    }
}
