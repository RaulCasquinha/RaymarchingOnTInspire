u_res = {320, 217}

require 'math'

Mousex = 0
Mousey = 0
angle = 0
function on.mouseMove(x, y)
    Mousex = x
    Mousey = y
    angle = (Mousex/u_res[1]) * 3.1416 * 2
end


-- Useful vector operations

function length(p)
    return math.sqrt((p[1] * p[1] )+ (p[2] * p[2]) + (p[3] * p[3]))
end

function normalize(p)
    local veclength = length(p)
    local newp = {p[1]/veclength, p[2]/veclength, p[3]/veclength}
    return newp
end

function crossProduct(a, b)
    local c = {}
    c[1] = a[2] * b[3] - a[3] * b[2]
    c[2] = a[3] * b[1] - a[1] * b[3]
    c[3] = a[1] * b[2] - a[2] * b[1]
    return c
end

function subtractVectors(a, b)
    return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end

function addVec(a, b)
    return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end

function mulVec(a, b)
    return {a[1] * b[1], a[2] * b[2], a[3] * b[3]}
end

function mulNum(a, b)
    multi = {a[1] * b, a[2] * b, a[3] * b}
    return multi
end

-----------------------------------------


function multiplyRayDirectionWithMatrix(rayd, matrix)
    -- Extend the ray direction vector to 4D, setting the fourth component to 0
    local extendedRayd = {rayd[1], rayd[2], rayd[3], 0}

    local result = {0, 0, 0, 0}

    -- Multiply the extended ray direction with the matrix
    for i = 1, 4 do
        for j = 1, 4 do
            result[i] = result[i] + extendedRayd[j] * matrix[i][j]
        end
    end

    -- We return only the first three components as the result is a direction vector
    return {result[1], result[2], result[3]}
end


function SDFSquare(p)
    local sqr = 1
    local pos = {0,0,0}
    local p = addVec(p, pos)
    local q = {math.abs(p[1]) - sqr, math.abs(p[2]) - sqr, math.abs(p[3]) - sqr}
    local b = length({math.max(q[1], 0), math.max(q[2], 0), math.max(q[3], 0)})
    return  b + math.min(math.max(q[1], math.max(q[2], q[3])),0)
end



function viewMatrix(eye, center, up)
    local f = normalize(subtractVectors(center, eye))
    local s = normalize(crossProduct(f, up))
    local u = crossProduct(s, f)

    return {
        {s[1], u[1], -f[1], 0},
        {s[2], u[2], -f[2], 0},
        {s[3], u[3], -f[3], 0},
        {0.0, 0.0, 0.0, 1}
    }
end


-- Sphere SDF
function SDFSphere(p)
    return length(p) - 1
end

function map(p)
    return SDFSquare(p)
end




function on.paint(gc)


    eye = {math.sin(angle) * 3, 2.0, math.cos(angle) * 3}
    center = {0.0, 0.0, 0.0}
    up = {0.0, 1.0, 0.0}
    matrix = viewMatrix(eye, center, up)

    --Drawing to the screen--
    for y=0,u_res[2],1 do 
        for x=0,u_res[1],1 do
        
            -- UV setup and testing -----
            
            --UV setup
            uv = {x/u_res[1], y/u_res[2]}
            
            -- Invert y
            uv[2] = (uv[2] - 1) * -1
            
            -- Testing
            --color[1] = uv[1]
            --color[2] = uv[2]
            
            ------------------------------
      
            color = {0, 0, 0}
      
            --Raymarching
            uv[1] = (uv[1] * 2) - 1
            uv[2] = (uv[2] * 2) - 1
            rayp = eye
            rayd = {uv[1], uv[2], -1}
            rayd = normalize(rayd)
            rayd = multiplyRayDirectionWithMatrix(rayd, matrix)
            dist = 0.0
            t = 0.0
            for i=0,20,1 do
                t = map(rayp)
                dist = dist + t
                rayp = addVec(rayp, mulNum(rayd, t))
            end
            ---------------------

      
            if dist/6 < 1 then
                color[1] = dist/6
            else
                color[1] = 0
            end
            gc:setColorRGB(color[1] * 255, color[2] * 255, color[3] * 255)
            gc:drawRect(x, y, 1, 1)
        end
    end
end
