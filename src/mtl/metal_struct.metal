#include <metal_stdlib>
using namespace metal;

# define WIN_WIDTH	1920
# define WIN_HEIGHT	1080
# define ALPHA_MAX	255
# define COLOR_MAX	255
# define RT_MAX_OBJECTS 128
# define RT_MAX_MATERIALS 32
# define RT_MAX_LIGHTS 16
# define RT_MAX_CAMERAS 16

constant const float pi = 3.14159265358979323846f;

typedef packed_float4	t_color;

typedef enum			e_shape_type
{
	NONE = 0,
	CONE,
	SPHERE,
	PLANE,
	CYLINDER,
	TORUS
}						t_shape_type;

typedef enum			e_camera_projection
{
	PROJECTION_ORTOGRAPHIC,
	PROJECTION_PERSPECTIVE
}						t_projection;

typedef struct			Ray
{
	float3				pos;
	float3				dir;
	float				max;
	float				min;
	Ray() : pos(0.0f), dir(1.0f), max(INFINITY), min(0) {};
	Ray(	float3 p, float3 d,
	float max = INFINITY, float min = 0.0 )
	: pos(p), dir(normalize(d)), max(max), min(min) {};
} 						Ray;

typedef struct			s_mat
{
	int					id;
	packed_float3		albedo;
	packed_float3		f0;
	float				transparency;
	float				ior;
	float 				roughness;
	float 				metalness;
}						t_m;

typedef struct			s_sphere
{
	packed_float3		center;
	float				r;
}						t_sphere;

typedef struct			s_cone
{
	packed_float3		head;
	packed_float3		tail;
	float				r;
}						t_cone;

typedef struct			s_plane
{
	float 				d;
	packed_float3		normal;
}						t_plane;



typedef struct			s_cylinder
{
	packed_float3		head;
	packed_float3		tail;
	float				r;
}						t_cylinder;


typedef struct			s_torus
{
	packed_float3		center;
	packed_float3		ins_vec;
	float 				R;
	float				r;
}						t_torus;

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
	packed_float3		local_x;
	packed_float3		local_y;
	packed_float3		local_z;
	t_shape_type		type;
	t_shape				obj;
}						t_obj;

typedef	struct			s_light
{
	int 				id;
	packed_float3		pos;
	packed_float3		col;
	float				power;
}						t_light;

typedef struct			s_cam
{
	int					id;
	packed_float3		pos;
	packed_float3		forward;
	packed_float3		right;
	packed_float3		up;
	packed_float2		fov;
}						t_cam;

typedef struct			s_scn
{
	int					id;
	struct s_obj		objects[RT_MAX_OBJECTS];
	int					obj_num;
	struct s_cam		cameras[RT_MAX_CAMERAS];
	int					cam_num;
	int					camera_active;
	struct s_mat		materials[RT_MAX_MATERIALS];
	int					mat_num;
	struct s_light		lights[RT_MAX_LIGHTS];
	int 				light_num;
	int					sampling_num;
}						t_scn;

typedef struct			s_ggx_loop
{
	Ray					normal;
	Ray					cam_ray;
	int					light_id;
	int 				mat_id;
}						t_ggx_loop;
