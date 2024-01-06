Shader "Tunnel"
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

            float tunnel(float3 p)
            {
            	return cos(p.x) + cos(p.y * 1.5) + cos(p.z) + cos(p.y * 20.0) * 0.05;
            }

            float ribbon(float3 p)
        	{
        		return length(max(abs(p - float3(cos(p.z * 1.5) * 0.3, -0.5 + cos(p.z) * 0.2, 0.0)) - float3(0.125, 0.02, TIME + 3.0), float3(0.0,0.0,0.0)));
        	}

        	float scene(float3 p)
        	{
        		return min(tunnel(p), ribbon(p));
        	}

        	float3 getNormal(float3 p)
        	{
        		float3 eps = float3( 0.1, 0.0, 0.0);
        		return normalize(float3(scene(p + eps.xyy), scene(p + eps.yxy), scene(p + eps.yyx)));
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
                // float2 coordinateBase = i.uv;

                float2 coordinate = i.uv;

				float2 coordinateHalf = i.uv /float2(2, 2);
                // float2 scaleResolution = i.uv /float2(2, 2);

                // float2 coordinateScale = (coordinateBase + 1.0 )/ float2(4.0,2.0);

                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);

    			// float2 coordinateScale = float2(scaleResolution.x + 1.0 + _rangeZero_Ten,scaleResolution.y + 1.0 + _rangeSOne_One);

                //Test Output 
                float3 col  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


                float4 color = 0.0;
                float3 org = float3(sin(TIME) * 0.5, cos(TIME * 0.5) * 0.25 + 0.25, TIME);
                float3 dir = normalize(float3(coordinate.x * 1.6, coordinate.y, 1.0));
                float3 p = org;
                float3 pp;
                float d = 0.0;

                for(int i = 0; i < 64; i++)
                {
                	d = scene(p);
                	p += d * dir;
                }

                pp = p;

                float f = length(p - org) * 0.02;

                dir = reflect(dir, getNormal(p));

              	p += dir;
              	for(int i = 0; i < 32; i++)
              	{
              		d = scene(p);
              		p += d * dir;
              	}

              	color = max(dot(getNormal(p), float3(0.1, 0.1, 0.0)), 0.0) + float4(0.3, cos(TIME * 0.5) * 0.5 + 0.5, sin(TIME * 0.5) * 0.5 + 0.5 ,1.0) * min(length(p - org) * 0.04, 1.0);

              	if(tunnel(pp) > ribbon(pp))
              	{
              		color = lerp(color, float4(cos(TIME * 0.3) * 0.5 + 0.5, cos(TIME * 0.2) * 0.5 + 0.5, sin(TIME * 0.3) * 0.5 + 0.5, 1.0), 0.3);
          		}

          		float4 fcolor = ((color + float4(f, f, f, f)) + (1.0 - min(pp.y + 1.9, 1.0)) *  float4(1.0, 0.8, 0.7, 1.0)) * min(TIME * 0.5, 1.0);


                return float4(fcolor.xyz, 1.0);


				
			}

			ENDCG
		}
	}
}

























