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

#include <metal_stdlib>
using namespace metal;

t_color		rt_trace_brdf_d(device t_scn *scene, Ray ray)
{
	thread struct s_obj nearest;
	thread float 		dist;
	Ray					normal;
	float3				d;
	int 				i;
	int					id;

	nearest.id = -1;
	id = rt_trace_nearest_dist(scene, ray, dist, nearest);
	if (!dist)
		return (float4(0));
	normal.pos = ray.pos + ray.dir * dist;
	normal.dir = trace_normal_fig(ray, &scene->objects[id]);
	d = 0.0;
	i = 0;
	while (i < scene->light_num)
	{
		if (ray_point_is_behind(normal, scene->lights[i].pos))
		{
			i++;
			continue;
		}
		d += brdf_get_d(normal.dir, -ray.dir, (float3(scene->lights[i].pos) - normal.pos), &scene->materials[find_material_by_id(nearest.material_id, scene->materials ,scene->mat_num)]);
		i++;
	}
	return(col_from_vec_norm(float3(d)));
}

kernel	void 	trace_brdf_d(	device struct		s_scn		*scene	[[buffer(0)]],
								texture2d<float,access::write>	out		[[texture(1)]],
								uint2                     		gid		[[thread_position_in_grid]])
{
	Ray		ray;
	float4	color;
	device struct s_cam *cam = &scene->cameras[0];
	uint2 size = uint2(out.get_width(), out.get_height());
	float2 ls = map2(float2(gid.x, gid.y), float4(float2(0.0f, (float)size.x), float2(0.0f, (float)size.y)), float4(float2(-1 * (float)size.x / 2, (float)size.x / 2), float2(-1 * (float)size.y / 2, (float)size.y / 2)));
	ray = Ray(cam->pos, normalize(float3(ls.x, ls.y, 1000.0)));
	//	ray = rt_camera_get_ray(cam, size, gid);
	color = rt_trace_brdf_d(scene, ray);
	out.write(color, gid);
}
