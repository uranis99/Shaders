Shader "custom/VertSpec" {
	Properties{
		_Color ("Color",color) = (1,1,1,1)
		_SpecColor ("SpecColor",color) = (1,1,1,1)
		_Shininess ("Shininess", Float) = 10
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			//praqmas
			#pragma vertex vert
			#pragma fragment frag

			//user input
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			//unity input
			uniform float4 _LightColor0;

			//appdata struct (vertexInput)
			struct appdata{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			//v2f struct (vertexOutput)
			struct v2f{
				float4 vertex:SV_POSITION;
				float4 color:COLOR;
			};

			//vertexfunction
			v2f vert (appdata v){
				v2f o;

				/*Things that are missing
				attenution to control diffuse strength
				ambient light color = UNITY_LIGHTMODEL_AMBIENT
				_Color input - done
				_SpecColor input - done
				*/

				//vectors
				//normal directions
				float3 normalDirection=normalize(mul(float4(v.normal,0.0), _World2Object).xyz);

				//view Direction=camera position - vertex position= distance between camera and vertex
				float3 viewDirection = normalize( float3( float4( _WorldSpaceCameraPos.xyz, 1.0) - mul( _Object2World, v.vertex).xyz) );

				//lightDirection= light direction
				float4 lightDirection=normalize(_WorldSpaceLightPos0);

				//diffuse reflection - Lambert
				//float4 diffuseReflection= dot(normalDirection,lightDirection);
				float3 diffuseReflection= _Color*_LightColor0.xyz * max(0.0,dot(normalDirection,lightDirection));

				//specular reflection
				//float3 specularReflection = dot( normalDirection, lightDirection ) * dot( reflect( -lightDirection, normalDirection ), viewDirection;
				float3 specularReflection = _SpecColor.rgb * max( 0.0, dot( normalDirection, lightDirection) ) * pow(max( 0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Shininess);

				float3 lightFinal = diffuseReflection + specularReflection;

				//return the diffuseReflection
				o.color=float4(lightFinal,1);
				o.vertex=mul(UNITY_MATRIX_MVP,v.vertex);
				return o; 
			}

			//fragmentfunction
			float4 frag (v2f i):COLOR {
				return i.color;
			}

			ENDCG
		}	
	}
}