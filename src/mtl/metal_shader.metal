/* **************************************************************************** */
/*                                                                              */
/*                                                         :::      ::::::::    */
/*    metal_shader.metal                                 :+:      :+:    :+:    */
/*                                                     +:+ +:+         +:+      */
/*    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         */
/*                                                 +#+#+#+#+#+   +#+            */
/*    Created: 2020/09/11 18:30:35 by wpoudre           #+#    #+#              */
/*    Updated: 2020/09/11 18:30:37 by wpoudre          ###   ########.fr        */
/*                                                                              */
/* **************************************************************************** */

#include <metal_stdlib>
using namespace metal;

int	find_material_by_id( int id, device struct s_mat *array, int len)
{
	for (int i = 0; i < len; i++)
	{
		if (array[i].id == id)
			return (i);
	}
	return (-1);
}

bool		vec_point_is_behind(float3 vec_from_zero, float3 point)
{
	float3 res;

	res = vec_from_zero * point;
	if (res.x + res.y + res.z < 0)
		return (true);
	return (false);
}

bool		ray_point_is_behind(Ray ray, float3 point)
{
	return (vec_point_is_behind(ray.dir, (point - ray.pos)));
}

float					num_clamp(float val, float min, float max)
{
	if (val < min)
	{
		return (min);
	}
	if (val > max)
	{
		return (max);
	}
	return (val);
}

float3			vec_clamp(float3 source, float min, float max)
{
	source.x = num_clamp(source.x, min, max);
	source.y = num_clamp(source.y, min, max);
	source.z = num_clamp(source.z, min, max);
	return (source);
}

float3		vec_to_srgb(float3 v)
{
	v.x = pow(v.x, 1.0f / 2.2f);
	v.y = pow(v.y, 1.0f / 2.2f);
	v.z = pow(v.z, 1.0f / 2.2f);
	return (v);
}

float4 	col_from_vec(float3 vector)
{
	float4 res;

	res[0] = vector.x;
	res[1] = vector.y;
	res[2] = vector.z;
	res[3] = ALPHA_MAX;
	return (res);
}

float4		col_from_normal(float3 vector)
{
	float4	res;

	vector = normalize(vector);
	res.x = (unsigned char)(vector.x + 1) * COLOR_MAX / 2;
	res.y = (unsigned char)(vector.y + 1) * COLOR_MAX / 2;
	res.z = (unsigned char)(vector.z + 1) * COLOR_MAX / 2;
	res.w = ALPHA_MAX;
	return (res);

}

//float4		col_from_vec_norm(float3 vector)
//{
//	float4	res;
//
//	res.x = (float)(num_clamp(vector.x, 0, 1));
//	res.y = (float)(num_clamp(vector.y, 0, 1));
//	res.z = (float)(num_clamp(vector.z, 0, 1));
//	res.w = 0;
//	return (res);
//}

float4		col_from_vec_norm(float3 vector)
{
	float4	res;

	res.x = vector.x;
	res.y = vector.y;
	res.z = vector.z;
	res.w = 0;
	return (res);
}

float3	fresnel_schlick(float3 f0, float cos_theta)
{
	float3	res;

	cos_theta = 1.0 - num_clamp(cos_theta, 0.0, 1.0);
	cos_theta = cos_theta * cos_theta * cos_theta * cos_theta * cos_theta;
	res = (float3(1.0, 1.0, 1.0)- f0) * cos_theta;
	res = f0 + res;
	return (res);
}

float					trace_dot_plane(Ray ray, device t_obj *fig)
{
	struct	s_plane		pl[1];
	float				d_dot_v;

	if (!fig)
		return (INFINITY);
	pl[0] = fig->obj.plane;
//	ray.dir = normalize(ray.dir);
	d_dot_v = dot(ray.dir, float3(pl->normal));
	return (-1 * dot((ray.pos - (float3(pl->normal) * (-1.0 * pl->d))), (float3)pl->normal) / d_dot_v);
}

float					trace_dot_pl(Ray ray, t_plane pl)
{
	float				d_dot_v;

//	ray.dir = normalize(ray.dir);
	d_dot_v = dot(ray.dir, float3(pl.normal));
	return (-1 * dot((ray.pos - (float3(pl.normal) * (-1.0 * pl.d))), float3(pl.normal)) / d_dot_v);
}


float					trace_dot_cap(Ray ray, Ray plane_ray)
{
	thread t_obj		fig;

	fig.type = PLANE;
	fig.obj.plane.normal = plane_ray.dir;
	fig.obj.plane.d = (dot(plane_ray.dir, plane_ray.pos));
//	fig.obj.plane.d = -1 * (dot(plane_ray.dir, plane_ray.pos));
	return (trace_dot_pl(ray, fig.obj.plane));
}

static float2			sphere_intersect_points(Ray ray, device t_sphere *sphere)
{
	float		a;
	float		b;
	float		c;
	float		d;
	float3		a_min_c;

	a_min_c = (ray.pos - float3(sphere->center));
	a = dot(ray.dir, ray.dir);
	b = 2 * dot(ray.dir, a_min_c);
	c = dot(a_min_c, a_min_c) - (sphere->r * sphere->r);
	d = pow(b, 2) - 4 * a * c;
	if (d >= 0)
		return (float2((-b - sqrt(d)) / (2 * a), (-b + sqrt(d)) / (2 * a)));
	return (float2(INFINITY));
}

float					trace_dot_sphere(Ray ray, device t_obj *fig)
{
	float			minimal;
	float2			points;

	if (!fig)
		return (INFINITY);
	points = sphere_intersect_points(ray, &fig->obj.sphere);
	minimal = INFINITY;
	if (points.x > 0 && points.x < minimal)
		minimal = points.x;
	if (points.y > 0 && points.y < minimal)
		minimal = points.y;
	return (minimal);
}

///cone trace------------------------------------------------------

float3					cone_intersect(Ray ray, device struct s_cone *cone, float3 v)
{
	float3		x;
	float		a;
	float		b;
	float		c;
	float		d;

	d = cone->r / length(float3(cone->tail) - float3(cone->head));
	x = ray.pos - float3(cone->tail);
	a = dot(ray.dir, ray.dir) - (1 + (d * d)) * pow(dot(ray.dir, v), 2);
	b = (dot(ray.dir, x) - dot(ray.dir, v) * (1 + d * d) * dot(x, v)) * 2;
	c = dot(x, x) - (1 + d * d) * pow(dot(x, v), 2);
	d = (b * b) - 4 * a * c;
	if (d < 0)
		return (float3(INFINITY));
	d = sqrt(d);
	return (float3((-b - d) / (2 * a), (-b + d) / (2 * a), 0));
}

static float3			cone_capped(Ray ray_in, device struct s_cone *cone)
{
	float3				points;
	float3				v;
	float3				m;
	float3				clamped;
	float				x_dot_v;

	v = normalize(float3(cone->tail) - float3(cone->head));
	ray_in.dir = normalize(ray_in.dir);
	points = cone_intersect(ray_in, cone, v);
	x_dot_v = dot(ray_in.pos - float3(cone->head), v);
	m.x = dot(ray_in.dir, v * points.x) + x_dot_v;
	m.y = dot(ray_in.dir, v * points.y) + x_dot_v;
	clamped.x = num_clamp(m.x, 0, length(float3(cone->head) - float3(cone->tail)));
	clamped.y = num_clamp(m.y, 0, length(float3(cone->head) - float3(cone->tail)));
	if (clamped.x != m.x && clamped.y != m.y)
		return (float3(INFINITY));
	if (clamped.x != m.x)
		points.x = trace_dot_cap(ray_in, Ray(float3(cone->tail), v));
	if (clamped.y != m.y)
		points.y = trace_dot_cap(ray_in, Ray(float3(cone->tail), v));
	return (points);
}

float					trace_dot_cone(Ray ray, device t_obj *fig)
{
	float 				minimal;
	float3 				points;

	if (!fig)
		return (INFINITY);
	points = cone_capped(ray, &(fig->obj.cone));
	minimal = INFINITY;
	if (points.x > 0 && points.x < minimal)
		minimal = points.x;
	if (points.y > 0 && points.y < minimal)
		minimal = points.y;
	return (minimal);
}

///cylinder trace-----------------------------------------------

float3					cylinder_intersect(Ray ray, struct s_cylinder cyl, float3 v)
{
	float3				x;
	float				a;
	float				b;
	float				c;
	float				d;

	x = float3(ray.pos) - float3(cyl.tail);
	a = dot(ray.dir, ray.dir) - pow(dot(ray.dir, v), 2);
	b = (dot(ray.dir, x) - (dot(ray.dir, v) * dot(x, v))) * 2;
	c = dot(x, x) - pow(dot(x, v), 2) - pow(cyl.r, 2);
	d = pow(b, 2) - 4 * a * c;
	if (d < 0)
		return (float3(INFINITY));
	d = sqrt(d);
	return (float3((-b - d) / (2 * a), (-b + d) / (2 * a), 0));
}

static float3			cylinder_capped(Ray ray, struct s_cylinder cyl)
{
	float				maxm;
	float3				points;
	float3				v;
	float3				m;
	float				x_dot_v;

	v = normalize(float3(cyl.head) - float3(cyl.tail));
	points = cylinder_intersect(ray, cyl, v);
	maxm = length(float3(cyl.tail) - float3(cyl.head));
	x_dot_v = dot((ray.pos - float3(cyl.tail)), v);
	m.x = dot(ray.dir, (v * points.x)) + x_dot_v;
	m.y = dot(ray.dir, (v * points.y)) + x_dot_v;
	if (m.x >= 0 && m.x <= maxm && m.y >= 0 && m.y <= maxm)
		return (points);
	if ((m.x < 0 && m.y < 0) || (m.x > maxm && m.y > maxm))
		return (float3(INFINITY));
	if (m.x < 0)
		points.x = trace_dot_cap(ray, Ray(float3(cyl.tail), (-1 * v)));
	if (m.y < 0)
		points.y = trace_dot_cap(ray, Ray(float3(cyl.tail), (-1 * v)));
	if (m.x > maxm)
		points.x = trace_dot_cap(ray, Ray(float3(cyl.head), v));
	if (m.y > maxm)
		points.y = trace_dot_cap(ray, Ray(float3(cyl.head), v));
	return (points);
}

float					trace_dot_cylinder(Ray ray, device t_obj *fig)
{
	float				minimal;
	float3				points;

	if (!fig)
		return (INFINITY);
	points = cylinder_capped(ray, fig->obj.cylinder);
	minimal = INFINITY;
	if (points.x > 0 && points.x < minimal)
		minimal = points.x;
	if (points.y > 0 && points.y < minimal)
		minimal = points.y;
	return (minimal);
}

///figur trace-------------------------------------------------

float					trace_dot_fig(Ray ray, device t_obj *fig)
{
	if (!fig)
		return (INFINITY);
	if (fig->type == PLANE)
		return (trace_dot_plane(ray, fig));
	else if (fig->type == SPHERE)
		return (trace_dot_sphere(ray, fig));
	else if (fig->type == CONE)
		return (trace_dot_cone(ray, fig));
	else if (fig->type == CYLINDER)
		return (trace_dot_cylinder(ray, fig));
	else
		return (INFINITY);
}

int			rt_trace_nearest_dist(device t_scn *scene, Ray ray, thread float &dist, thread t_obj &nearest)
{
	float				tmp_dist;
	float				res_dist;
	int 				i;
	int					nearest_num;
	t_obj 				near;

	near = nearest;
	if (!scene)
		return (0);
	res_dist = INFINITY;
	i = 0;
	while (i < scene->obj_num)
	{
		if (near.id != scene->objects[i].id)
		{
			tmp_dist = trace_dot_fig(ray, &(scene->objects[i]));
			if (tmp_dist < res_dist && tmp_dist > 0)
			{
				res_dist = tmp_dist;
				nearest = scene->objects[i];
				nearest_num = i;
			}
		}
		i++;
	}
	dist = res_dist;
	return (nearest_num);
}

/*
float		brdf_get_d(float3 n, float3 v, float3 l, t_m *mat)
{
	float	d;
	float	roug_sqr;
	float3	h;

	if (!mat)
		return (INFINITY);
	h = normalize(v + l);
	roug_sqr = sqrt(mat->roughness);
	d = ggx_distribution(dot(n, h), roug_sqr);
	return (d);
}

float		brdf_get_g(float3 n, float3 v, float3 l, t_m *mat)
{
	float	g;
	float	roug_sqr;

	if (!mat)
		return (INFINITY);
	roug_sqr = sqrt(mat->roughness);
	g = ggx_partial_geometry(dot(n, v), roug_sqr);
	g = g * ggx_partial_geometry(dot(n, l), roug_sqr);
	return (g);
}
*/

///figur norm-------------------------------------------------

///plane norm-------------------------------------------------

float3				trace_normal_plane(Ray ray, device t_obj *fig)
{
	if (!fig)
		return (float3(INFINITY));
	if ((float)fig->obj.plane.normal.x * ray.pos.x + (float)fig->obj.plane.normal.y * ray.pos.y
		+ (float)fig->obj.plane.normal.z * ray.pos.z + (float)fig->obj.plane.d < 0)
		return (-(fig->obj.plane.normal));
	return (fig->obj.plane.normal);
}

///sphere norm------------------------------------------------

float3				trace_normal_sphere(Ray ray, device t_obj *fig)
{
	float3				bounce_pos;

	if (!fig)
		return (float3(INFINITY));
	bounce_pos = ray.pos + (ray.dir * trace_dot_sphere(ray, fig));
	return (normalize(bounce_pos - float3(fig->obj.sphere.center)));
}

///cone norm--------------------------------------------------

float3				trace_normal_cone(Ray ray_in, device t_obj *fig)
{
	float3			v;
	float3			point_p;
	float3			ca;
	float			cg;
	float			cr;

	if (!fig)
		return (float3(INFINITY));
	v = float3(fig->obj.cone.head) - float3(fig->obj.cone.tail);
	ray_in.dir = normalize(ray_in.dir);
	point_p = ray_in.pos + ray_in.dir * trace_dot_cone(ray_in, fig);
	cg = length(v);
	cr = sqrt(pow(fig->obj.cone.r, 2) + pow(cg, 2));
	ca = normalize(v) * (cg * length(point_p - float3(fig->obj.cone.tail)) / cr);
	return (normalize(point_p - (float3(fig->obj.cone.tail) + ca)));
}

///cylinder norm-----------------------------------------------

static float3		cylinder_side_nrm(float3 p, float3 c, float3 v, float m)
{
	p = p - c;
	p = p - v * m;
	return (p);
}

static float3		cylinder_m(Ray ray, float3 v, float3 cyl_pos, float3 points)
{
	float			x_dot_v;
	float3			m;

	x_dot_v = dot(ray.pos - cyl_pos, v);
	m.x = dot(ray.dir, v * points.x) + x_dot_v;
	m.y = dot(ray.dir, v * points.y) + x_dot_v;
	return (m);
}

float3				trace_normal_cylinder(Ray ray, device t_obj *fig)
{
	float			maxm;
	float3			dis;
	float3			v;
	float3			m;
	float3			p;

	if (!fig)
		return (float3(INFINITY));
	v = normalize(float3(fig->obj.cylinder.head) - float3(fig->obj.cylinder.tail));
	dis = cylinder_intersect(ray, fig->obj.cylinder, v);
	maxm = length(float3(fig->obj.cylinder.tail) - float3(fig->obj.cylinder.head));
	m = cylinder_m(ray, v, float3(fig->obj.cylinder.tail), dis);
	if (dis.x > dis.y)
	{
		dis.x = dis.y;
		m.x = m.y;
	}
	if (m.x < 0)
		return (-(v));
	else if (m.x > maxm)
		return (v);
	p = ray.pos + ray.dir * dis.x;
	return (cylinder_side_nrm(p, float3(fig->obj.cylinder.tail), v, m.x));
}

float3		trace_normal_fig(Ray ray, device t_obj *fig)
{
	if (!fig)
		return (float3(INFINITY));
	if (fig->type == PLANE)
		return (trace_normal_plane(ray, fig));
	else if (fig->type == SPHERE)
		return (trace_normal_sphere(ray, fig));
	else if (fig->type == CONE)
		return (trace_normal_cone(ray, fig));
	else if (fig->type == CYLINDER)
		return (trace_normal_cylinder(ray, fig));
	else
		return (float3(INFINITY));
}

float3 rerp(float val, float3 from, float3 to)
{
	return (normalize(from * cos(val) + to * sin(val)));
}

float3 rerp2(float2 val, float3 fromX, float3 toY, float3 toZ)
{
	return (normalize(rerp(val.x, fromX, toY) + rerp(val.y, fromX, toZ)));
}

float		map(float x, float2 in, float2 out)
{
	return ((x - in.x) * (out.y - out.x) / (in.y - in.x) + out.x);
}

float2		map2(float2 val, float4 in, float4 out)
{
	return (float2(map(val.x, in.xy, out.xy), map(val.y, in.zw, out.zw)));
}

float2		angle2_to_radians(float2 degrees)
{
	return (degrees * pi / 180.0f);
}

Ray rt_camera_get_ray(device struct s_cam *cam, uint2 viewport, uint2 pixel)
{
	float2 v = static_cast<float2>(viewport);
	float2 p = static_cast<float2>(pixel);
//	fov-range x and y
	float4 fr;
	fr.xy = float2(-1 * cam->fov[0] / 2, cam->fov[0] / 2);
	fr.zw = float2(-1 * cam->fov[1] / 2, cam->fov[1] / 2);
//	fr.zw = float2(cam->fov[1] / 2, -1 * cam->fov[1] / 2);
//	map to radians m
	p = map2(p, float4(0, v.x - 1, 0, v.y - 1), fr);
	p = angle2_to_radians(p);
//	float3 dest = rerp2(p, float3(cam->forward), float3(cam->right), float3(cam->up));
	float3 dest = rerp2(p, float3(cam->forward), float3(cam->up), float3(cam->right));
	Ray ray = Ray(float3(cam->pos), dest);
	return ray;
}
