/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rtc_init.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/09/30 21:04:09 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/14 01:55:35 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "rt.h"

void		rtc_hooks_editor(void *win)
{
	mlx_hook(win, MLX_HOOK_DRAG_DROP, 0, rt_editor_drag_file, NULL);
}

// TODO add viewer window
// TODO add renderer window

#define RT_MTL_FILES "src/mtl/metal_struct.metal src/mtl/metal_shader.metal src/mtl/rt_trace_mod_ggx.metal"
//#define RT_MTL_FILES "src/mtl/_rt__structs.metal src/mtl/_rt__utils.metal src/mtl/_rt_sphere.metal src/mtl/_rt___kernel.metal"
#define RT_BUF_SCENE "scene"
#define IMG_RES "image_result"

#define RT_WIN_EDITOR_W 1920
#define RT_WIN_EDITOR_H 1080

void rtc_mgx_load_buffer(t_rts *rts);
void rtc_mgx_load_lib(t_rts *rts, char *name);

int			rtc_init(t_rts *rts)
{
	if (rts == NULL)
		return (rt_err("rts is NULL pointer"));
	void *win_edit = mlx_window_add(rts->mgx, RT_WIN_EDITOR_W, RT_WIN_EDITOR_H, WINDOW_EDITOR);
	// creating windows
	if (win_edit == NULL)
		return (rt_err("Cannot init editor window"));
//	if (win_view == NULL)
//		return (rt_err("Cannot init viewer window"));
//	if (win_render == NULL)
//		return (rt_err("Cannot init renderer window"));

	// giving windows hooks
	rtc_hooks_editor(win_edit);
//	rtc_hooks_view(win_view);
//	rtc_hooks_render(win_render);

	mlx_loop_hook(rts->mgx, rtc_loop, rts);

	// TODO add this
//	if (mlx_metal_lib_load_source(d->mlx, libstr) != 0)
//		printf("lib govno\n");
//	else
//		printf("lib success!\n");

	char *lib_source = NULL;

	if (fio_read_files(&lib_source, RT_MTL_FILES))
		rt_err("Cannot read metal library source files");
	mlx_metal_lib_load_source(rts->mgx, lib_source);

//	rtc_mgx_load_lib(rts, "src/mtl/mtl_basic.metal");

	rtc_mgx_load_buffer(rts);

	if (mlx_image_add(rts->mgx, IMG_RES, RT_WIN_EDITOR_W, RT_WIN_EDITOR_H) == NULL)
		ft_printf("image govno\n");
	else
		ft_printf("image success!\n");

	if (mlx_metal_kernel_run(rts->mgx, "trace_mode_ggx", RT_BUF_SCENE, IMG_RES))
		ft_printf("kernel govno\n");
	else
		ft_printf("kernel success!\n");

	mlx_image_put(rts->mgx, win_edit, IMG_RES, 0, 0);

	return (0);
}

void rtc_mgx_load_buffer(t_rts *rts)
{
	if (mlx_metal_buffer_add(rts->mgx, RT_BUF_SCENE, (void*)(rts->scene), (int)sizeof(t_scn)))
		ft_printf("buffer govno\n");
	else
	ft_printf("buffer success!\n");
}

