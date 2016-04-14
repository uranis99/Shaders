Shader "custom/Flat" {
	Properties{
		_Color ("Color",Color)=(1,1,1,1)
	}
	SubShader{
		Pass{
			
			CGPROGRAM

			//vertex=type, vert=function name
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;
			uniform float4 _LightColor0;

			//input data
			struct appdata{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			//output data
			struct v2f{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			//vertex shader function
			v2f vert (appdata v){
				v2f o;


				//normalDirection = normal of the vertex/(pixel)
				float3 normalDirection= mul(v.normal, _World2Object).xyz;

				//lightDirection = light direction
				float3 lightDirection=_WorldSpaceLightPos0.xyz;
				
				//diffuseReflection = _Color *_LightColor0 * dot(normalDirection, lightDirection);
				float3 diffuseReflection = _Color * _LightColor0*dot(normalDirection,lightDirection);

				//Built in variables
				//normalize()
				//_World2Object
				//_WorldSpaceLightPos0
				//_LightColor0

				//built in functions
				//dot(lightDirection, normal);

				//return the diffuseReflection;
				o.color = float4(diffuseReflection, 1);
				o.vertex=mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			//fragment/pixel function
			float4 frag (v2f i):COLOR{
				return i.color;
			}

			ENDCG
		}
	}

	//commented out during development
	//Fallback "diffuse"
}

/*Normalize = 5 (-1,1)
Dot = (-2,-2)
Mul = Vector & Matrix || Matrix & Matrix
Max = max(0.0,dot)
Saturate = Saturate (dot(normaldir,lightdir)) -10/10
Pow = 4^2 = 4*41
*/