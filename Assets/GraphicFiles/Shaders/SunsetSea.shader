Shader "SunsetSea"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

                  UNITY_INSTANCING_BUFFER_START(CommonProps)
                  UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
                  UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)

                  UNITY_INSTANCING_BUFFER_END(CommonProps)

            

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
                sampler2D _TextureChannel0;
                sampler2D _TextureChannel1;
                sampler2D _TextureChannel2;
                sampler2D _TextureChannel3;
      			
                #define PI 3.1415927
                #define TIME _Time.y
      
                float2 mouseCoordinateFunc(float x, float y)
                {
                	return normalize(float2(x,y));
                }
            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////
    
const bool USE_MOUSE = false; // Set this to true for God Mode :)

// const float PI = 3.14159265;
const float MAX_RAYMARCH_DIST = 150.0;
const float MIN_RAYMARCH_DELTA = 0.00015; 
const float GRADIENT_DELTA = 0.015;
float waveHeight1 = 0.005;
float waveHeight2 = 0.004;
float waveHeight3 = 0.001;
float2 mouse;


float3 mod289(float3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 permute(float3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(float2 v)
{
  const float4 C = float4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                          0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                         -0.577350269189626,  // -1.0 + 2.0 * C.x
                          0.024390243902439); // 1.0 / 41.0
// First corner
  float2 i  = floor(v + dot(v, C.yy) );
  float2 x0 = v -   i + dot(i, C.xx);

// Other corners
  float2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
        + i.x + float3(0.0, i1.x, 1.0 ));

  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  float3 x = 2.0 * frac(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  float3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// --------------------- END of SIMPLEX NOISE


float map(float3 p) {
    return p.y + (0.5 + waveHeight1 + waveHeight2 + waveHeight3) 
        + snoise(float2(p.x + TIME * 0.4, p.z + TIME * 0.6)) * waveHeight1
        + snoise(float2(p.x * 1.6 - TIME * 0.4, p.z * 1.7 - TIME * 0.6)) * waveHeight2
        + snoise(float2(p.x * 6.6 - TIME * 1.0, p.z * 2.7 + TIME * 1.176)) * waveHeight3;
}

float3 gradientNormalFast(float3 p, float map_p) {
    return normalize(float3(
        map_p - map(p - float3(GRADIENT_DELTA, 0, 0)),
        map_p - map(p - float3(0, GRADIENT_DELTA, 0)),
        map_p - map(p - float3(0, 0, GRADIENT_DELTA))));
}

float intersect(float3 p, float3 ray_dir, out float map_p, out int iterations) {
    iterations = 0;
    if (ray_dir.y >= 0.0) { return -1.0; } // to see the sea you have to look down
    
    float distMin = (- 0.5 - p.y) / ray_dir.y;
    float distMid = distMin;
    for (int i = 0; i < 50; i++) {
        //iterations++;
        distMid += max(0.05 + float(i) * 0.002, map_p);
        map_p = map(p + ray_dir * distMid);
        if (map_p > 0.0) { 
            distMin = distMid + map_p;
        } else { 
            float distMax = distMid + map_p;
            // interval found, now bisect inside it
            for (int i = 0; i < 10; i++) {
                //iterations++;
                distMid = distMin + (distMax - distMin) / 2.0;
                map_p = map(p + ray_dir * distMid);
                if (abs(map_p) < MIN_RAYMARCH_DELTA) return distMid;
                if (map_p > 0.0) {
                    distMin = distMid + map_p;
                } else {
                    distMax = distMid + map_p;
                }
            }
            return distMid;
        }
    }
    return distMin;
}


            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);
                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);

                
                float2 coordinate = i.uv;
                
                float2 coordinateBase = i.uv/(float2(2.0, 2.0));
                
                float2 coordinateScale2 = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                
                

                
                float2 var = coordinate;
                mouse = mouseCoordinate;
                float waveHeight =  cos(TIME * 0.03) * 2.5 + 1.6;
                waveHeight1 *= waveHeight;
                waveHeight2 *= waveHeight;
                waveHeight3 *= waveHeight;
                
                float2 position = coordinate;
                // position *= 2.0;
                float3 ray_start = float3(0, 0.2, -2);
                float3 ray_dir = normalize(float3(position,0) - ray_start);
                ray_start.y = cos(TIME * 0.5) * 0.2 - 0.25 + sin(TIME * 2.0) * 0.05;
                
                const float dayspeed = 1;
                float subtime = max(-0.16, sin(TIME * dayspeed) * 0.2);
                float middayperc = USE_MOUSE ? mouse.y * 0.3 - 0.15 : max(0.0, sin(subtime));
                float3 light1_pos = float3(0.0, middayperc * 200.0, USE_MOUSE ? 200.0 : cos(subtime * dayspeed) * 200.0);
                float sunperc = pow(max(0.0, min(dot(ray_dir, normalize(light1_pos)), 1.0)), 190.0 + max(0.0,light1_pos.y * 4.3));
                float3 suncolor = (1.0 - max(0.0, middayperc)) * float3(1.5, 1.2, middayperc + 0.5) + max(0.0, middayperc) * float3(1.0, 1.0, 1.0) * 4.0;
                float3 skycolor = float3(middayperc + 0.8, middayperc + 0.7, middayperc + 0.5);
                float3 skycolor_now = suncolor * sunperc + (skycolor * (middayperc * 1.6 + 0.5)) * (1.0 - sunperc);
                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float map_p = 0;
                int iterations = 0;
                float dist = intersect(ray_start, ray_dir, map_p, iterations);
                if (dist > 0.0) {
                    float3 p = ray_start + ray_dir * dist;
                    float3 light1_dir = normalize(light1_pos - p);
                    float3 n = gradientNormalFast(p, map_p);
                    float3 ambient = skycolor_now * 0.1;
                    float3 diffuse1 = float3(1.1, 1.1, 0.6) * max(0.0, dot(light1_dir, n)  * 2.8);
                    float3 r = reflect(light1_dir, n);
                    float3 specular1 = float3(1.5, 1.2, 0.6) * (0.8 * pow(max(0.0, dot(r, ray_dir)), 200.0));       
                    float fog = min(max(p.z * 0.07, 0.0), 1.0);
                           color.rgb = (float3(0.6,0.6,1.0) * diffuse1 + specular1 + ambient)  * (1.0 - fog) + skycolor_now * fog;
                    } else {
                        color.rgb = skycolor_now.rgb;
                    }
        
                return color;
                // return float4(color, 1.0);

                // col = tex2D(_TextureChannel0, coordinate);
                // return float4(col,1.0) ;
                // 
                // if (colFour.x >= 0.01)
                // {
                	// return colFour;
                // }
                // else
                // {
                	// return float4(col2, 1.0);
                // }


				
			}

			ENDCG
		}
	}
}

























