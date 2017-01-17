Shader "Doodle/Wire"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    CGINCLUDE

    #include "UnityCG.cginc"


    float UVRandom(float u, float v)
    {
        float f = dot(float2(12.9898, 78.233), float2(u, v));
        return frac(43758.5453 * sin(f));
    }

    half4 _Color;

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
    };

    v2f vert(appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        UNITY_TRANSFER_FOG(o,o.vertex);
        return o;
    }

    fixed4 frag(v2f i) : SV_Target
    {
        fixed4 col = _Color * frac(dot(i.uv.xy, 1) + UVRandom(i.uv.x, i.uv.y) - _Time.y);
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
