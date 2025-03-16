Shader "_MyShaders/3)Vlad's Shell Shader"
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
            Name "Shells"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #pragma multi_compile _ _GLOBAL_SHELL_DIRECTION
            #pragma multi_compile _ _TAPPER_SHELLS

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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 normal : TEXCOORD1;

                float3 worldPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _ShellTexture, _ShellsLocationTexture;
            float4 _ShellTexture_ST, _ShellsLocationTexture_ST;
            float4 _Tint;

            int _ShellIndex;
            int _ShellCount;

            float _Density;
            float _MaxShellLength;
            float _NoiseMin, _NoiseMax;
            float _Thickness;
            float _ShellDistanceAttenuation;
            float _Curvature;

            float3 _ShellDirection;

            v2f vert (appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _ShellTexture);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

                float h = (float)_ShellIndex / (float)_ShellCount;
                h = pow(h, _ShellDistanceAttenuation);
                float FurLength = _MaxShellLength * h;
                v.vertex.xyz += (v.normal.xyz * FurLength);

                float k = pow(h, _Curvature);
                float3 shellDirection = _ShellDirection;
                #if defined(_GLOBAL_SHELL_DIRECTION)
                    shellDirection = mul(unity_WorldToObject, _ShellDirection);
                #endif
                v.vertex.xyz += (shellDirection * k);

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }
            
            [maxvertexcount(4)] 
            void geom(lineadj v2f input[4], inout TriangleStream<v2f> stream)
            {
                float viewDir = input[0].viewDir;
                float3 N1 = normalize(cross( input[0].worldPos - input[1].worldPos,
                                        input[3].worldPos - input[1].worldPos));
                float3 N2 = normalize(cross(input[2].worldPos - input[1].worldPos,
                                        input[0].worldPos - input[1].worldPos)); 

                float viewDotN1 = dot(viewDir, N1);
                float viewDotN2 = dot(viewDir, N2);

                v2f g0, g1, g2, g3;
                g0 = input[0];
                g1 = input[1];
                g2 = input[2];
                g3 = input[3];

                if( viewDotN1 * viewDotN2 < 0)
                {
                    //stream.Append(g3);
                }

	            stream.Append(g0);
	            stream.Append(g1);
	            stream.Append(g2);
            }

            float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}
            fixed4 frag (v2f i) : SV_Target
            {
                float3 albedo = tex2D(_ShellTexture, i.uv) * _Tint;
                float shellsLocation = tex2D(_ShellsLocationTexture, i.uv);
                float3 finalColor = float3(255, 0, 255) / (float)255;

                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

                float2 newUV = i.uv * _Density;
                float h = shellIndex / shellCount;

                uint2 hashUV = newUV;
                uint seed = hashUV.x + 100 * hashUV.y + 100 * 10;
                float rand = lerp(_NoiseMin, _NoiseMax, hash(seed)) * shellsLocation;

                int discardCondition = rand < h;
                #if defined(_TAPPER_SHELLS)
                    float2 localUV = frac(newUV) * 2 - 1;
                    float localDistanceFromCenter = length(localUV);
                    int outsideThickness = (localDistanceFromCenter) > (_Thickness * (rand - h));
                    discardCondition = outsideThickness;
                #endif

                if(discardCondition && shellIndex > 0)
                {
                    discard;
                }

                finalColor = lerp(albedo * h, albedo, 1 - shellsLocation);

                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
