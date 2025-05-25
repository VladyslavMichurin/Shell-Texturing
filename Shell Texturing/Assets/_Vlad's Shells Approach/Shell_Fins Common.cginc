#if !defined(SHELL_FINS_COMMON_INCLUDED)
#define SHELL_FINS_COMMON_INCLUDED

        #include "UnityPBSLighting.cginc"
        #include "AutoLight.cginc"

		sampler2D _ShellTexture, _ShellsLocationTexture;
        float4 _ShellTexture_ST, _ShellsLocationTexture_ST;

        float _Density;
        float _MaxShellLength;
        float _NoiseMin, _NoiseMax;
        float _Attenuation;
        float _OcclusionBias;

        float3 _ShellDirection;

        float NdotL(float3 _normal)
        {
            float ndotl = DotClamped(_normal, _WorldSpaceLightPos0) * 0.5f + 0.5f;
            ndotl = lerp(ndotl * ndotl, 1, ndotl * ndotl);
            return ndotl;
        }


        float AmbientOcclusion(float _height)
        {
            float ambientOcclusion = pow(_height, _Attenuation);
            ambientOcclusion += _OcclusionBias;
            return saturate(ambientOcclusion);
        }

#endif