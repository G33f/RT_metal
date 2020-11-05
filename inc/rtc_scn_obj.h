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

typedef enum		e_shape_type
{
	NONE = 0,
	CONE,
	SPHERE,
	PLANE,
	CYLINDER,
	TORUS
}					t_shape_type;

typedef struct		s_mat
{
	int				id;
	t_vec3			albedo;
	t_vec3			f0;
	float			transparency;
	float			ior;
	float 			roughness;
	float 			metalness;
}					t_m;

struct				s_sphere
{
	t_vec3			center;
	float			r;
};

struct				s_cone
{
	t_vec3			head;
	t_vec3			tail;
	float			r;
};

struct		s_plane
{
	float 			d;
	t_vec3			normal;
};

struct		s_cylinder
{
	t_vec3			head;
	t_vec3			tail;
	float			r;
};

struct		s_torus
{
	t_vec3			center;
	t_vec3			ins_vec;
	float 			R;
	float			r;
};

typedef union			u_shape
{
	struct s_sphere		sphere;
	struct s_cone		cone;
	struct s_plane		plane;
	struct s_cylinder	cylinder;
	struct s_torus		torus;
}						t_shape;

typedef struct			s_obj
{
	int 				id;
	int					material_id;
	t_shape_type 		type;
	t_shape				obj;
}						t_obj;

#endif
