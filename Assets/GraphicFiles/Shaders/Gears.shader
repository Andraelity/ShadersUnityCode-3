Shader "Gears"
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
    
float square(in float x, in float y){
    return sqrt(x*x*x*x+y*y*y*y);
}

float4 gradient (in float2 uv){
    float2 loc = - uv * float2(2.0,2.0) - float2(-1.0, -1.0);
    loc.x *= 1;
    float loadF3 = 1.0-length(float2(loc.x,loc.y))/4.0;
    return float4(float3(loadF3, loadF3, loadF3),1.0);
}

float4 gear(in float2 uv, in float2 pos, in float r, in float n, in float3 col){
    
    float2 loc = (pos - uv) * float2(2.0,2.0) - float2(-1.0, -1.0);
    loc.x *= 1;
    float a = (atan2(loc.x,loc.y)/PI/2.0)+0.5+TIME/n;
    float c = length(float2(loc.x, loc.y))/r;
    float t = 4.0*square((fmod(a*n,1.0)-0.5)*1.6, (c-0.5)*1.5);
    float g = min(c,t);
    g = max(g, 1.0-c*2.0);
    
    if (g < 0.5) return float4(col, 1.0);
    else if (g < 0.6) return float4(col*0.6, 1.0);
    else return float4(0.0, 0.0, 0.0, 0.0);
}

float4 blend(in float4 c1, in float4 c2){
    return float4(c1.rgb*(1.0-c2.a)+c2.rgb*(c2.a), max(c1.a,c2.a));
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
                float3 col  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                
                float2 uv = coordinateScale2;
                

                float4 colOut = gradient(uv);
                colOut = blend(colOut, gear(uv, float2(0.0,0.0), 0.5, -6.0, float3(1.0,0.9,0.1)));
                colOut = blend(colOut, gear(uv, float2(0.205,0.089), 0.5, 6.0, float3(0.95,0.0,0.0)));
                colOut = blend(colOut, gear(uv, float2(-0.235,-0.21), 0.75, 9.0, float3(0.1,0.2,0.9)));
                colOut = blend(colOut, gear(uv, float2(0.404,0.39), 0.75, -9.0, float3(0.0,0.95,0.0)));
                colOut = blend(colOut, gear(uv, float2(-0.47,-0.0), 0.5, -6.0, float3(0.95,0.0,0.0)));
                colOut = blend(colOut, gear(uv, float2(0.26,-0.18), .5/6.*4., -4.0, float3(0.1,0.2,0.9)));
            
                


                return float4(colOut);

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

























