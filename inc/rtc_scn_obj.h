/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rtc_scn_obj.h                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: kcharla <kcharla@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2020/10/12 21:13:16 by kcharla           #+#    #+#             */
/*   Updated: 2020/10/12 21:13:58 by kcharla          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef RTC_SCN_OBJ_H
# define RTC_SCN_OBJ_H

# include "libnum.h"

enum e_obj_type
{
	NONE = 0,
	PLANE,
	SPHERE,
	CYLINDER,
	CONE,
	GEOMETRY
};

struct				s_sphere
{
	t_vec3			pos;
	t_num			r;
};

struct				s_plane
{
	t_vec3			n;
	t_num			d;
};

union				u_obj_content
{
	struct s_sphere		sphere;
	struct s_plane		plane;
};

struct				s_obj
{
	int						id;
	enum e_obj_type			type;
	union u_obj_content		content;
};

#endif
