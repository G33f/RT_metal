/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rt_trace_brdf_d.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/09/18 19:25:23 by wpoudre           #+#    #+#             */
/*   Updated: 2020/09/18 19:25:24 by wpoudre          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "metal_shader.h"

t_color		rt_trace_brdf_d(t_scene *scene, t_ray ray)
{
	t_obj		*nearest;
	t_ray		normal;
	float3		dist;
	float3		d;
	size_t		i;

	if ((nearest = rt_trace_nearest_dist(scene, ray, &dist)) == NULL)
		return ((t_color){0, 0, 0, ALPHA_MAX});
	normal.pos = ray.pos + ray.dir * dist;
	normal.dir = trace_normal_fig(ray, nearest);
	d = 0.0;
	i = 0;
	while (i < scene->light_num)
	{
		if (ray_point_is_behind(normal, scene->lights[i].pos))
		{
			i++;
			continue;
		}
		d += brdf_get_d(normal.dir, -ray.dir, scene->lights[i].pos - normal.pos, nearest->material);
		i++;
	}
	return (col_from_vec_norm((float3){d, d, d}));
}

kernal	void 	trace_brdf_d(	device struct		s_scn		*scene	[[buffer(0)]],
								texture2d<float,access::write>	pixel [[texture(1)]],
								uint2                     		gid [[thread_position_in_grid]])
{
	t_rat	ray;
	t_scene s;
	float4	color;
	t_color	buf;

	ray = project_get_ray_from_coords(scene.camera, git.x, git.y);
	buf = rt_trace_brdf_d(scene, ray);
	color = (float4){buf.r, buf.g, buf.g, buf.a};
	out.write(color, git);
}
