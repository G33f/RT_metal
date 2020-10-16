/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   metal_shader.h                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/09/11 18:31:27 by wpoudre           #+#    #+#             */
/*   Updated: 2020/09/11 18:31:29 by wpoudre          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef METAL_SHADER_H

# define METAL_SHADER_H

# define WIN_WIDTH	1920
# define WIN_HEIGHT	1080
# define ALPHA_MAX	255
# define COLOR_MAX	255
# define RT_MAX_OBJECTS 128
# define RT_MAX_MATERIALS 32
# define RT_MAX_LIGHTS 16
# define RT_MAX_CAMERAS 16

typedef packed_float4	t_color;

typedef enum		e_shape_type
{
	NONE = 0,
	CONE,
	SPHERE,
	PLANE,
	CYLINDER
}					t_shape_type;

typedef enum		e_camera_projection
{
	PROJECTION_ORTOGRAPHIC,
	PROJECTION_PERSPECTIVE
}					t_projection;

typedef struct		Ray
{
	float3 pos;
	float3 dir;
	float max;
	float min;
	Ray() : pos(0.0f), dir(1.0f), max(INFINITY), min(0) {};
	Ray(	float3 p, float3 d,
	float max = INFINITY, float min = 0.0 )
	: pos(p), dir(normalize(d)), max(max), min(min) {};
} 					Ray;

typedef struct		s_material
{
	packed_float3	color;
	packed_float3	f0;
	float			ior;
	float 			roughness;
	float 			metalness;
}					t_material;

typedef struct		s_sphere
{
	packed_float3	center;
	float			radius;
}					t_sphere;

typedef struct		s_cone
{
	packed_float3	head;
	packed_float3	tail;
	float			radius;
}					t_cone;

typedef struct		s_plane
{
	packed_float3	center;
	packed_float3	normal;
}					t_plane;

typedef struct		s_cylinder
{
	packed_float3	head;
	packed_float3	tail;
	float			radius;
}					t_cylinder;

typedef union		u_shape
{
	t_sphere		sphere;
	t_cone			cone;
	t_plane			plane;
	t_cylinder		cylinder;
}					t_shape;

typedef struct		s_obj
{
	t_shape			obj;
	t_shape_type	type;
	t_material		material;
}					t_obj;

typedef	struct		s_light
{
	size_t			id;
	packed_float3	pos;
	packed_float3	col;
	float			power;
}					t_light;

struct				s_cam
{
	int				id;
	packed_float3	pos;
	packed_float3	forward;
	packed_float3	up;
	packed_float3	right;
	packed_float2	fov;
};

typedef struct		t_scn
{
	int				id;
	struct s_obj	objects[RT_MAX_OBJECTS];
	int				obj_num;
	struct s_cam	cameras[RT_MAX_CAMERAS];
	int				cam_num;
	int				camera_active;
	struct s_mat	materials[RT_MAX_MATERIALS];
	int				mat_num;
	struct s_light	lights[RT_MAX_LIGHTS];
	int 			light_num;
}					t_scn;

typedef struct		s_ggx_loop
{
	Ray				normal;
	Ray				cam_ray;
	t_scn			*scene;
	t_light			*lamp;
	t_material		*mat;
}					t_ggx_loop;

bool				vec_point_is_behind(float3 vec_from_zero, float3 point);
bool				ray_point_is_behind(Ray ray, float3 point);
float				num_clamp(float val, float min, float max);
float3				vec_clamp(float3 source, float min, float max);
float3				vec_to_srgb(float3 v);
t_color				col_from_vec_norm(float3 vector);
float3				fresnel_schlick(float3 f0, float cos_theta);
float				trace_dot_plane(Ray ray, t_obj *fig);
float				trace_dot_cap(Ray ray, Ray plane_ray);
float				trace_dot_sphere(Ray ray, t_obj *fig);
float3				cone_intersect(Ray ray, t_cone cone, float3 v);
float				trace_dot_cone(Ray ray, t_obj *fig);
float3				cylinder_intersect(Ray ray, t_cylinder cyl, float3 v);
float				trace_dot_cylinder(Ray ray, t_obj *fig);
float				trace_dot_fig(Ray ray, t_obj *fig);
t_obj				*rt_trace_nearest_dist(t_scn *scene, Ray ray, float *dist);
float3				trace_normal_plane(Ray ray, t_obj *fig);
float3				trace_normal_sphere(Ray ray, t_obj *fig);
float3				trace_normal_cone(Ray ray_in, t_obj *fig);
float3				trace_normal_cylinder(Ray ray, t_obj *fig);
float3				trace_normal_fig(Ray ray, t_obj *fig);
t_color				rt_trace(t_scn *scene, Ray ray, t_trace_mode mode);
Ray					project_geRay_from_coords(t_cam *cam, double x, double y);
float				ggx_distribution(float cos_theta_nh, float alpha);
float3				cook_torrance_ggx(float3 n, float3 l, float3 v, t_material *m);
t_color				rt_trace_mode_ggx(t_scn *scene, Ray cam_ray);
float				ggx_partial_geometry(float cos_theta_n, float alpha);
t_color				col_from_normal(float3 vector);
t_color 			col_from_vec(float3 vector);
t_color				rt_trace_mode_normals(t_scn *scene, Ray ray);
t_obj				*rt_trace_nearest(t_scn *scene, Ray ray);
t_color 			rt_trace_mode_color_only(t_scn *scene, Ray ray);
t_color				rt_trace_mode_light(t_scn *scene, Ray ray);
t_color				rt_trace_mode_dist(t_scn *scene, Ray ray);
float				brdf_get_g(float3 n, float3 v, float3 l, t_material *mat);
t_color				rt_trace_brdf_g(t_scn *scene, Ray ray);
float				brdf_get_d(float3 n, float3 v, float3 l, t_material *mat);
t_color				rt_trace_brdf_d(t_scn *scene, Ray ray);
t_color				rt_trace_mode_normals_angle(t_scn *scene, Ray ray);

#endif