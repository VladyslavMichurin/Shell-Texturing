
// a recreation of a shell shader using Acerola's video and github as a guide

Shader "_MyShaders/1)Simple Shell Shader(Acerola Ver)"
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

            float4 _MainColor;

            int _ShellIndex;
            int _ShellCount;
            float _ShellLength;
            float _Density;
            float _NoiseMin, _NoiseMax;
            float _Thickness;
            float _Attenuation;
            float _OcclusionBias;
            float _ShellDistanceAttenuation; 


            float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

            v2f vert (appdata v)
            {
                v2f o;

                float shellHeight = (float)_ShellIndex / (float)_ShellCount;
                shellHeight = pow(shellHeight, _ShellDistanceAttenuation);
                v.vertex.xyz += v.normal.xyz * (_ShellLength * shellHeight);

                o.uv = v.uv;
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
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

                float3 albedo = _MainColor;
                int outsideThickness = (localDistanceFromCenter) > (_Thickness * (rand - height));
                if(outsideThickness && shellIndex > 0)
                {
                    discard;
                }

                float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0) * 0.5f + 0.5f;
                ndotl = ndotl * ndotl;

                float ambientOcclusion = pow(height, _Attenuation);
                ambientOcclusion += _OcclusionBias;
                ambientOcclusion = saturate(ambientOcclusion);
                
                return float4(albedo  * ndotl * ambientOcclusion, 1);
            }
            ENDCG
        }
    }
}
