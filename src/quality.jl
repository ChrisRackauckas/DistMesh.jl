"""
Determine the quality of a triangle given 3 points.

Points must be 3D.
"""
function triqual(p1, p2, p3)
    d12 = p2 - p1
    d13 = p3 - p1
    d23 = p3 - p2
    n   = cross(d12,d13)
    vol = sqrt(sum(n.^2))
    den = dot(d12,d12) + dot(d13,d13) + dot(d23,d23)
    return sqrt(3)*2*vol/den
end

function triangle_qualities(p,tets)
    tris = NTuple{3,Int}[]
    tets_to_tris!(tris, tets)
    qualities = Vector{Float64}(undef,length(tris))
    triangle_qualities!(tris,qualities,p,tets)
end

function triangle_qualities!(tris,triset,qualities,p,tets)
    tets_to_tris!(tris,triset,tets)
    resize!(qualities, length(tris))
    for i in eachindex(tris)
        tp = tris[i]
        qualities[i] = triqual(p[tp[1]], p[tp[2]], p[tp[3]])
    end
    qualities
end

function triangle_qualities!(tris::Vector,qualities::Vector,p,tets)
    triangle_qualities!(tris,Set{eltype(tris)}(),qualities,p,tets)
end

const ⋅ = dot
const × = cross

function dihedral(p0,p1,p2,p3)\
    b1 = p1 - p0
    b2 = p2 - p1
    b3 = p3 - p2

    abs(atan(((b1×b2)×(b2×b3))⋅normalize(b2), (b1×b2)⋅(b2×b3)))
end

"""
    Compute dihedral angles within a tetrahedra
    radians
"""
function dihedral_angles(p,t)
    AT = eltype(eltype(p))
    nangs = length(t)*6
    a = fill(zero(AT), nangs)
    for i in 1:length(t)
        t1, t2, t3, t4 = t[i]
        a[i*6-5] = dihedral(p[t1],p[t2],p[t3],p[t4])
        a[i*6-4] = dihedral(p[t1],p[t2],p[t4],p[t3])
        a[i*6-3] = dihedral(p[t2],p[t1],p[t4],p[t3])
        a[i*6-2] = dihedral(p[t2],p[t3],p[t4],p[t1])
        a[i*6-1] = dihedral(p[t2],p[t1],p[t3],p[t4])
        a[i*6]   = dihedral(p[t3],p[t1],p[t2],p[t4])
    end
    a
end

"""
    Compute the minimum dihedral angle within a tetrahedra
    radians
"""
function min_dihedral_angles(p,t)
    AT = eltype(eltype(p))
    nangs = length(t)
    a = fill(zero(AT), nangs)
    for i in 1:length(t)
        t1, t2, t3, t4 = t[i]
        d = (dihedral(p[t1],p[t2],p[t3],p[t4]),
             dihedral(p[t1],p[t2],p[t4],p[t3]),
             dihedral(p[t2],p[t1],p[t4],p[t3]),
             dihedral(p[t2],p[t3],p[t4],p[t1]),
             dihedral(p[t2],p[t1],p[t3],p[t4]),
             dihedral(p[t3],p[t1],p[t2],p[t4]))
        a[i] = minimum(d)
    end
    a
end
