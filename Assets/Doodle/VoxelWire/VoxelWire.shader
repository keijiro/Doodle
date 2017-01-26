Shader "Doodle/Voxel Wire"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Voxelize("Voxelize", Range(0, 1)) = 0.5
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    half4 _Color;
    float _Voxelize;

    struct appdata
    {
        float4 vertex : POSITION;
    };

    struct v2f
    {
        UNITY_FOG_COORDS(1)
        float4 vertex : SV_POSITION;
    };

    v2f vert(appdata v)
    {
        float3 wp = mul(unity_ObjectToWorld, v.vertex).xyz;

        float div = pow(5, 1 + (1 - _Voxelize) * 2);
        float3 vp = floor(wp * div + 0.5) / div;

        wp = lerp(wp, vp, saturate(_Voxelize * 10));

        v2f o;
        o.vertex = UnityWorldToClipPos(wp);
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
