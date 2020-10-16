# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    rt_trace_mod_ggx.metal                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/09/14 20:10:13 by wpoudre           #+#    #+#              #
#    Updated: 2020/09/14 20:10:16 by wpoudre          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#include "metal_shader.h"

float		ggx_partial_geometry(float cos_theta_n, float alpha)
{
	cos_theta_n = num_clamp(sqrt(cos_theta_n), 0, 1);
	cos_theta_n = (1 - cos_theta_n) / cos_theta_n;
	return (2.0 / (1.0 + sqrt(1.0 + alpha * alpha * cos_theta_n)));
}

float		ggx_distribution(float cos_theta_nh, float alpha)
{
	float		alpha2;
	float		nh_sqr;
	float		den;

	alpha2 = alpha * alpha;
	nh_sqr = num_clamp(sqrt(cos_theta_nh), 0, 1);
	den = nh_sqr * alpha2 + (1.0 - nh_sqr);
	return (alpha2 / (M_PI * den * den));
}

float3			cook_torrance_ggx(float3 n, float3 l, float3 v, t_material *m)
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
		return ((float3){0, 0, 0});
	g = ggx_partial_geometry(n_dot_v, num_sqr(m->roughness));
	g = g * ggx_partial_geometry(n_dot_l, num_sqr(m->roughness));
	f_diffk = fresnel_schlick(m->f0, dot(normalize(v + l), v));
	speck = f_diffk * (g * ggx_distribution(dot(n, normalize(v + l)), sqrt(m->roughness)) * 0.25 / (n_dot_v + 0.001));
	f_diffk = vec_clamp(((float3){1.0, 1.0, 1.0} - f_diffk), 0.0, 1.0);
	f_diffk = m->color * f_diffk;
	f_diffk = f_diffk * (n_dot_l / M_PI);
	return (speck + f_diffk);
}

static float3	rt_trace_mode_ggx_loop(t_ggx_loop info)
{
	float3		to_light;
	float3		to_view;
	float		dist_to_shadow;
	float		dist_to_light;
	float		light_amount;

	if (info.lamp == NULL)
		return ((float3){0, 0, 0});
	if (ray_point_is_behind(info.normal, info.lamp->pos))
		return ((float3){0, 0, 0});
	to_light = info.lamp->pos - info.normal.pos;
	dist_to_light = length(to_light);
	if (rt_trace_nearest_dist(info.scene, (t_ray){info.normal.pos, to_light}, &dist_to_shadow) != NULL)
	{
		if (dist_to_shadow < dist_to_light)
		{
			return ((float3){0, 0, 0});
		}
	}
	to_view = -info.cam_ray.dir;
	light_amount = info.lamp->power / (dist_to_light * dist_to_light + 1.0);
	return (cook_torrance_ggx(info.normal.dir, to_light, to_view, info.mat) * light_amount);
}

t_color			rt_trace_mode_ggx(t_scene *scene, t_ray cam_ray)
{
	t_obj		*nearest;
	t_ray		normal;
	float		dist;
	size_t		i;
	float3		res;

	if ((nearest = rt_trace_nearest_dist(scene, cam_ray, &dist)) == NULL)
		return ((t_color){0, 0, 0, ALPHA_MAX});
	normal.pos = cam_ray.pos + cam_ray.dir * (dist - 0.0001);
	normal.dir = trace_normal_fig(cam_ray, nearest);
	res = (float3){0.0f, 0.0f, 0.0f};
	i = 0;
	while (i < scene->light_num)
	{
		res = res + rt_trace_mode_ggx_loop((t_ggx_loop){normal, cam_ray, scene, &(scene->lights[i]), nearest->mat});
		i++;
	}
	res = vec_clamp(res, 0, 1);
	return (col_from_vec_norm(vec_to_srgb(res)));
}

kernal	void 	trace_mode_ggx(	device struct		s_scn		*scene	[[buffer(0)]],
								texture2d<float,access::write>	pixel [[texture(1)]],
								uint2                     		gid [[thread_position_in_grid]])
{
	t_rat	ray;
	t_scene s;
	float4	color;
	t_color	buf;

	ray = project_get_ray_from_coords(scene.camera, git.x, git.y);
	buf = rt_trace_mode_ggx(scene, ray);
	color = (float4){buf.r, buf.g, buf.g, buf.a};
	out.write(color, git);
}
