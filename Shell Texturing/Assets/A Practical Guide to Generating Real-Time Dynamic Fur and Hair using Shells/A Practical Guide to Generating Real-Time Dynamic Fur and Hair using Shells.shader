Shader "_MyShaders/2)A Practical Guide to Generating Real-Time Dynamic Fur and Hair using Shells"
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

                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float3 normal : TEXCOORD1;
            };

            float4 _MainColor;

            int _ShellIndex;
            int _ShellCount;

            float _MaxFurLength;

            float3 _ShellDirection;

            v2f vert (appdata v)
            {
                v2f o;

                float h = (float)_ShellIndex / (float)_ShellCount;
                float FurLength = _MaxFurLength * h;
                v.vertex.xyz += (v.normal.xyz * FurLength);

                o.normal = normalize(UnityObjectToWorldNormal(v.normal));

                float k = pow(h, 3);
                //float3 worldShellDirection = mul(_ShellDirection, unity_WorldToObject);
                v.vertex.xyz += (_ShellDirection * k);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }
            
            float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

                float2 newUV = i.uv * 100;
                float h = shellIndex / shellCount;

                uint2 hashUV = newUV;
                uint seed = hashUV.x + 100 * hashUV.y + 100 * 10;
                float rand = hash(seed);

                float3 albedo = _MainColor;
                if(rand < h)
                {
                    discard;
                }

                return float4(albedo * h, 1);
            }
            ENDCG
        }
    }
}
