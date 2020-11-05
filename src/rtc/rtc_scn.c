/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rtc_scene.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/10/12 20:53:18 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/14 02:45:39 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "rt.h"

static void		material_apply_parameters(t_m *mat)
{
	t_num		tmp_f0;

	if (mat == NULL)
		return ;
	tmp_f0 = num_sqr((1 - mat->ior) / (1 + mat->ior));
	if (mat->metalness == TRUE)
	{
		mat->f0 = mat->albedo;
		mat->albedo = (t_vec3){0, 0, 0};
	}
	else
	{
		mat->f0 = (t_vec3){tmp_f0, tmp_f0, tmp_f0};
	}
}

void material_check(t_scn *scene)
{
	int i;

	i = -1;
	while (++i < scene->materials_num)
		material_apply_parameters(&scene->materials[i]);
}

int			rtc_scn_init(t_scn **scn_ptr, t_idm *idm)
{
	t_scn			*scene;

	if (idm == NULL)
		return (rt_err("idm is NULL pointer"));
	if (scn_ptr == NULL)
		return (rt_err("scn_ptr is NULL pointer"));
	scene = NULL;
	scene = ft_memalloc(sizeof(t_scn));

	scene->id = 5;//idm->next_id(idm);

	scene->objects[0].id = 6;
	scene->objects[0].type = SPHERE;
	scene->objects[0].material_id = 0;
	scene->objects[0].obj.sphere.center = (t_vec3){0.0, 0.0, 100.0};
	scene->objects[0].obj.sphere.r = (t_num){3.1};

	scene->objects[1].id = 4;
	scene->objects[1].type = SPHERE;
	scene->objects[1].material_id = 1;
	scene->objects[1].obj.sphere.center = (t_vec3){30.0, -15.0, 40.0};
	scene->objects[1].obj.sphere.r = (t_num){3.9};

	scene->objects[2].id = 8;
	scene->objects[2].type = CONE;
	scene->objects[2].material_id = 1;
	scene->objects[2].obj.cone.head = (t_vec3){5, 10, 40};
	scene->objects[2].obj.cone.tail = (t_vec3){5, -10, 40};
	scene->objects[2].obj.cone.r = (t_num){3.2};

	scene->objects[3].id = 11;
	scene->objects[3].type = CYLINDER;
	scene->objects[3].material_id = 0;
	scene->objects[3].obj.cylinder.head = (t_vec3){-10, 4, 50};
	scene->objects[3].obj.cylinder.tail = (t_vec3){-10, 4, 40};
	scene->objects[3].obj.cylinder.r = (t_num){2.5};

	scene->objects[4].id = 14;
	scene->objects[4].type = PLANE;
	scene->objects[4].material_id = 0;
	scene->objects[4].obj.plane.normal = (t_vec3){0, -1, 0};
	scene->objects[4].obj.plane.d = 10;

	scene->objects[5].id = 15;
	scene->objects[5].type = TORUS;
	scene->objects[5].material_id = 0;
	scene->objects[5].obj.torus.center = (t_vec3){1, 1, 30};
	scene->objects[5].obj.torus.ins_vec = (t_vec3){1, 0, 0};
	scene->objects[5].obj.torus.r = 1.0f;
	scene->objects[5].obj.torus.R = 5.0f;



//	scene->objects[2].id = 14;
//	scene->objects[2].type = PLANE;
//	scene->objects[2].material_id = 9;
//	scene->objects[2].obj.plane.normal = (t_vec3){0.0, 1.0, 0.0};
//	scene->objects[2].obj.plane.d = 5;

	scene->objects_num = 7;


	scene->cameras[0].id = 7;
	scene->cameras[0].pos = (t_vec3){0.0, 0.0, 0.0};
	scene->cameras[0].forward = (t_vec3){1.0, 0.0, 0.0};
	scene->cameras[0].right = (t_vec3){0.0, 1.0, 0.0};
	scene->cameras[0].up = (t_vec3){0.0, 0.0, 1.0};
	//fov in degrees
	scene->cameras[0].fov = (t_vec2){90.0, 59.0};
	scene->cameras_num = 1;

	scene->materials[0].id = 0;
	scene->materials[0].metalness = 0;
	scene->materials[0].roughness = 1.0f;
	scene->materials[0].ior = 1.6f;
	scene->materials[0].transparency = 0.0f;
	scene->materials[0].albedo = (t_vec3){1.0, 1.0, 1.0};
	scene->materials[0].f0 = (t_vec3){0.0, 0.0, 0.0};

	scene->materials[1].id = 1;
	scene->materials[1].metalness = 0;
	scene->materials[1].roughness = 0.0f;
	scene->materials[1].ior = 1.2f;
	scene->materials[1].transparency = 0.0f;
	scene->materials[1].albedo = (t_vec3){0.73, 0.93, 0.0};
	scene->materials[1].f0 = (t_vec3){0.0, 0.0, 0.0};

	scene->materials_num = 2;

	scene->lights[0].id = 3;
	scene->lights[0].pos = (t_vec3){0.0, 0.0, 0.0};
	scene->lights[0].col = (t_vec3){1.0, 1.0, 1.0};
	scene->lights[0].power = 10000;

	scene->light_num = 1;
//	scene->materials_num = 1;
	//TODO init scene

	material_check(scene);

	*scn_ptr = scene;
	return (0);
}

int			rtc_scn_free(t_scn *scene)
{
	if (scene == NULL)
		return (0);
	free(scene);
	return (0);
}

//int		rtc_loop()
//{
//	t_rt	*rt;
//	t_mgx	*mgx;
//
//	if ((rt = (t_rt*)void_rt) == NULL)
//		return (-1);
//	if ((mgx = rt->mgx) == NULL)
//		return (-1);
//	if (mgx->win_active == NULL)
//		return (-1);
//	if (mgx->win_active->input.close)
//	{
//		ft_printf("pressed (X) button, exit...\n");
//		//rt_free(?)
//		exit(0);
//	}
//	clock_gettime(CLOCK_MONOTONIC_RAW, &(rt->timespec));
//	rt_loop_main_win(rt, mgx, mgx->win_active);
//	rt_run_coroutines(rt);
//	mgx_buf_merge(mgx->win_active->bufs, mgx_get_win_buf(mgx->win_active, 2));
//	mgx_win_draw(mgx->win_active);
//	return (0);
//}

//int		coroutine_add(t_rt *rt, int (*func)(t_rt*, t_timespec*, t_bool*))
//{
//	t_coroutine		*cor;
//
//	cor = &(rt->one_coroutine);
//	cor->timespec = rt->timespec;
//	cor->func = func;
//	return (0);
//}
//
//int		rt_loop_main_win(t_rt *rt, t_mgx *mgx, t_mgx_win *win)
//{
//	if (rt == NULL || mgx == NULL || win == NULL)
//		return (-1);
//	if (mgx_mouse_clicked_left(win))
//	{
//		ft_putstr("left button clicked!\n");
//		if (rt->one_coroutine.func == NULL)
//			coroutine_add(rt, coroutine_example);
//	}
//	if (mgx_mouse_clicked_right(win))
//	{
//		ft_putstr("right button clicked!\n");
//		rt->coroutines_run = FALSE;
//	}
//	return (0);
//}
//
//int		rt_run_coroutines(t_rt *rt)
//{
//	if (rt->one_coroutine.func == NULL)
//		return (0);
//	if (rt->one_coroutine.func(rt, &(rt->one_coroutine.timespec), &(rt->coroutines_run)))
//	{
//		rt->one_coroutine.func = NULL;
//	}
//	return (0);
//}
//


