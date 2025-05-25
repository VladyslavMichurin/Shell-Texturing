Shader "_MyShaders/_Vlad's Fins Shader"
{
    SubShader
    {
        Tags 
        { 
            "LightMode" = "ForwardBase"
        }

        Pass
		{
            Name "Fins"

            Cull Off
		    ZWrite Off
		    Blend SrcAlpha OneMinusSrcAlpha

		    CGPROGRAM
		    #pragma vertex vert
		    #pragma geometry geom
		    #pragma fragment frag

			#pragma multi_compile _ _USE_CAMERA_DIR

		    #include "Shell_Fins Common.cginc"

		    struct appdata
		    {
			    float4 vertex : POSITION;
			    float2 uv : TEXCOORD0;
			    float3 normal : NORMAL;
		    };


		    struct v2g
		    {
			    float4 vertex : SV_POSITION;
			    float2 uv : TEXCOORD0;
			    float3 normal : NORMAL;
		    };

		    struct g2f
		    {
				float4 vertex : SV_POSITION;
			    float2 uv : TEXCOORD0;
			    float2 originalUv : TEXCOORD1;

				float3 normal : TEXCOORD2;
		    };

		    sampler2D _FinsTexture;
            float4 _FinsTexture_ST;

			float _LenghtOffset;
			float _DirectionPower;
			float _MaxOffset;

		    v2g vert(appdata v)
		    {
			    v2g o;

			    o.vertex = mul(unity_ObjectToWorld, v.vertex);
			    o.uv = TRANSFORM_TEX(v.uv, _ShellTexture);
			    o.normal = mul(v.normal, unity_WorldToObject);

			    return o;
		    }

			g2f PrepareVertexData(float2 _uv, float2 _originalUv, float4 _vertex, float3 _normal)
			{
				float4x4 m_MVP = unity_MatrixMVP;
				float4x4 vp = mul(m_MVP, unity_WorldToObject);

				g2f toReturn;

				toReturn.uv = _uv;
				toReturn.originalUv = _originalUv;
				toReturn.vertex = mul(vp, _vertex);
				toReturn.normal = normalize(UnityObjectToWorldNormal(mul(vp, _normal)));

				return toReturn;
			}

		    [maxvertexcount(4)]
			void geom(line v2g input[2], inout TriangleStream<g2f> stream)
			{
				float3 eyeVec;
				#if defined(_USE_CAMERA_DIR)
					eyeVec = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
				#else
					eyeVec = normalize(((input[0].vertex - _WorldSpaceCameraPos) + (input[1].vertex - _WorldSpaceCameraPos)) / 2);
				#endif

				float4 lineNormal = float4(normalize((input[0].normal + input[1].normal) / 2), 0);
				float eyeDot = dot(lineNormal, eyeVec);

				if (eyeDot < _MaxOffset && eyeDot > -_MaxOffset)
				{
					float shellsLocation = tex2Dlod(_ShellsLocationTexture, float4(input[0].uv, 0,0)).r;
					
					float finLenght = max(0, _MaxShellLength - _LenghtOffset);
					lineNormal.xyz = (lineNormal.xyz * finLenght).xyz;
					lineNormal.xyz += _ShellDirection * _DirectionPower;
					lineNormal.xyz *= shellsLocation;

					float4 test = float4(normalize(lineNormal.xyz), lineNormal.w);
					
					g2f pIn;

					pIn = PrepareVertexData(float2(1, 0), input[1].uv, input[1].vertex, input[1].normal);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(1, 1), input[1].uv, input[1].vertex + lineNormal,  input[1].normal);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(0, 0), input[0].uv, input[0].vertex, input[0].normal);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(0, 1), input[0].uv, input[0].vertex + lineNormal, input[0].normal);
					stream.Append(pIn);

					stream.RestartStrip();
				}

			}

		    fixed4 frag(g2f i) : SV_Target
		    {
			    float3 albedo = tex2D(_ShellTexture, i.originalUv);
			    float3 finsRGB = tex2D(_FinsTexture, i.uv).rgb;
				float finsAlpha = tex2D(_FinsTexture, i.uv).a;

				if(finsAlpha < 0.05 || (1 - i.uv.y) < 0.01) discard;

				float3 finalColor = albedo * (1 - NdotL(i.normal)) * AmbientOcclusion(i.uv.y);
				return float4(finalColor, finsAlpha);
		    }

		ENDCG
		}
    }
}
