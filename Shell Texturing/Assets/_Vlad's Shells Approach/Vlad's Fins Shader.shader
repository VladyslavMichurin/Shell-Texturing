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
		    ZWrite On
		    Blend SrcAlpha OneMinusSrcAlpha

		    CGPROGRAM
		    #pragma vertex vert
		    #pragma geometry geom
		    #pragma fragment frag

			#pragma multi_compile _ _USE_CAMERA_DIR

		    #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

		    struct appdata
		    {
			    float4 vertex : POSITION;
			    float2 uv : TEXCOORD0;
			    float3 normal : NORMAL;
		    };


		    struct v2g
		    {
			    float2 uv : TEXCOORD0;
			    float4 vertex : SV_POSITION;
			    float3 normal : NORMAL;
		    };

		    struct g2f
		    {
			    float2 uv : TEXCOORD0;
			    float2 originalUv : TEXCOORD1;
			    float4 vertex : SV_POSITION;
		    };

		    sampler2D _ShellTexture, _ShellsLocationTexture, _FinsTexture;
            float4 _ShellTexture_ST, _ShellsLocationTexture_ST, _FinsTexture_ST;
            float4 _Tint;

            float _Density;
            float _MaxShellLength;
            float _NoiseMin, _NoiseMax;

			float3 _ShellDirection;

			float _LenghtOffset;
			float _MaxOffset;

		    v2g vert(appdata v)
		    {
			    v2g o;

			    o.vertex = mul(unity_ObjectToWorld, v.vertex);
			    o.uv = TRANSFORM_TEX(v.uv, _ShellTexture);
			    o.normal = mul(v.normal, unity_WorldToObject);

			    return o;
		    }

			g2f PrepareVertexData(float2 _uv, float2 _originalUv, float4 _vertex)
			{
				float4x4 m_MVP = unity_MatrixMVP;
				float4x4 vp = mul(m_MVP, unity_WorldToObject);

				g2f toReturn;

				toReturn.uv = _uv;
				toReturn.originalUv = _originalUv;
				toReturn.vertex = mul(vp, _vertex);

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

				float3 newNormal = normalize(cross(input[1].vertex- input[0].vertex, lineNormal));

				if (eyeDot < _MaxOffset && eyeDot > -_MaxOffset)
				{
					float shellsLocation = tex2Dlod(_ShellsLocationTexture, float4(input[0].uv, 0,0)).r; 
					lineNormal.xyz = (((lineNormal.xyz * _MaxShellLength).xyz + _ShellDirection + ( lineNormal.xyz * _LenghtOffset)) 
							* shellsLocation);

					g2f pIn;

					pIn = PrepareVertexData(float2(1, 0), input[1].uv, input[1].vertex);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(1, 1), input[1].uv, input[1].vertex + lineNormal);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(0, 0), input[0].uv, input[0].vertex);
					stream.Append(pIn);

					pIn = PrepareVertexData(float2(0, 1), input[0].uv, input[0].vertex + lineNormal);
					stream.Append(pIn);

					stream.RestartStrip();
				}

			}

		    fixed4 frag(g2f i) : SV_Target
		    {
			    fixed4 albedo = tex2D(_ShellTexture, i.originalUv);
			    fixed4 fins = tex2D(_FinsTexture, i.uv);

				if(fins.r < 0.4) discard;

			    return albedo * fins;
		    }

		ENDCG
		}
    }
}
