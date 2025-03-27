
Shader "_MyShaders/Testing/3)Fins Shader"
{
   	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FurMaskTex("Fur Mask", 2D) = "white" {}
		_SideFurTex("Side Fur", 2D) = "white" {}
	}
	SubShader
	{
		
		Tags { "RenderType"="Opaque"  "LightMode" = "ForwardBase" }
		LOD 100

		//Mesh
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
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}


		//Fins
		//Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "ForwardBase" }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma geometry geom
		#pragma fragment frag


		#include "UnityCG.cginc"

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

		sampler2D _MainTex;
		sampler2D _SideFurTex;
		sampler2D _FurMaskTex;
		float4 _MainTex_ST;


		v2g vert(appdata v)
		{
			v2g o;
			o.vertex = mul(unity_ObjectToWorld, v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.normal = mul(v.normal, unity_WorldToObject);
			return o;
		}

		[maxvertexcount(4)]
		void geom(line v2g IN[2], inout TriangleStream<g2f> triStream)
		{
			float4x4 m_MVP = unity_MatrixMVP;
			float4x4 vp = mul(m_MVP, unity_WorldToObject);

			float3 eyeVec = normalize(((IN[0].vertex -_WorldSpaceCameraPos) + (IN[1].vertex - _WorldSpaceCameraPos)) / 2);
			float4 lineNormal = float4(normalize((IN[0].normal + IN[1].normal) / 2), 0);
			float eyeDot = dot(lineNormal, eyeVec);

			float3 newNormal = normalize(cross(IN[1].vertex- IN[0].vertex, lineNormal));
			float maxOffset = 0.25f;

			if (eyeDot < maxOffset && eyeDot > -maxOffset)
			{
				
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

		fixed4 frag(g2f i) : SV_Target
		{
			fixed4 originalCol = tex2D(_MainTex, i.originalUv);
			fixed4 col = tex2D(_SideFurTex, i.uv);
			fixed4 mask = tex2D(_FurMaskTex, i.originalUv);

			if (mask.r <= .5) discard;

			return col;
			return originalCol * col;
		}

		ENDCG
		}
		
	}
}