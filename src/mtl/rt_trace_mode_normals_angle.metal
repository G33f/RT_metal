# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    rt_trace_mode_normals_angle.metal                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: wpoudre <marvin@42.fr>                     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/09/18 19:32:47 by wpoudre           #+#    #+#              #
#    Updated: 2020/09/18 19:32:49 by wpoudre          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#include "metal_shader.h"

t_color		rt_trace_mode_normals_angle(t_scene *scene, t_ray ray)
{
	t_obj		*nearest;
	float3		normal;
	float		angle_in;

	if ((nearest = rt_trace_nearest(scene, ray)) != NULL)
	{
		normal = trace_normal_fig(ray, nearest);
		angle_in = 1.0 - dot(normalize(normal), normalize(-ray.dir));
		return (col_from_vec((float3){angle_in * 256, 0, 0}));
	}
	return ((t_color){0, 0, 0, ALPHA_MAX});
}

kernal	void 	trace_mode_normals_angle(	device struct		s_scn		*scene	[[buffer(0)]],
											texture2d<float,access::write>	pixel [[texture(1)]],
											uint2                     		gid [[thread_position_in_grid]])
{
	t_rat	ray;
	t_scene s;
	float4	color;
	t_color	buf;

	ray = project_get_ray_from_coords(scene.camera, git.x, git.y);
	buf = rt_trace_mode_normals_angle(scene, ray);
	color = (float4){buf.r, buf.g, buf.g, buf.a};
	out.write(color, git);
}