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

		    v2g vert(appdata v)
		    {
			    v2g o;

			    o.vertex = mul(unity_ObjectToWorld, v.vertex);
			    o.uv = TRANSFORM_TEX(v.uv, _ShellTexture);
			    o.normal = mul(v.normal, unity_WorldToObject);

			    return o;
		    }

		    [maxvertexcount(4)]
			void geom(line v2g IN[2], inout TriangleStream<g2f> triStream)
			{
				float4x4 m_MVP = unity_MatrixMVP;
				float4x4 vp = mul(m_MVP, unity_WorldToObject);

				float3 eyeVec = normalize(((IN[0].vertex - _WorldSpaceCameraPos) + (IN[1].vertex - _WorldSpaceCameraPos)) / 2);
				//eyeVec = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
				float4 lineNormal = float4(normalize((IN[0].normal + IN[1].normal) / 2), 0);
				float eyeDot = dot(lineNormal, eyeVec);

				float3 newNormal = normalize(cross(IN[1].vertex- IN[0].vertex, lineNormal));
				float maxOffset = 0.5f;

				if (eyeDot < maxOffset && eyeDot > -maxOffset)
				{
					
					lineNormal *= _MaxShellLength;

					g2f pIn;

					pIn.vertex = mul(vp, IN[1].vertex);
					pIn.uv = float2(1, 0);
					pIn.originalUv = IN[1].uv;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, IN[1].vertex + lineNormal);
					pIn.uv = float2(1, 1);
					pIn.originalUv = IN[1].uv;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, IN[0].vertex);
					pIn.uv = float2(0, 0);
					pIn.originalUv = IN[0].uv;
					triStream.Append(pIn);

					pIn.vertex = mul(vp, IN[0].vertex + lineNormal);
					pIn.uv = float2(0, 1);
					pIn.originalUv = IN[0].uv;
					triStream.Append(pIn);

					triStream.RestartStrip();
				}

			}

            float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}
		    fixed4 frag(g2f i) : SV_Target
		    {
			    fixed4 albedo = tex2D(_ShellTexture, i.originalUv);
			    fixed4 fins = tex2D(_FinsTexture, i.uv);
			    fixed4 shellsLocation = tex2D(_ShellsLocationTexture, i.originalUv);

                uint2 hashUV = i.uv * _Density;
                uint seed = hashUV.x + 100 * hashUV.y + 100 * 10;
                float rand = lerp(_NoiseMin, _NoiseMax, hash(seed)) * shellsLocation;

                if (shellsLocation.r < 0.5) discard;

			    return albedo * fins;
		    }

		ENDCG
		}
    }
}
