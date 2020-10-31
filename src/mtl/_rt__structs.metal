/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   _rt__structs.metal                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By§: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/10/14 01:53:59 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/14 01:53:59 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <metal_stdlib>
using namespace metal;

constant const float pi = 3.14159265358979323846f;

typedef struct		Ray {
	float3 pos;
	float3 dir;
	float max;
	float min;
	Ray() : pos(0.0f), dir(1.0f), max(INFINITY), min(0) {};
	Ray(	float3 p, float3 d,
	float max = INFINITY, float min = 0.0 )
	: pos(p), dir(normalize(d)), max(max), min(min) {};
} Ray;

enum e_obj_type
{
	OBJ_NONE = 0,
	OBJ_PLANE,
	OBJ_SPHERE,
	OBJ_CYLINDER,
	OBJ_CONE,
	OBJ_GEOMETRY
};

struct				s_sphere
{
	packed_float3	pos;
	float			r;
};

struct				s_plane
{
	packed_float3	n;
	float			d;
};

union				u_obj_content
{
	struct s_sphere		sphere;
	struct s_plane		plane;
};

struct				s_obj
{
	int						id;
	int						material_id;
	enum e_obj_type			type;
	union u_obj_content		content;
};

struct				s_cam
{
	int				id;
	packed_float3	pos;
	packed_float3	forward;
	packed_float3	up;
	packed_float3	right;
	packed_float2	fov;
};

struct				s_mat
{
	int				id;
	float 			metalness;
	float 			roughness;
	float 			ior;
	float 			transparency;
	packed_float3	albedo;
	packed_float3	f0;
};

#define RT_MAX_OBJECTS 128
#define RT_MAX_CAMERAS 16
#define RT_MAX_MATERIALS 32

typedef struct		s_scn
{
	int				id;
	struct s_obj	objects[RT_MAX_OBJECTS];
	int				objects_num;
	struct s_cam	cameras[RT_MAX_CAMERAS];
	int				cameras_num;
	int				camera_active;
	struct s_mat	materials[RT_MAX_MATERIALS];
	int				materials_num;
	struct t_light	*lights;
	int 			light_num;
}					t_scn;

