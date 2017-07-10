Shader "Custom/UI/Common/StencilMask"
{
    Properties
    {
        _MainTex          ("Base (RGB)",  2D)  = "white" {}
        _StencilReference ("Stencil ID",  Int) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"           = "Transparent+1"
            "IgnoreProjector" = "True"
        }

        ZWrite On
        AlphaTest Greater 0.5
        ZTest Always

        Stencil
        {
            Ref  [_StencilReference]
            Comp always
            Pass replace
        }


        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex  : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f output;
                output.vertex   = mul(UNITY_MATRIX_MVP, v.vertex);
                output.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return output;
            }

            fixed4 frag (v2f input) : COLOR
            {
                fixed4 col = tex2D(_MainTex, input.texcoord);

                // cut off trransparent part
                if (col.a < 0.1) {
                    discard;
                }

                return col;
            }
            ENDCG
        }
    }

}
