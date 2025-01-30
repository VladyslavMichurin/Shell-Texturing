Shader "_MyShaders/1)Shell Shader V1"
{
    SubShader
    {
        Tags 
        { 
            "LightMode" = "ForwardBase"
        }

        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

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

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float4 _MainColor, _SecondColor;

            int _ShellIndex;
            int _ShellCount;
            float _MaxDistance;
            float _Density;
            float _NoiseMin, _NoiseMax;
            float _Thickness;


            float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = v.uv;
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));

                float distance_Delta = _MaxDistance / _ShellCount;

                v.vertex.xyz += v.normal.xyz * (distance_Delta * _ShellIndex);

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

                float2 newUV = i.uv * _Density;
                float height = shellIndex / shellCount;

                float2 localUV = frac(newUV) * 2 - 1;
                float localDistanceFromCenter = length(localUV);

                uint2 hashUV = newUV;
                uint seed = hashUV.x + 100 * hashUV.y + 100 * 10;
                float rand = lerp(_NoiseMin, _NoiseMax, hash(seed));

                float3 albedo = 0;
                if(rand > height)
                {
                    albedo = lerp(_MainColor, _SecondColor, height);
                }
                else
                {
                    discard;
                }

                if(localDistanceFromCenter > _Thickness * (rand - height) && shellIndex > 0)
                {
                    discard;
                }

                
                
                return float4(albedo, 1);
            }
            ENDCG
        }
    }
}
