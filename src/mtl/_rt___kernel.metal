/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   _rt___kernel.metal                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/10/14 01:54:03 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/14 01:54:03 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <metal_stdlib>
using namespace metal;

Ray rt_camera_get_ray(device struct s_cam *cam, uint2 viewport, uint2 pixel)
{
	float2 v = static_cast<float2>(viewport);
	float2 p = static_cast<float2>(pixel);
//	fov-range x and y
	float4 fr;
	fr.xy = float2(-1 * cam->fov[0] / 2, cam->fov[0] / 2);
//	fr.zw = float2(-1 * cam->fov[1] / 2, cam->fov[1] / 2);
	fr.zw = float2(cam->fov[1] / 2, -1 * cam->fov[1] / 2);
//	map to radians m
	p = map2(p, float4(0, v.x, 0, v.y), fr);
	p = angle2_to_radians(p);
//	float3 dest = rerp2(p, float3(cam->forward), float3(cam->right), float3(cam->up));
	float3 dest = rerp2(p, float3(cam->forward), float3(cam->up), float3(cam->right));
	Ray ray = Ray(float3(cam->pos), dest);
	return ray;
}

float rt_dist(Ray ray, device struct s_obj *obj)
{
	if (obj->type == OBJ_SPHERE) {
		return (rt_dist_sphere(ray, &(obj->content.sphere)));
//	} else if (obj->type == OBJ_PLANE) {
//		return (rt_dist_plane(ray, &(obj->content.plane)));
	}
	return (INFINITY);
}

int	find_material_by_id( int id, device struct s_mat *array, int len)
{
	for (int i = 0; i < len; i++)
	{
		if (array[i].id == id)
			return (i);
	}
	return (-1);
}

kernel void scene_test(	device struct		s_scn		*scene	[[buffer(0)]],
						texture2d<float,access::write> 	out		[[texture(1)]],
						uint2                  			gid 	[[thread_position_in_grid]])
{
	uint2 size = uint2(out.get_width(), out.get_height());
	device struct s_cam *cam = &scene->cameras[0];

	if (gid.x < size.x && gid.y < size.y)
	{
		float4 color = float4(0.5, 0.5, 0.5, 0);

		Ray ray = rt_camera_get_ray(cam, size, gid);

		int		nearest_id = -1;
		float	nearest_dist = INFINITY;

		for (int i = 0; i < scene->objects_num; i++)
		{
			float dist = rt_dist(ray, &scene->objects[i]);
			if (dist < nearest_dist && dist != INFINITY) {
				nearest_id = i;
				nearest_dist = dist;
			}
		}

		if (nearest_id >= 0) {
//			color = float4(0, 1, 0, 0);
			int index = find_material_by_id(
					scene->objects[nearest_id].material_id,
					scene->materials, scene->materials_num);
			if (scene->materials_num == 1) {
				color = float4(1, 1, 1, 0.0f);
			}
			else
			{
				color = float4(float3(scene->materials[index].albedo), 0.0f);
			}
		}

//		if (length(ray.dir - cam->forward) < 0.001) {
//			color = float4(0, 1, 0, 0);
//		}

		out.write(color, gid);
	}
}


