# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    rt_trace_mode_dist.metal                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/09/18 19:11:26 by wpoudre           #+#    #+#              #
#    Updated: 2020/09/18 19:11:29 by wpoudre          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#include "metal_shader.h"

t_color			rt_trace_mode_dist(t_scene *scene, t_ray ray)
{
	float 		dist;

	if (rt_trace_nearest_dist(scene, ray, &dist) != NULL)
	{
		dist = dist > 1 ? dist : 1;
		dist = 1 / dist;
		return (col_from_vec_norm((float3) {dist, dist, dist}));
	}
	return ((t_color) {0, 0, 0, ALPHA_MAX});
}

kernal	void 	trace_mode_dis(	device struct		s_scn		*scene	[[buffer(0)]],
								texture2d<float,access::write>	pixel [[texture(1)]],
								uint2                     		gid [[thread_position_in_grid]])
{
	t_rat	ray;
	t_scene s;
	float4	color;
	t_color	buf;

	ray = project_get_ray_from_coords(scene.camera, git.x, git.y);
	buf = rt_trace_mode_dis(scene, ray);
	color = (float4){buf.r, buf.g, buf.g, buf.a};
	out.write(color, git);
}
