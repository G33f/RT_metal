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

t_color 		rt_trace_mode_color_only(device t_scn *scene, Ray ray)
{
	struct s_obj 			nearest;
	float 					t;

	rt_trace_nearest_dist(scene, ray, t, nearest);
	if (nearest->material)
		return (col_from_vec_norm(nearest->materials.color));
	return (t_color(0.0f, 0.0f, 0.0f, (float)ALPHA_MAX));
}

kernel	void 	trace_mode_color_only(	device struct		s_scn		*scene	[[buffer(0)]],
										texture2d<float,access::write>	out [[texture(1)]],
										uint2                     		gid [[thread_position_in_grid]])

{
	Ray		ray;
	float4	color;
	t_color	buf;

	device struct s_cam *cam = &scene->cameras[0];
	uint2 size = uint2(out.get_width(), out.get_height());
	ray = rt_camera_get_ray(cam, size, gid);
	buf = rt_trace_mode_color_only(scene, ray);
	color = float4(buf.r, buf.g, buf.g, buf.a);
	out.write(color, gid);
}
