/* **************************************************************************** */
/*                                                                              */
/*                                                         :::      ::::::::    */
/*    rt_trace_mode_color_only.metal                     :+:      :+:    :+:    */
/*                                                     +:+ +:+         +:+      */
/*    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         */
/*                                                 +#+#+#+#+#+   +#+            */
/*    Created: 2020/09/17 15:45:55 by wpoudre           #+#    #+#              */
/*    Updated: 2020/09/17 15:45:58 by wpoudre          ###   ########.fr        */
/*                                                                              */
/* **************************************************************************** */

#include <metal_stdlib>
using namespace metal;

float3			cook_torrance_ggx(float3 n, float3 l, float3 v, device t_m *m)
{
	float		g;
	float3		f_diffk;
	float		n_dot_v;
	float		n_dot_l;
	float3		speck;

	n = normalize(n);
	l = normalize(l);
	v = normalize(v);
	n_dot_v = dot(n, v);
	n_dot_l = dot(n, l);
	if (n_dot_l <= 0 || n_dot_v <= 0)
		return (float3(0));
	g = ggx_partial_geometry(n_dot_v, sqrt(m->roughness));
	g = g * ggx_partial_geometry(n_dot_l, sqrt(m->roughness));
	f_diffk = fresnel_schlick(m->f0, dot(normalize(v + l), v));
	speck = f_diffk * (g * ggx_distribution(dot(n, normalize(v + l)), sqrt(m->roughness)) * 0.25 / (n_dot_v + 0.001));
	f_diffk = vec_clamp((float3(1.0) - f_diffk), 0.0, 1.0);
	f_diffk = m->albedo * f_diffk;
	f_diffk = f_diffk * (n_dot_l / pi);
	return (speck + f_diffk);
}

static float3	rt_trace_mode_ggx_loop(t_ggx_loop info, device t_scn *scene, thread t_obj &near)
{
	float3					to_light;
	float3					to_view;
	thread float 			dist_to_shadow;
	thread struct s_obj 	nearest;
	float					dist_to_light;
	float					light_amount;

	nearest = near;
	if (ray_point_is_behind(info.normal, scene->lights[info.light_id].pos))
		return (float3(0));
	to_light = float3(scene->lights[info.light_id].pos) - info.normal.pos;
	dist_to_light = length(to_light);
//	dist_to_light = length_squared(to_light);
	dist_to_shadow = 0.0;
	rt_trace_nearest_dist(scene, Ray(info.normal.pos, to_light), dist_to_shadow, nearest);
	if (dist_to_shadow > 0.00000001)
	{
		if ((dist_to_shadow - 0.001) * dist_to_shadow < dist_to_light)
		{
			return (float3(0.0));
		}
	}
	dist_to_light = length(to_light) + 1;

	to_view = float3(info.cam_ray.dir) * -1;
	light_amount = scene->lights[info.light_id].power / (dist_to_light * dist_to_light) + 1;
	return (cook_torrance_ggx(info.normal.dir, to_light, to_view,
		&scene->materials[find_material_by_id(info.mat_id, scene->materials ,scene->mat_num)]) * light_amount);
}

t_color			rt_trace_mode_ggx(device t_scn *scene, Ray cam_ray)
{
	thread struct s_obj nearest;
	thread float 		dist;
	Ray					normal;
	int					i;
	float3				res;


	nearest.id = -1;
	i = rt_trace_nearest_dist(scene, cam_ray, dist, nearest);
	if (dist == INFINITY)
		return (float4(0));
	normal.pos = cam_ray.pos + cam_ray.dir * dist;
	normal.dir = trace_normal_fig(cam_ray, &scene->objects[i]);
	res = float3(0.0f);
	i = 0;
	while (i < scene->light_num)
	{
		res = res + rt_trace_mode_ggx_loop((t_ggx_loop){normal, cam_ray, i, nearest.material_id}, scene, nearest);
		i++;
	}
	res = vec_clamp(res, 0, 1);
//	return (col_from_vec_norm(res));
	return (col_from_vec_norm(vec_to_srgb(res)));
}

kernel	void 	trace_mod_ggx(	device struct		s_scn		*scene	[[buffer(0)]],
								texture2d<float,access::write>	out		[[texture(1)]],
								uint2                     		gid		[[thread_position_in_grid]])
{
	Ray		ray;
	float4	color;
	device struct s_cam *cam = &scene->cameras[0];
	uint2 size = uint2(out.get_width(), out.get_height());
	float2 ls = map2(float2(gid.x, gid.y), float4(float2(0.0f, (float)size.x), float2(0.0f, (float)size.y)), float4(float2(-1 * (float)size.x / 2, (float)size.x / 2), float2(-1 * (float)size.y / 2, (float)size.y / 2)));
	ray = Ray(cam->pos, normalize(float3(ls.x, ls.y, 1000.0)));
	//	material_check(scene);
	//	ray = rt_camera_get_ray(cam, size, gid);
	color = rt_trace_mode_ggx(scene, ray);
	out.write(color, gid);
}
