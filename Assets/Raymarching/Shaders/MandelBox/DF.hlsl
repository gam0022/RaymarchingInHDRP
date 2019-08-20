#define GBUFFER_MARCHING_ITERATION       300
#define SHADOWCASTER_MARCHING_ITERATION  64
#define MOTIONVECTORS_MARCHING_ITERATION 64

float dMandel(float3 p, float scale, int n) {
     float4 q0 = float4 (p, 1.);
     float4 q = q0;
 
     for ( int i = 0; i < n; i++ ) {
         q.xyz = clamp( q.xyz, -1.0, 1.0 ) * 2.0 - q.xyz;
         q = q * scale / clamp( dot( q.xyz, q.xyz ), 0.5, 1.0 ) + q0;
     }
 
     return length( q.xyz ) / abs( q.w );
 }
 
 float _MandelScale = 2.9;
 
 float distanceFunction(float3 p) {
     //p *= scale;
     //p.yx = pmod(p.yx, (sin(_Time.y) * 0.5 + 0.5) * 4.0 + 4.0);
     //return dMenger(p, float3((sin(_Time.y) * 0.5 + 0.5) + 1.0, (sin(_Time.y*0.7) * 0.5 + 0.5) + 1.0, (sin(_Time.y*0.4) * 0.5 + 0.5) + 1.0), 3.0) / scale;
     
     float s = 20.0;
     p *= s;
     return dMandel(p, _MandelScale, 20.0) / s;
 }

DistanceFunctionSurfaceData getDistanceFunctionSurfaceData(float3 p) {
    DistanceFunctionSurfaceData surface = initDistanceFunctionSurfaceData();
    surface.Position = p;
    surface.Normal   = normal(p, 0.0001);
    surface.Occlusion = ao(p, surface.Normal, 1.0);
    // Normally BentNormal is the average direction of unoccluded ambient light, but AO * Normal is used instead because of high calculation load.
    surface.BentNormal = surface.Normal * surface.Occlusion;
    surface.Albedo = float3(1.0, 1.0, 1.0);
    surface.Smoothness = 0.6;
    surface.Metallic = 0.0;

    float3 positionOS = TransformWorldToObject(surface.Position);
    float distanceFromCenter = length(positionOS);

    // https://github.com/FMS-Cat/type
    /*float emissive = saturate(sin(-_Time.y * 6.0 + distanceFromCenter * 15.0));
    float edge = saturate( pow( length( surface.Normal - normal( surface.Position, 0.005 ) ) * 2.0, 2.0 ) );
    surface.Emissive = float3(80000.0, 8000., 800.) * edge * saturate(emissive);*/
    return surface;
}