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

int	find_material_by_id( int id, device struct s_mat *array, int len)
{
	for (int i = 0; i < len; i++)
	{
		if (array[i].id == id)
			return (i);
	}
	return (-1);
}

t_color 		rt_trace_mode_color_only(device t_scn *scene, Ray ray)
{
	thread struct s_obj 			nearest;
	thread float 					t;
	int								index;

	nearest.type = NONE;
	rt_trace_nearest_dist(scene, ray, t, nearest);
	if (nearest.type != NONE)
	{
		index = find_material_by_id(nearest.material_id, scene->materials, scene->mat_num);
		return (float4(float3(scene->materials[index].albedo.xyz), 0));
	}
	return (float4(0.0f, 0.0f, 0.0f, 0));
}

kernel	void 	trace_mode_color_only(	device struct		s_scn		*scene	[[buffer(0)]],
										texture2d<float,access::write>	out [[texture(1)]],
										uint2                     		gid [[thread_position_in_grid]])

{
	Ray		ray;
	float4	color;

	device struct s_cam *cam = &scene->cameras[0];
	uint2 size = uint2(out.get_width(), out.get_height());
	ray = rt_camera_get_ray(cam, size, gid);
	color = rt_trace_mode_color_only(scene, ray);
	out.write(color, gid);
}
