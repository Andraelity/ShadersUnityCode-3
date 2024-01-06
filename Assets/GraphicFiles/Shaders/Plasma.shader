Shader "Plasma"
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
			static float2 mouse;
			static float2 resolution;
			
			static const int iters = 256;
			
			static const float origin_z = 0.0;
			static const float plane_z = 4.0;
			static const float far_z = 64.0;
			
			static const float step = (far_z - plane_z) / float(iters) * 0.025;
			
			static const float color_bound = 0.0;
			static const float upper_bound = 1.0;
			
			static const float scale = 32.0;
			
			static const float disp = 0.25;


			float calc_this(float3 p, float disx, float disy, float disz)
			{
				float c = sin(sin((p.x + disx) * sin(sin(p.z + disz)) + time) + sin((p.y + disy) * cos(p.z + disz) + 2.0 * time) + sin(3.0*p.z + disz + 3.5 * time) + sin((p.x + disx) + sin(p.y + disy + 2.5 * (p.z + disz - time) + 1.75 * time) - 0.5 * time));
				return c;
			}
			
			float3 get_intersection(float2 coordinateInput)
			{
				float2 position = coordinateInput * scale;
			
				float3 pos = float3(position.x, position.y, plane_z);
				float3 origin = float3(0.0, 0.0, origin_z);
			
				float3 dir = pos - origin;
				float3 dirstep = normalize(dir) * step;
			
				dir = normalize(dir) * plane_z;
			
			
				float c;
			
				for (int i=0; i<iters; i++)
				{
					c = calc_this(dir, 0.0, 0.0, 0.0);
			
					if (c > color_bound)
					{
						break;
					}
			
					dir = dir + dirstep;
				}
			
				return dir;
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

                float3 p = get_intersection(coordinate);
				float dx = color_bound - calc_this(p, disp, 0.0, 0.0);
				float dy = color_bound - calc_this(p, 0.0, disp, 0.0);
			
				float3 du = float3(disp, 0.0, dx);
				float3 dv = float3(0.0, disp, dy);
				float3 normal = normalize(cross(du, dv));
			
				float3 light = normalize(float3(0.0, 0.0, 1.0));
				float l = dot(normal, light);
			
				float cc = pow(l, 2.0);
				float4 fragColor = float4(cc*0.8, cc*0.5, cc*0.2, cc);

				return float4(fragColor.xyz,1.0);
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

























