# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    rt_trace_mode_light.metal                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/09/18 19:03:28 by wpoudre           #+#    #+#              #
#    Updated: 2020/09/18 19:03:30 by wpoudre          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#include "metal_shader.h"

t_color			rt_trace_mode_light(t_scene *scene, t_ray ray)
{
	t_ray		normal;
	float3		res;
	float		light_amount;
	float		dist;
	size_t		i;

	if (rt_trace_nearest_dist(scene, ray, &dist) != NULL)
	{
		res = (float3){0.0f, 0.0f, 0.0f};
		normal.pos = ray.pos + ray.dir * dist;
		i = 0;
		while (i < scene->light_num)
		{
			dist = length(scene->lights[i].pos - normal.pos);
			light_amount = scene->lights[i].power / (dist * dist + 1.0);
			res = res + (float3){light_amount, light_amount, light_amount};
			i++;
		}
		return (col_from_vec_norm(res));
	}
	return ((t_color)(0, 0, 0, ALPHA_MAX));
}

kernal	void 	trace_mode_light(	device struct		s_scn		*scene	[[buffer(0)]],
									texture2d<float,access::write>	pixel [[texture(1)]],
									uint2                     		gid [[thread_position_in_grid]])
{
	t_rat	ray;
	t_scene s;
	float4	color;
	t_color	buf;

	ray = project_get_ray_from_coords(scene.camera, git.x, git.y);
	buf = rt_trace_mode_light(scene, ray);
	color = (float4){buf.r, buf.g, buf.g, buf.a};
	out.write(color, git);
}
