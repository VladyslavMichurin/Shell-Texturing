Shader "_MyShaders/1)Shell Shader V1"
{
    Properties
    {
        _ShellIndex ("Shell Index", Integer) = 0
        _Color ("Color", Color) = (1, 1, 1, 1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
        }

        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 normal: TEXCOORD1;
            };

            float _ShellIndex;

            float4 _Color;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            v2f vert (appdata v)
            {

                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 toReturn = 0;
                float noiseValue = tex2D(_NoiseTex, i.uv).a;

                float clipValue = (0.15 * _ShellIndex);

                if(noiseValue > clipValue)
                {
                    toReturn.rgb = _Color.rgb;
                    toReturn.g += 0.1 * _ShellIndex;
                }

                clip(noiseValue > clipValue ? 1: -1);

                return float4(toReturn, 1);
            }
            ENDCG
        }
    }
}
