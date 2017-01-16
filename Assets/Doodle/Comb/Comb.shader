Shader "Hidden/Comb"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D_float _CameraDepthTexture;

    float4x4 _InverseView;

    fixed4 frag (v2f_img i) : SV_Target
    {
        float vz = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
        float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
        float3 vpos = float3((i.uv * 2 - 1) / p11_22, -1) * vz;
        float4 wpos = mul(_InverseView, float4(vpos, 1));

        const float3 dir = normalize(float3(1, 0.8, 0.3));

        half4 source = tex2D(_MainTex, i.uv);
        float dd = frac(dot(wpos.xyz, dir) * 10);

        half3 color = smoothstep(0.0, 0.05, dd) * smoothstep(0.45, 0.5, 1 - dd);

        return half4(lerp(source.rgb, color, 1), source.a);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
