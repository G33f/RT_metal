/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rtc_scn_obj.h                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/10/12 21:13:16 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/13 01:12:07 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef RTC_SCN_OBJ_H
# define RTC_SCN_OBJ_H

# include "libnum.h"

enum e_obj_type
{
	OBJ_NONE = 0,
	OBJ_PLANE,
	OBJ_SPHERE,
	OBJ_CYLINDER,
	OBJ_CONE,
	OBJ_GEOMETRY
};

struct				s_sphere
{
	t_vec3			pos;
	t_num			r;
};

struct				s_plane
{
	t_vec3			n;
	t_vec3			d;
};

struct		s_cylinder
{
	t_vec3			head;
	t_vec3			tail;
	t_num			radius;
};

struct		s_cone
{
	t_vec3			head;
	t_vec3			tail;
	t_num			radius;
}					t_cone;

union				u_obj_content
{
	struct s_sphere		sphere;
	struct s_plane		plane;
	struct s_cylinder	cylinder;
	struct s_cone		cone;
};

struct				s_obj
{
	int						id;
	int						material_id;
	enum e_obj_type			type;
	union u_obj_content		content;
};

#endif
