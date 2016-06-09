Shader "custom/Midterm" {
	Properties{
		_Color("Color",color) = (1,1,1,1)
		_SpecColor("SpecColor",color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
		_Atten("Attenuation",Float) = 1
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM

				//pragmas
				#pragma vertex vert
				#pragma fragment frag

				sampler2D _MainTex;

				//user input
				uniform float4 _Color;
				uniform float4 _SpecColor;
				uniform float _Shininess;
				uniform float _Atten;
				uniform	float2 uv_MainTex;


				//unity input
				uniform float4 _LightColor0;

				//appdata struct (vertexInput)
				struct appdata {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
				};

				//v2f struct (vertexOutput)
				struct v2f {
					float4 vertex:SV_POSITION;
					float4 worldPosition : TEXCOORD0;
					float3 normalDirection : TEXCOORD1;
				};

				//vertexfunction
				v2f vert(appdata v) {
				v2f o;

				//vectors
				//normal directions
				o.normalDirection = normalize(mul(v.normal, _World2Object).xyz);
				o.worldPosition = mul(_Object2World, v.vertex);

				//return the diffuseReflection
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				return o;
				}

				//fragmentfunction
				float4 frag(v2f i) :COLOR{

				float3 normalDirection = i.normalDirection;

				//view Direction=camera position - vertex position= distance between camera and vertex
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);

				//lightDirection= light direction
				float4 lightDirection = normalize(_WorldSpaceLightPos0);
				float atten = _Atten;

				//diffuse reflection - Lambert
				//float4 diffuseReflection= dot(normalDirection,lightDirection);
				float3 diffuseReflection = atten*_Color*_LightColor0.xyz * max(0.0,dot(normalDirection,lightDirection));

				//specular reflection
				//float3 specularReflection = dot( normalDirection, lightDirection ) * dot( reflect( -lightDirection, normalDirection ), viewDirection;
				float3 specularReflection = atten*_SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

				float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT;

				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;

				//Final
				return float4(lightFinal*_Color.rgb,1.0);

			}

			ENDCG
		}
	}
}
/*

#define ANIMATE

vec2 hash2( vec2 p )
{
// texture based white noise
return texture2D( iChannel0, (p+0.5)/256.0, -100.0 ).xy;

// procedural white noise
//return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 voronoi( in vec2 x )
{
vec2 n = floor(x);
vec2 f = fract(x);

//----------------------------------

vec2 mg, mr;

float md = 8.0;
for( int j=-1; j<=1; j++ )
for( int i=-1; i<=1; i++ )
{
vec2 g = vec2(float(i),float(j));
vec2 o = hash2( n + g );
#ifdef ANIMATE
o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o );
#endif
vec2 r = g + o - f;
float d = dot(r,r);

if( d<md )
{
md = d;
mr = r;
mg = g;
}
}

//----------------------------------

md = 8.0;
for( int j=-2; j<=2; j++ )
for( int i=-2; i<=2; i++ )
{
vec2 g = mg + vec2(float(i),float(j));
vec2 o = hash2( n + g );
#ifdef ANIMATE
o = 0.5 + 0.5*sin( iGlobalTime + 6.2831*o );
#endif
vec2 r = g + o - f;

if( dot(mr-r,mr-r)>0.00001 )
md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
}

return vec3( md, mr );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
vec2 p = fragCoord.xy/iResolution.xx;

vec3 c = voronoi( 8.0*p );

// isolines
vec3 col = c.x*(0.5 + 0.5*sin(64.0*c.x))*vec3(1.0);
// borders
col = mix( vec3(1.0,0.6,0.0), col, smoothstep( 0.04, 0.07, c.x ) );
// feature points
float dd = length( c.yz );
col = mix( vec3(1.0,0.6,0.1), col, smoothstep( 0.0, 0.12, dd) );
col += vec3(1.0,0.6,0.1)*(1.0-smoothstep( 0.0, 0.04, dd));

fragColor = vec4(col,1.0);
}

*/