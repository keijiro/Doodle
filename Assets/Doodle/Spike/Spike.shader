Shader "Doodle/Wire2"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)

        [Space]
        _Frequency("Noise Frequency", Float) = 20
        _Amplitude("Noise Amplitude", Float) = 0.05
        _Speed("Noise Speed", Float) = 8

        [HideInInspector] _LevelTex("", 2D) = "black"{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "SimplexNoiseGrad3D.cginc"

    half4 _Color;

    half _Frequency;
    half _Amplitude;
    half _Speed;

    sampler2D _LevelTex;

    struct appdata
    {
        float4 vertex : POSITION;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        UNITY_FOG_COORDS(1)
    };

    v2f vert(appdata v)
    {
        float3 P = v.vertex.xyz;

        // Divergence-free noise field
        float3 n_offs = float3(0, _Time.y * _Speed, 0);
        half3 n_p1 = n_offs + P * _Frequency;
        half3 n_p2 = n_offs - P * _Frequency + float3(19.3742, 3.48392, 8.32454);
        half3 dn = cross(snoise_grad(n_p1), snoise_grad(n_p2));

        // Vertex displacement
        half lv = tex2Dlod(_LevelTex, 0).r;
        float3 disp = dn * _Amplitude * lv * lv * lv;

        v2f o;
        o.vertex = UnityObjectToClipPos(float4(P + disp, 1));
        UNITY_TRANSFER_FOG(o, o.vertex);
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
