Shader "custom/VertSpec" {
	Properties{
		_Color ("Color",color) = (1,1,1,1)
		_SpecColor ("SpecColor",color) = (1,1,1,1)
		_Shininess ("Shininess", Float) = 10
		_Atten ("Attenuation",Float) = 1
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			//pragmas
			#pragma vertex vert
			#pragma fragment frag

			//user input
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float _Atten;

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
				float4 worldPosition : TEXCOORD0;
				float3 normalDirection : TEXCOORD1;
			};

			//vertexfunction
			v2f vert (appdata v){
				v2f o;

				//vectors
				//normal directions
				o.normalDirection=normalize(mul(v.normal, _World2Object).xyz);
				o.worldPosition=mul(_Object2World, v.vertex);

				//return the diffuseReflection
				o.vertex=mul(UNITY_MATRIX_MVP,v.vertex);
				return o; 
			}

			//fragmentfunction
			float4 frag (v2f i):COLOR {

				float3 normalDirection = i.normalDirection;

				//view Direction=camera position - vertex position= distance between camera and vertex
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.worldPosition);

				//lightDirection= light direction
				float4 lightDirection=normalize(_WorldSpaceLightPos0);
				float atten = _Atten;

				//diffuse reflection - Lambert
				//float4 diffuseReflection= dot(normalDirection,lightDirection);
				float3 diffuseReflection= atten*_Color*_LightColor0.xyz * max(0.0,dot(normalDirection,lightDirection));

				//specular reflection
				//float3 specularReflection = dot( normalDirection, lightDirection ) * dot( reflect( -lightDirection, normalDirection ), viewDirection;
				float3 specularReflection = atten*_SpecColor.rgb * max( 0.0, dot( normalDirection, lightDirection) ) * pow(max( 0.0, dot( reflect( -lightDirection, normalDirection), viewDirection)), _Shininess);

				float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT;

				//Final
				return float4(lightFinal*_Color.rgb,1.0);

			}

			ENDCG
		}	
	}
}