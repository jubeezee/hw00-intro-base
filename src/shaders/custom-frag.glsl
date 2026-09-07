#version 300 es


precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
uniform float u_Time;
uniform vec3 u_CameraPos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


// hash3 repeatable pseudo-random vec3 for 3d grid
vec3 random3(vec3 p) {
    p = vec3(
        dot(p, vec3(127.1, 311.7, 74.7)),
        dot(p, vec3(269.5, 183.3, 246.1)),
        dot(p, vec3(113.5, 271.9, 124.6))
    );

    return fract(sin(p) * 43758.5453);
}

// worley noise
float worley(vec3 p) {
    vec3 cell = floor(p);
    vec3 local = fract(p);

    float minDist = 100.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            for (int z = -1; z <= 1; z++) {

                vec3 neighbor = vec3(
                    float(x),
                    float(y),
                    float(z)
                );

                // Random feature point inside this neighboring cell
                vec3 featurePoint = random3(cell + neighbor);

                // Vector from our point to that feature point
                vec3 diff = neighbor + featurePoint - local;

                float dist = length(diff);

                minDist = min(minDist, dist);
            }
        }
    }

    return minDist;
}


void main()
{
    // Material base color (before shading)

        // different positions forr each layer of worley
        vec3 noisePos1 = fs_Pos.xyz;
        vec3 noisePos2 = fs_Pos.xyz;
        vec3 noisePos3 = fs_Pos.xyz;

        // if this position is 

        // different tiny skews (add some sort of random), 
        // at different utime speeds in 3 different dirs
        // position.axis += wave(time * SPEED) * DISTANCE;
        noisePos1.x += sin(u_Time * 2.0) * 0.13; // time 1.7
        noisePos1.y += cos(u_Time * 1.5) * 0.11; // time 1.2
        noisePos1.z += sin(u_Time * 1.72) * 0.12; // ttime 1.42

        noisePos2.x += cos(u_Time * 0.8) * 0.23;
        noisePos2.y += sin(u_Time * 0.88) * 0.4;
        noisePos2.z += cos(u_Time * 0.79) * 0.33;

        noisePos3.x += cos(u_Time * 0.65) * 0.17;
        noisePos3.y += sin(u_Time * 0.75) * 0.2;
        noisePos3.z += sin(u_Time * 0.70) * 0.14;

        // noisePos.x += u_Time * 0.1;
        // pass in fs_pos into worley to get noise result
        // larger multiplier = smaller the worley beads
        float wNoise1 = worley(noisePos1 * 1.75); // big worley
        float wNoise2 = worley(noisePos2 * 2.5); // medium worley
        float wNoise3 = worley(noisePos3 * 4.0); // small worley

        // big worley
        vec3 deepBlue1 = vec3(0.0, 0.835, 0.859);
        vec3 blueHighlight1 = vec3(0.718, 0.992, 1.0);
        vec3 white1 = vec3(0.914, 1.0, 0.871);
        //vec3 white1 = vec3(0.878, 1.0, 0.82);
        //vec3 white1 = vec3(0.957, 1.0, 0.89);
        // 

        // big color
        // i want white part (wnoise higher) to be white and black part (wnoise lower) to be blue
        // higher the wnoise, the whiter.
        float t1 = pow(wNoise1, 5.2); //4.2

        vec3 bigColor;


        
        if (t1 < 0.5) {
            bigColor = mix(deepBlue1, blueHighlight1, t1 * 2.0);
        } else {
            bigColor = mix(blueHighlight1, white1, (t1 - 0.5) * 2.0);
        }
        

        // get the vec3 colors of thte medium worley and small worley?
        // then mix them later

        // medium worley
        vec3 deepBlue2 = vec3(0.0, 0.349, 0.51);
        vec3 blueHighlight2 = vec3(0.153, 0.584, 0.769);
        //vec3 blueHighlight2 = vec3(0.263, 0.8, 0.851);
        vec3 white2 = vec3(0.459, 0.714, 0.949);
        //vec3 white2 = vec3(0.737, 0.886, 0.902);



        float t2 = pow(wNoise2, 2.5);

        // medium color
        vec3 mediumColor;
        
        if (t2 < 0.5) {
            mediumColor = mix(deepBlue2, blueHighlight2, t2 * 2.0);
        } else {
            mediumColor = mix(blueHighlight2, white2, (t2 - 0.5) * 2.0);
        }


        // small worley
        vec3 deepBlue3 = vec3(0.0, 0.341, 0.49);
        vec3 blueHighlight3 = vec3(0.047, 0.459, 0.529);
        //vec3 white3 = vec3(0.071, 0.588, 0.678); // blue
        //vec3 white3 = vec3(0.443, 0.529, 0.859); // testt red
        vec3 white3 = vec3(0.165, 0.396, 0.769); // testt red 2


        float t3 = pow(wNoise3, 2.0);

        // small color
        vec3 smallColor;
        
        if (t3 < 0.5) {
            smallColor = mix(deepBlue3, blueHighlight3, t3 * 2.0);
        } else {
            smallColor = mix(blueHighlight3, white3, (t3 - 0.5) * 2.0);
        }



        vec3 finalColor = bigColor;

    
        // FRESNEL
        // ill add a bit of FRESNEL (lighter at glancing angles -- its cyan ish and not white tho)
        // dot between surface normal and view normal. aligned (high dot) = no/low fresnel
        vec3 viewDir = normalize(u_CameraPos - fs_Pos.xyz);

        float fresnel = 1.0 - abs(dot(normalize(fs_Nor.xyz), viewDir)); 

        finalColor += vec3(0.851, 1.0, 0.349) * fresnel * 0.2; // add slightly green/cyan based on fresnel level
        // vec3(0.886, 1.0, 0.957) blue/cyan

        float bigGap = 1.0 - clamp(t1, 0.0, 1.0);


        // bigColor influence, then blend mediumColor influence 30%, smallColor = 20%
        finalColor = mix(finalColor, mediumColor, t2 * 0.46 * bigGap); // 0.25
        finalColor = mix(finalColor, smallColor, t3 * 0.30 * bigGap); // used to be 0.15 - 0.18
        
        // deepen the darks finalColor *= mix(0.65, 1.0, clamp(t1, 0.0, 1.0));


        //vec3 color = mix(deepBlue, white, pow(wNoise, 3.0));
        // diffuseColor = result of noise
       // vec4 diffuseColor = u_Color;

        // lerp between 0.2 and 0.9 depending on t (clamped between 0 and 1)
        // alphas for other ts are given smaller ranges

        float alpha1 = mix(0.22, 0.9, clamp(t1, 0.0, 1.0));
        float alpha2 = mix(0.2, 0.7, clamp(t2, 0.0, 1.0));
        float alpha3 = mix(0.2, 0.5, clamp(t3, 0.0, 1.0));

        // make final alpha, finalalpha = alpha1, then mix in the others
        float finalAlpha = alpha1;
        finalAlpha = mix(finalAlpha, alpha2, 0.39);
        finalAlpha = mix(finalAlpha, alpha3, 0.23);

        vec4 diffuseColor = vec4(finalColor, finalAlpha);

        // adding in Lambert

        // Calculate the diffuse term for Lambert shading
        // how much diffuse lightt should come through
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));


        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.5;

        //float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.
        float lightIntensity = mix(0.5, 1.0, diffuseTerm); // 0.5 is the lowest itll go, 1 is the highest
                                                            // interpolated ebtween 0.5 and 1 using diffuseTerm

        vec3 litColor = diffuseColor.rgb * lightIntensity;

        // t1 (big worley's white highlights) = caustics
        //float caustic = clamp(t1, 0.0, 1.0);

        float caustic = smoothstep(0.5, 0.96, t1); // this one is sharper (below 0.5 no boost)

        // boost the light colors, when caustic is high (aka this is a white bright spot), add more boost
        litColor += white1 * caustic * 0.16;

        // final shaded color is the updated litColor
        out_Col = vec4(litColor, diffuseColor.a);



        // Compute final shaded color
        //out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
