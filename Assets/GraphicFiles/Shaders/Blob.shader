Shader "Blob"
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
		    
			HLSLPROGRAM
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
      			
                #define PI 3.1415926535897931
                #define TIME _Time.y
      
                float2 mouseCoordinateFunc(float x, float y)
                {
                	return normalize(float2(x,y));
                }

            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////


			static float time;
			static float delta    = 0.20015;
			// static float PI       = 3.1415;
			static int colorIndex = 0;
			static int material   = 0;
			
			const static float3 lightPosition  = float3(3.5,3.5,-1.0);
			const static float3 lightDirection = float3(-0.5,0.5,-1.0);
			
			float displace(float3 p)
			{
				return ((cos(4.*p.x)*sin(4.*p.y)*sin(4.*p.z))*cos(30.1))*sin(time);
			}
			
			float3 rotateX(float3 pos, float alpha) {
				float4x4 trans= {1.0, 0.0, 0.0, 0.0, 0.0, cos(alpha), -sin(alpha), 0.0, 0.0, sin(alpha), cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0};
				return float3(mul(trans,float4(pos, 1.0)).xyz);
			}
			
			
			float3 rotateY(float3 pos, float alpha) {

				float4x4 trans2 = {cos(alpha), 0.0, sin(alpha), 0.0, 0.0, 1.0, 0.0, 0.0,-sin(alpha), 0.0, cos(alpha), 0.0, 0.0, 0.0, 0.0, 1.0};
				
				return float3(mul(trans2,float4(pos, 1.0)).xyz);
			}
			
			float rBox( float3 p, float3 b, float r ){
				return length(max(abs(p)-b,0.0))-r;
			}
			
			
			float minBox( float d1, float d2 ){
				return min(d1,d2);
			}
			
			
				
			float f(float3 position) {
				
				float d, a, b, c, m, n, q, dist;
				d = displace(position);
				b = rBox(rotateY(rotateX(position+ float3(0.5,0.0,-6.0),time*3.0),time*3.0), float3(0.7,0.7,0.7), 0.4);
				c = rBox(position+float3(0,0,-16), float3(25.6,15.6,0.6), 0.2 );
				b = b + d;
				if (c < b) material = 1;
				else material = 0;
				return minBox(c,b);
				
			}
			
			
			float3 ray(float3 start, float3 direction, float t) {
				
				return start + t * direction;
				
			}
			
			
			
			float3 gradient(float3 position) {
			
				return float3(f(position + float3(delta, 0.0, 0.0)) - f(position - float3(delta, 0.0, 0.0)),f(position + float3(0.0,delta, 0.0)) - f(position - float3(0.0, delta, 0.0)),f(position + float3(0.0, 0.0, delta)) - f(position - float3(0.0, 0.0, delta)));
			
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
                
                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                time = TIME;
				// flaot2 uv  = fragCoord.xy / iResolution.xy;
				float3 cam = float3( -0.20, -.5, -3.4 );
				// float aspect = iResolution.x/iResolution.y;
				float3 near = float3(coordinate, 0.0);
			
				time = TIME;
				
				float3 vd = normalize(near - cam);
				vd.x -= .1;
				vd.z -= .0001;
				vd.y -= .08;
				
				float t = 0.0;
				float dst;
				float3 pos;
				float4 color = float4(float3(1.0,1.0,1.0),1.0);
				float3 normal;
				float3 up = normalize(float3(-0.0, 1.0,0.0));
				
			
				for(int i=0; i < 64; i++) {
				
					pos = ray(cam,	vd, t);
					dst = f(pos);
				
					if( abs(dst) < 0.008 ) {
						
						normal = normalize(gradient(pos));
						
						float4 color1 = float4(0.15, 0.19, 0.5,1.0);
						float4 color2 = float4(.10, 0.1, 0.11,1.0);
						
						float4 color3 = lerp(color2, color1, (1.0+dot(up, normal))/2.0);
						color = color3 * max(dot(normal, normalize(lightDirection)),0.0) + float4(0.1,0.1,0.1,1.0);
						
						float3 E = normalize(cam - pos);
						float3 R = reflect(-normalize(lightDirection), normal);
						float specular = pow( max(dot(R, E), 0.0), 8.0);
						color += float4(1.6, 1.4,0.4,0.0)*specular;
						if(material==1) color = float4(0.0,0.0,0.0,1.0);
						color += float4(float3(0.5, 1.0,0.5)*pow(float(i)/128.0*2.1, 2.0) *1.0,1.0);
						break;
						
						
					}
				
					t = t + dst * 1.0;
				
				}	
				
				// return float4(color.xyz, (color.x + color.y + color.z)/3.0);
				return float4(color.xyz, 1.0);
				//(colBase.x + colBase.y + colBase.z)/3.0
                // return float4(coordinateScale, 0.0, 1.0);
				// return float4(right.x, up2.y, 0.0, 1.0);
				// return float4(coordinate3.x, coordinate3.y, 0.0, 1.0);
				// return float4(ro.xy, 0.0, 1.0);

				// float radio = 0.5;
				// float lenghtRadio = length(offset);

    //             if (lenghtRadio < radio)
    //             {
    //             	return float4(1, 0.0, 0.0, 1.0);
    //             }
    //             else
    //             {
    //             	return 0.0;
    //             }


				
			}

			ENDHLSL
		}
	}
}

























