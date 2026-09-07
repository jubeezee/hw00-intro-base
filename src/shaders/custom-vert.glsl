#version 300 es

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.


uniform float u_Time;

// sin(u_Time * 1.7)

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    // deformedpos = modified vs_pos
    vec4 deformedPos = vs_Pos;

    // sin(POSITION * frequency + TIME * speed)

    deformedPos.x += sin(vs_Pos.y * 4.8 + vs_Pos.z * 2.0 + u_Time * 5.0) * 0.05;
    deformedPos.y += cos(vs_Pos.z * 3.2 + vs_Pos.z * 2.0 + u_Time * 3.0) * 0.06;
    deformedPos.z += sin(vs_Pos.x * 3.6 + vs_Pos.y * 2.0 + u_Time * 4.0) * 0.05;

    //deformedPos.x += sin(vs_Pos.y * 3.0 + vs_Pos.z * 2.0 + u_Time * 2.5) * 0.05;
    //deformedPos.y += cos(vs_Pos.x * 2.5 + vs_Pos.z * 2.0 + u_Time * 2.0) * 0.06;
    //deformedPos.z += sin(vs_Pos.x * 3.0 + vs_Pos.y * 2.0 + u_Time * 2.8) * 0.05;

    //deformedPos.x += sin(vs_Pos.y * 3.0 + u_Time * 4.0) * 0.15;
    //deformedPos.y += cos(vs_Pos.x * 2.0 + u_Time * 2.0) * 0.2;
    //deformedPos.z += sin((vs_Pos.x + vs_Pos.y) * 4.0 + u_Time * 3.0) * 0.1;



    vec4 modelposition = u_Model * deformedPos;   // Temporarily store the transformed vertex positions for use below
    
    // export fs_pos (model position) info for our frag shader to use
    fs_Pos = modelposition;

    // export light, a vec made from lightpos - transformed vertex pos
    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    // final screen draw position for the vert
    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
