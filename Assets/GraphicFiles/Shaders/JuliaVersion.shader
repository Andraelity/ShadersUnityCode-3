Shader "JuliaVersion"
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

                
                

                
                float2 p = coordinateScale2;
                
                
                float modeTimer = TIME;
            
                float vignetteVal = 1.5 - 2.0 * length( p - float2( .5, .5 ) );
                float progress = 1.0 - frac( modeTimer * .05 );//.5 + .5 * cos( modeTimer * 0.15 );
                progress *= 1.0;
                float phase = pow( progress, 6.0 ) * 1.0;
                float scale = pow( progress, 6.0 ) * .4  + .00003;
                float sinuses = pow( 1.0 - progress, 0.5 );
                float angle = pow( progress, 3.0 ) * 4.0;
                float2 rot = float2( sin(angle), -cos( angle) );
                p = (-1.5 + 3.0*p) * float2(1.7,1.0);
                
                float2 pRotated = float2( rot.x * p.x - rot.y * p.y, rot.y * p.x + rot.x * p.y );
                
                float fractZScale = 1.0 + pow( progress, 1.5 ) * 19.0;
                sinuses = -.3 + 5.8 * sinuses;
                //sinuses = .3 - 20.0 * progress * (progress - 1.0 );
            
            
                float2 cc = float2( 0.1 + sin( phase ) * .2, 0.61 - sin( phase ) * .2) * 1.0;
                
                float3 dmin = float3( 1000.0, 1000.0, 1000.0 );
                float3 norm = float3( 0.0, 0.0, 0.0 );
                float2 z = scale * pRotated + float2( -.415230, -.568869);
                for( int i=0; i<48; i++ )
                {
                    z = cc + float2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
                    z += 0.15*sin(float(i));
                    norm.y = dot( z, z );
                    norm.x = norm.y + 0.1 * z.y / ( z.x * z.x + .01) + sinuses * sin(1.0 * norm.y ) ;
                    norm.z = 0.1 / length( frac( z * fractZScale ) - 0.5 );
                    norm.z *= norm.z;
                    
                    //norm = .050 * ( prev + norm );
                    
                    
                    dmin = min(dmin, norm );
                }

                float val = ( dmin.x - dmin.y + .83 );
                                            
                float inWeight = clamp( norm.z * 1.0, .0, 1.0 );
                float3 colorIn = lerp(float3( 1.3, .984, .820 ), float3( 1.8, .3, -.2 ), inWeight );
                
                float outWeight = clamp( 3.0 -5.0 *  norm.z, .0, 1.0 );
                float3 colorOut = lerp( float3( 0.7, .2, .3 ), float3( .173, .0, .137 ), outWeight );
                             
                
                float backgroundBlack = clamp(.3 * val * (vignetteVal - .5 ), .0, 1.0 );
                float backgroundWhite = clamp(-.3 * val, .0, 1.0 );
                val =  clamp( val * 3.0, .0, 1.0 );
                float3 color = lerp( float3( 1.3, .984, .820 ), float3( .173, .0, .137 ), val );
                
                color = lerp( color, colorOut, backgroundBlack * 1.0);
                color = lerp( color, colorIn, backgroundWhite * 1.0);
                
                
                color *= vignetteVal;
    

                return float4(color, 1.0);

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

























