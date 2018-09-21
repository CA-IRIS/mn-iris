--
-- PostgreSQL database template for IRIS
--

SET client_encoding = 'UTF8';

\set ON_ERROR_STOP
BEGIN;

CREATE SCHEMA iris;
ALTER SCHEMA iris OWNER TO tms;

CREATE SCHEMA event;
ALTER SCHEMA event OWNER TO tms;

SET SESSION AUTHORIZATION 'tms';

SET search_path = public, pg_catalog;

--
-- Events
--
CREATE SEQUENCE event.event_id_seq;

CREATE TABLE event.event_description (
	event_desc_id INTEGER PRIMARY KEY,
	description text NOT NULL
);

COPY event.event_description (event_desc_id, description) FROM stdin;
1	Alarm TRIGGERED
2	Alarm CLEARED
8	Comm ERROR
9	Comm RESTORED
10	Comm QUEUE DRAINED
11	Comm POLL TIMEOUT
12	Comm PARSING ERROR
13	Comm CHECKSUM ERROR
14	Comm CONTROLLER ERROR
20	Incident CLEARED
21	Incident CRASH
22	Incident STALL
23	Incident HAZARD
24	Incident ROADWORK
29	Incident IMPACT
65	Comm FAILED
89	LCS DEPLOYED
90	LCS CLEARED
91	Sign DEPLOYED
92	Sign CLEARED
94	NO HITS
95	LOCKED ON
96	CHATTER
101	Sign BRIGHTNESS LOW
102	Sign BRIGHTNESS GOOD
103	Sign BRIGHTNESS HIGH
201	Client CONNECT
202	Client AUTHENTICATE
203	Client FAIL AUTHENTICATION
204	Client DISCONNECT
301	Gate Arm UNKNOWN
302	Gate Arm FAULT
303	Gate Arm OPENING
304	Gate Arm OPEN
305	Gate Arm WARN CLOSE
306	Gate Arm CLOSING
307	Gate Arm CLOSED
308	Gate Arm TIMEOUT
401	Meter event
501	Beacon ON
502	Beacon OFF
601	Tag Read
651	Price DEPLOYED
652	Price VERIFIED
701	TT Link too long
702	TT No data
703	TT No destination data
704	TT No origin data
705	TT No route
801	Camera SWITCHED
900	Action Plan ACTIVATED
901	Action Plan DEACTIVATED
902	Action Plan Phase CHANGED
\.

--
-- System attributes
--
CREATE TABLE iris.system_attribute (
	name VARCHAR(32) PRIMARY KEY,
	value VARCHAR(64) NOT NULL
);

COPY iris.system_attribute (name, value) FROM stdin;
action_plan_alert_list	
action_plan_event_purge_days	90
camera_autoplay	true
camera_construction_url	
camera_image_base_url	
camera_kbd_panasonic_enable	false
camera_num_blank	999
camera_out_of_service_url	
camera_sequence_dwell_sec	5
camera_preset_store_enable	false
camera_ptz_blind	true
camera_stream_controls_enable	false
camera_switch_event_purge_days	30
camera_wiper_precip_mm_hr	8
client_units_si	true
comm_event_purge_days	14
comm_idle_disconnect_dms_sec	0
comm_idle_disconnect_gps_sec	5
comm_idle_disconnect_modem_sec	20
database_version	4.80.0
detector_auto_fail_enable	true
dict_allowed_scheme	0
dict_banned_scheme	0
dms_brightness_enable	true
dms_comm_loss_enable	true
dms_composer_edit_mode	1
dms_default_justification_line	3
dms_default_justification_page	2
dms_duration_enable	true
dms_font_selection_enable	false
dms_gps_jitter_m	100
dms_high_temp_cutoff	60
dms_lamp_test_timeout_secs	30
dms_manufacturer_enable	true
dms_max_lines	3
dms_message_min_pages	1
dms_page_off_default_secs	0.0
dms_page_on_default_secs	2.0
dms_page_on_max_secs	10.0
dms_page_on_min_secs	0.5
dms_page_on_selection_enable	false
dms_pixel_off_limit	2
dms_pixel_on_limit	1
dms_pixel_maint_threshold	35
dms_pixel_status_enable	true
dms_pixel_test_timeout_secs	30
dms_querymsg_enable	false
dms_quickmsg_store_enable	false
dms_reset_enable	false
dms_send_confirmation_enable	false
dms_update_font_table	true
dmsxml_modem_op_timeout_secs	305
dmsxml_op_timeout_secs	65
dmsxml_reinit_detect	false
email_sender_server	
email_smtp_host	
email_recipient_action_plan	
email_recipient_aws	
email_recipient_dmsxml_reinit	
email_recipient_gate_arm	
gate_arm_alert_timeout_secs	90
help_trouble_ticket_enable	false
help_trouble_ticket_url	
incident_clear_secs	600
map_extent_name_initial	Home
map_icon_size_scale_max	30
map_segment_max_meters	2000
meter_event_purge_days	14
meter_green_secs	1.3
meter_max_red_secs	13.0
meter_min_red_secs	0.1
meter_yellow_secs	0.7
msg_feed_verify	true
operation_retry_threshold	3
route_max_legs	8
route_max_miles	16
rwis_high_wind_speed_kph	40
rwis_low_visibility_distance_m	152
rwis_obs_age_limit_secs	240
rwis_max_valid_wind_speed_kph	282
sample_archive_enable	true
speed_limit_min_mph	45
speed_limit_default_mph	55
speed_limit_max_mph	75
toll_density_alpha	0.045
toll_density_beta	1.1
toll_min_price	0.25
toll_max_price	8
travel_time_min_mph	15
uptime_log_enable	false
vsa_bottleneck_id_mph	55
vsa_control_threshold	-1000
vsa_downstream_miles	0.2
vsa_max_display_mph	60
vsa_min_display_mph	30
vsa_min_station_miles	0.1
vsa_start_intervals	3
vsa_start_threshold	-1500
vsa_stop_threshold	-750
window_title	IRIS: 
work_request_url	
\.

-- Helper function to check and update database version from migrate scripts
CREATE FUNCTION iris.update_version(TEXT, TEXT) RETURNS TEXT AS
	$update_version$
DECLARE
	ver_prev ALIAS FOR $1;
	ver_new ALIAS FOR $2;
	ver_db TEXT;
BEGIN
	SELECT value INTO ver_db FROM iris.system_attribute
		WHERE name = 'database_version';
	IF ver_db != ver_prev THEN
		RAISE EXCEPTION 'Cannot migrate database -- wrong version: %',
			ver_db;
	END IF;
	UPDATE iris.system_attribute SET value = ver_new
		WHERE name = 'database_version';
	RETURN ver_new;
END;
$update_version$ language plpgsql;

--
-- Roles, Users, Capabilities and Privileges
--
CREATE TABLE iris.role (
	name VARCHAR(15) PRIMARY KEY,
	enabled BOOLEAN NOT NULL
);

COPY iris.role (name, enabled) FROM stdin;
administrator	t
operator	t
\.

CREATE TABLE iris.i_user (
	name VARCHAR(15) PRIMARY KEY,
	full_name VARCHAR(31) NOT NULL,
	password VARCHAR(64) NOT NULL,
	dn VARCHAR(64) NOT NULL,
	role VARCHAR(15) REFERENCES iris.role,
	enabled BOOLEAN NOT NULL
);

COPY iris.i_user (name, full_name, password, dn, role, enabled) FROM stdin;
admin	IRIS Administrator	+vAwDtk/0KGx9k+kIoKFgWWbd3Ku8e/FOHoZoHB65PAuNEiN2muHVavP0fztOi4=		administrator	t
\.

CREATE VIEW i_user_view AS
	SELECT name, full_name, dn, role, enabled
	FROM iris.i_user;
GRANT SELECT ON i_user_view TO PUBLIC;

CREATE TABLE iris.capability (
	name VARCHAR(16) PRIMARY KEY,
	enabled BOOLEAN NOT NULL
);

COPY iris.capability (name, enabled) FROM stdin;
base	t
base_admin	t
base_policy	t
beacon_admin	t
beacon_control	t
beacon_tab	t
camera_admin	t
camera_control	t
camera_policy	t
camera_tab	t
comm_admin	t
comm_control	t
comm_tab	t
dms_admin	t
dms_control	t
dms_policy	t
dms_tab	t
gate_arm_admin	t
gate_arm_control	t
gate_arm_tab	t
incident_admin	t
incident_control	t
incident_tab	t
lcs_admin	t
lcs_control	t
lcs_tab	t
meter_admin	t
meter_control	t
meter_tab	t
plan_admin	t
plan_control	t
plan_tab	t
sensor_admin	t
sensor_control	t
sensor_tab	t
toll_admin	t
toll_tab	t
parking_admin	t
parking_tab	t
\.

CREATE TABLE iris.sonar_type (
	name VARCHAR(16) PRIMARY KEY
);

COPY iris.sonar_type (name) FROM stdin;
action_plan
alarm
beacon
beacon_action
cabinet
cabinet_style
camera
camera_preset
capability
catalog
comm_link
connection
controller
day_matcher
day_plan
detector
dms
dms_action
dms_sign_group
encoder_type
font
gate_arm
gate_arm_array
geo_loc
glyph
gps
graphic
inc_advice
inc_descriptor
incident
incident_detail
inc_locator
lane_action
lane_marking
lane_use_multi
lcs
lcs_array
lcs_indication
map_extent
meter_action
modem
monitor_style
parking_area
plan_phase
play_list
privilege
quick_message
ramp_meter
r_node
road
role
sign_config
sign_group
sign_message
sign_text
station
system_attribute
tag_reader
time_action
toll_zone
user
video_monitor
weather_sensor
word
\.

CREATE TABLE iris.privilege (
	name VARCHAR(8) PRIMARY KEY,
	capability VARCHAR(16) NOT NULL REFERENCES iris.capability,
	type_n VARCHAR(16) NOT NULL REFERENCES iris.sonar_type,
	obj_n VARCHAR(16) DEFAULT ''::VARCHAR NOT NULL,
	group_n VARCHAR(16) DEFAULT ''::VARCHAR NOT NULL,
	attr_n VARCHAR(16) DEFAULT ''::VARCHAR NOT NULL,
	write BOOLEAN DEFAULT false NOT NULL
);

COPY iris.privilege (name, capability, type_n, attr_n, write) FROM stdin;
PRV_0001	base	user		f
PRV_0002	base	role		f
PRV_0003	base	capability		f
PRV_0004	base	privilege		f
PRV_0005	base	connection		f
PRV_0006	base	system_attribute		f
PRV_0007	base	map_extent		f
PRV_0008	base	road		f
PRV_0009	base	geo_loc		f
PRV_0010	base	cabinet		f
PRV_0011	base	controller		f
PRV_0012	base_admin	user		t
PRV_0013	base_admin	role		t
PRV_0014	base_admin	privilege		t
PRV_0015	base_admin	capability		t
PRV_0016	base_admin	connection		t
PRV_0017	base_policy	geo_loc		t
PRV_0018	base_policy	map_extent		t
PRV_0019	base_policy	road		t
PRV_0020	base_policy	system_attribute		t
PRV_0021	beacon_admin	beacon		t
PRV_0022	beacon_control	beacon	flashing	t
PRV_0023	beacon_tab	beacon		f
PRV_0024	camera_admin	camera		t
PRV_0025	camera_admin	encoder_type		t
PRV_0026	camera_admin	camera_preset		t
PRV_0027	camera_admin	video_monitor		t
PRV_0028	camera_admin	monitor_style		t
PRV_002C	camera_admin	play_list		t
PRV_002D	camera_admin	catalog		t
PRV_0029	camera_control	camera	ptz	t
PRV_0030	camera_control	camera	recallPreset	t
PRV_0031	camera_control	camera	deviceRequest	t
PRV_0032	camera_policy	camera	publish	t
PRV_0033	camera_policy	camera	storePreset	t
PRV_0034	camera_tab	encoder_type		f
PRV_0035	camera_tab	camera		f
PRV_0036	camera_tab	camera_preset		f
PRV_0037	camera_tab	video_monitor		f
PRV_0038	camera_tab	monitor_style		f
PRV_003C	camera_tab	play_list		f
PRV_003E	camera_tab	catalog		f
PRV_0039	comm_admin	comm_link		t
PRV_0040	comm_admin	modem		t
PRV_0041	comm_admin	cabinet_style		t
PRV_0042	comm_admin	cabinet		t
PRV_0043	comm_admin	controller		t
PRV_0044	comm_admin	alarm		t
PRV_0045	comm_control	controller	condition	t
PRV_0046	comm_control	controller	download	t
PRV_0047	comm_control	controller	counters	t
PRV_0048	comm_tab	comm_link		f
PRV_0049	comm_tab	modem		f
PRV_0050	comm_tab	alarm		f
PRV_0051	comm_tab	cabinet_style		f
PRV_0052	dms_admin	dms		t
PRV_0053	dms_admin	font		t
PRV_0054	dms_admin	glyph		t
PRV_0055	dms_admin	gps		t
PRV_0056	dms_admin	graphic		t
PRV_0057	dms_admin	sign_config		t
PRV_0058	dms_control	dms	msgUser	t
PRV_0059	dms_control	dms	deviceRequest	t
PRV_0060	dms_control	sign_message		t
PRV_0061	dms_policy	dms_sign_group		t
PRV_0062	dms_policy	quick_message		t
PRV_0063	dms_policy	sign_group		t
PRV_0064	dms_policy	sign_text		t
PRV_0065	dms_policy	word		t
PRV_0066	dms_tab	dms		f
PRV_0067	dms_tab	dms_sign_group		f
PRV_0068	dms_tab	font		f
PRV_0069	dms_tab	glyph		f
PRV_0070	dms_tab	gps		f
PRV_0071	dms_tab	graphic		f
PRV_0072	dms_tab	quick_message		f
PRV_0073	dms_tab	sign_config		f
PRV_0074	dms_tab	sign_group		f
PRV_0075	dms_tab	sign_message		f
PRV_0076	dms_tab	sign_text		f
PRV_0077	dms_tab	word		f
PRV_0078	gate_arm_admin	gate_arm		t
PRV_0079	gate_arm_admin	gate_arm_array		t
PRV_0080	gate_arm_control	gate_arm_array	armStateNext	t
PRV_0081	gate_arm_control	gate_arm_array	ownerNext	t
PRV_0082	gate_arm_control	gate_arm_array	deviceRequest	t
PRV_0083	gate_arm_tab	gate_arm		f
PRV_0084	gate_arm_tab	gate_arm_array		f
PRV_0085	gate_arm_tab	camera		f
PRV_0086	gate_arm_tab	encoder_type		f
PRV_0087	incident_admin	incident_detail		t
PRV_0088	incident_admin	inc_descriptor		t
PRV_0089	incident_admin	inc_locator		t
PRV_0090	incident_admin	inc_advice		t
PRV_0091	incident_control	incident		t
PRV_0092	incident_tab	incident		f
PRV_0093	incident_tab	incident_detail		f
PRV_0094	incident_tab	inc_descriptor		f
PRV_0095	incident_tab	inc_locator		f
PRV_0096	incident_tab	inc_advice		f
PRV_0097	lcs_admin	lane_use_multi		t
PRV_0098	lcs_admin	lcs		t
PRV_0099	lcs_admin	lcs_array		t
PRV_0100	lcs_admin	lcs_indication		t
PRV_0101	lcs_admin	lane_marking		t
PRV_0102	lcs_control	lcs_array	indicationsNext	t
PRV_0103	lcs_control	lcs_array	ownerNext	t
PRV_0104	lcs_control	lcs_array	lcsLock	t
PRV_0105	lcs_control	lcs_array	deviceRequest	t
PRV_0106	lcs_tab	dms		f
PRV_0107	lcs_tab	lane_use_multi		f
PRV_0108	lcs_tab	lcs		f
PRV_0109	lcs_tab	lcs_array		f
PRV_0110	lcs_tab	lcs_indication		f
PRV_0111	lcs_tab	quick_message		f
PRV_0112	lcs_tab	lane_marking		f
PRV_0113	meter_admin	ramp_meter		t
PRV_0114	meter_control	ramp_meter	mLock	t
PRV_0115	meter_control	ramp_meter	rateNext	t
PRV_0116	meter_control	ramp_meter	deviceRequest	t
PRV_0117	meter_tab	ramp_meter		f
PRV_0118	plan_admin	action_plan		t
PRV_0119	plan_admin	day_plan		t
PRV_0120	plan_admin	day_matcher		t
PRV_0121	plan_admin	plan_phase		t
PRV_0122	plan_admin	time_action		t
PRV_0123	plan_admin	dms_action		t
PRV_0124	plan_admin	beacon_action		t
PRV_0125	plan_admin	lane_action		t
PRV_0126	plan_admin	meter_action		t
PRV_0127	plan_control	action_plan	phase	t
PRV_0128	plan_tab	action_plan		f
PRV_0129	plan_tab	day_plan		f
PRV_0130	plan_tab	day_matcher		f
PRV_0131	plan_tab	plan_phase		f
PRV_0132	plan_tab	time_action		f
PRV_0133	plan_tab	dms_action		f
PRV_0134	plan_tab	beacon_action		f
PRV_0135	plan_tab	lane_action		f
PRV_0136	plan_tab	meter_action		f
PRV_0137	sensor_admin	detector		t
PRV_0138	sensor_admin	r_node		t
PRV_0139	sensor_admin	weather_sensor		t
PRV_0140	sensor_control	detector	fieldLength	t
PRV_0141	sensor_control	detector	forceFail	t
PRV_0142	sensor_tab	r_node		f
PRV_0143	sensor_tab	detector		f
PRV_0144	sensor_tab	station		f
PRV_0145	sensor_tab	weather_sensor		f
PRV_0146	toll_admin	tag_reader		t
PRV_0147	toll_admin	toll_zone		t
PRV_0148	toll_tab	tag_reader		f
PRV_0149	toll_tab	toll_zone		f
PRV_0150	parking_admin	parking_area		t
PRV_0151	parking_tab	parking_area		f
\.

COPY iris.privilege (name, capability, type_n, group_n, write) FROM stdin;
PRV_003D	camera_tab	play_list	user	t
\.

CREATE TABLE iris.role_capability (
	role VARCHAR(15) NOT NULL REFERENCES iris.role,
	capability VARCHAR(16) NOT NULL REFERENCES iris.capability
);
ALTER TABLE iris.role_capability ADD PRIMARY KEY (role, capability);

COPY iris.role_capability (role, capability) FROM stdin;
administrator	base
administrator	base_admin
administrator	base_policy
administrator	beacon_admin
administrator	beacon_control
administrator	beacon_tab
administrator	camera_admin
administrator	camera_control
administrator	camera_policy
administrator	camera_tab
administrator	comm_admin
administrator	comm_control
administrator	comm_tab
administrator	dms_admin
administrator	dms_control
administrator	dms_policy
administrator	dms_tab
administrator	gate_arm_admin
administrator	gate_arm_control
administrator	gate_arm_tab
administrator	incident_admin
administrator	incident_control
administrator	incident_tab
administrator	lcs_admin
administrator	lcs_control
administrator	lcs_tab
administrator	meter_admin
administrator	meter_control
administrator	meter_tab
administrator	plan_admin
administrator	plan_control
administrator	plan_tab
administrator	sensor_admin
administrator	sensor_control
administrator	sensor_tab
administrator	toll_admin
administrator	toll_tab
administrator	parking_admin
administrator	parking_tab
operator	base
operator	beacon_control
operator	beacon_tab
operator	camera_control
operator	camera_tab
operator	dms_control
operator	dms_tab
operator	gate_arm_tab
operator	incident_control
operator	incident_tab
operator	lcs_control
operator	lcs_tab
operator	meter_control
operator	meter_tab
operator	plan_control
operator	plan_tab
operator	sensor_tab
operator	toll_tab
\.

CREATE VIEW role_privilege_view AS
	SELECT role, role_capability.capability, type_n, obj_n, group_n, attr_n,
	       write
	FROM iris.role
	JOIN iris.role_capability ON role.name = role_capability.role
	JOIN iris.capability ON role_capability.capability = capability.name
	JOIN iris.privilege ON privilege.capability = capability.name
	WHERE role.enabled = 't' AND capability.enabled = 't';
GRANT SELECT ON role_privilege_view TO PUBLIC;

CREATE TABLE event.client_event (
	event_id integer PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date timestamp WITH time zone NOT NULL,
	event_desc_id integer NOT NULL
		REFERENCES event.event_description(event_desc_id),
	host_port VARCHAR(64) NOT NULL,
	iris_user VARCHAR(15)
);

CREATE VIEW client_event_view AS
	SELECT e.event_id, e.event_date, ed.description, e.host_port,
	       e.iris_user
	FROM event.client_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id;
GRANT SELECT ON client_event_view TO PUBLIC;

--
-- Direction, Road, Geo Location, R_Node, Map Extent
--
CREATE TABLE iris.direction (
	id SMALLINT PRIMARY KEY,
	direction VARCHAR(4) NOT NULL,
	dir VARCHAR(4) NOT NULL
);

COPY iris.direction (id, direction, dir) FROM stdin;
0		
1	NB	N
2	SB	S
3	EB	E
4	WB	W
5	N-S	N-S
6	E-W	E-W
7	IN	IN
8	OUT	OUT
\.

CREATE TABLE iris.road_class (
	id INTEGER PRIMARY KEY,
	description VARCHAR(12) NOT NULL,
	grade CHAR NOT NULL
);

COPY iris.road_class (id, description, grade) FROM stdin;
0		
1	residential	A
2	business	B
3	collector	C
4	arterial	D
5	expressway	E
6	freeway	F
7	CD road	
\.

CREATE TABLE iris.road_modifier (
	id SMALLINT PRIMARY KEY,
	modifier text NOT NULL,
	mod VARCHAR(2) NOT NULL
);

COPY iris.road_modifier (id, modifier, mod) FROM stdin;
0	@	
1	N of	N
2	S of	S
3	E of	E
4	W of	W
5	N Junction	Nj
6	S Junction	Sj
7	E Junction	Ej
8	W Junction	Wj
\.

CREATE TABLE iris.road (
	name VARCHAR(20) PRIMARY KEY,
	abbrev VARCHAR(6) NOT NULL,
	r_class SMALLINT NOT NULL REFERENCES iris.road_class(id),
	direction SMALLINT NOT NULL REFERENCES iris.direction(id),
	alt_dir SMALLINT NOT NULL REFERENCES iris.direction(id)
);

CREATE VIEW road_view AS
	SELECT name, abbrev, rcl.description AS r_class, dir.direction,
	       adir.direction AS alt_dir
	FROM iris.road r
	LEFT JOIN iris.road_class rcl ON r.r_class = rcl.id
	LEFT JOIN iris.direction dir ON r.direction = dir.id
	LEFT JOIN iris.direction adir ON r.alt_dir = adir.id;
GRANT SELECT ON road_view TO PUBLIC;

CREATE TABLE iris.geo_loc (
	name VARCHAR(20) PRIMARY KEY,
	roadway VARCHAR(20) REFERENCES iris.road(name),
	road_dir SMALLINT REFERENCES iris.direction(id),
	cross_street VARCHAR(20) REFERENCES iris.road(name),
	cross_dir SMALLINT REFERENCES iris.direction(id),
	cross_mod SMALLINT REFERENCES iris.road_modifier(id),
	lat double precision,
	lon double precision,
	landmark VARCHAR(24)
);

CREATE FUNCTION iris.geo_location(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT)
	RETURNS TEXT AS $geo_location$
DECLARE
	roadway ALIAS FOR $1;
	road_dir ALIAS FOR $2;
	cross_mod ALIAS FOR $3;
	cross_street ALIAS FOR $4;
	cross_dir ALIAS FOR $5;
	landmark ALIAS FOR $6;
	res TEXT;
BEGIN
	res = trim(roadway || ' ' || road_dir);
	IF char_length(cross_street) > 0 THEN
		RETURN trim(concat(res || ' ', cross_mod || ' ', cross_street),
		            ' ' || cross_dir);
	ELSIF char_length(landmark) > 0 THEN
		RETURN concat(res || ' ', '(' || landmark || ')');
	ELSE
		RETURN res;
	END IF;
END;
$geo_location$ LANGUAGE plpgsql;

CREATE VIEW geo_loc_view AS
	SELECT l.name, r.abbrev AS rd, l.roadway, r_dir.direction AS road_dir,
	       r_dir.dir AS rdir, m.modifier AS cross_mod, m.mod AS xmod,
	       c.abbrev as xst, l.cross_street, c_dir.direction AS cross_dir,
	       l.lat, l.lon, l.landmark,
	       iris.geo_location(l.roadway, r_dir.direction, m.modifier,
	       l.cross_street, c_dir.direction, l.landmark) AS location
	FROM iris.geo_loc l
	LEFT JOIN iris.road r ON l.roadway = r.name
	LEFT JOIN iris.road_modifier m ON l.cross_mod = m.id
	LEFT JOIN iris.road c ON l.cross_street = c.name
	LEFT JOIN iris.direction r_dir ON l.road_dir = r_dir.id
	LEFT JOIN iris.direction c_dir ON l.cross_dir = c_dir.id;
GRANT SELECT ON geo_loc_view TO PUBLIC;

CREATE TABLE iris.r_node_type (
	n_type INTEGER PRIMARY KEY,
	name VARCHAR(12) NOT NULL
);

COPY iris.r_node_type (n_type, name) FROM stdin;
0	station
1	entrance
2	exit
3	intersection
4	access
5	interchange
\.

CREATE TABLE iris.r_node_transition (
	n_transition INTEGER PRIMARY KEY,
	name VARCHAR(12) NOT NULL
);

COPY iris.r_node_transition (n_transition, name) FROM stdin;
0	none
1	loop
2	leg
3	slipramp
4	CD
5	HOV
6	common
7	flyover
\.

CREATE TABLE iris.r_node (
	name VARCHAR(10) PRIMARY KEY,
	geo_loc VARCHAR(20) NOT NULL REFERENCES iris.geo_loc(name),
	node_type INTEGER NOT NULL REFERENCES iris.r_node_type,
	pickable BOOLEAN NOT NULL,
	above BOOLEAN NOT NULL,
	transition INTEGER NOT NULL REFERENCES iris.r_node_transition,
	lanes INTEGER NOT NULL,
	attach_side BOOLEAN NOT NULL,
	shift INTEGER NOT NULL,
	active BOOLEAN NOT NULL,
	abandoned BOOLEAN NOT NULL,
	station_id VARCHAR(10),
	speed_limit INTEGER NOT NULL,
	notes text NOT NULL
);

CREATE UNIQUE INDEX r_node_station_idx ON iris.r_node USING btree (station_id);

CREATE FUNCTION iris.r_node_left(INTEGER, INTEGER, BOOLEAN, INTEGER)
	RETURNS INTEGER AS $r_node_left$
DECLARE
	node_type ALIAS FOR $1;
	lanes ALIAS FOR $2;
	attach_side ALIAS FOR $3;
	shift ALIAS FOR $4;
BEGIN
	IF attach_side = TRUE THEN
		RETURN shift;
	END IF;
	IF node_type = 0 THEN
		RETURN shift - lanes;
	END IF;
	RETURN shift;
END;
$r_node_left$ LANGUAGE plpgsql;

CREATE FUNCTION iris.r_node_right(INTEGER, INTEGER, BOOLEAN, INTEGER)
	RETURNS INTEGER AS $r_node_right$
DECLARE
	node_type ALIAS FOR $1;
	lanes ALIAS FOR $2;
	attach_side ALIAS FOR $3;
	shift ALIAS FOR $4;
BEGIN
	IF attach_side = FALSE THEN
		RETURN shift;
	END IF;
	IF node_type = 0 THEN
		RETURN shift + lanes;
	END IF;
	RETURN shift;
END;
$r_node_right$ LANGUAGE plpgsql;

ALTER TABLE iris.r_node ADD CONSTRAINT left_edge_ck
	CHECK (iris.r_node_left(node_type, lanes, attach_side, shift) >= 1);
ALTER TABLE iris.r_node ADD CONSTRAINT right_edge_ck
	CHECK (iris.r_node_right(node_type, lanes, attach_side, shift) <= 9);
ALTER TABLE iris.r_node ADD CONSTRAINT active_ck
	CHECK (active = FALSE OR abandoned = FALSE);

CREATE VIEW r_node_view AS
	SELECT n.name, roadway, road_dir, cross_mod, cross_street,
	       cross_dir, nt.name AS node_type, n.pickable, n.above,
	       tr.name AS transition, n.lanes, n.attach_side, n.shift, n.active,
	       n.abandoned, n.station_id, n.speed_limit, n.notes
	FROM iris.r_node n
	JOIN geo_loc_view l ON n.geo_loc = l.name
	JOIN iris.r_node_type nt ON n.node_type = nt.n_type
	JOIN iris.r_node_transition tr ON n.transition = tr.n_transition;
GRANT SELECT ON r_node_view TO PUBLIC;

CREATE VIEW roadway_station_view AS
	SELECT station_id, roadway, road_dir, cross_mod, cross_street, active,
	       speed_limit
	FROM iris.r_node r, geo_loc_view l
	WHERE r.geo_loc = l.name AND station_id IS NOT NULL;
GRANT SELECT ON roadway_station_view TO PUBLIC;

CREATE TABLE iris.map_extent (
	name VARCHAR(20) PRIMARY KEY,
	lat real NOT NULL,
	lon real NOT NULL,
	zoom INTEGER NOT NULL
);

--
-- Day Matchers, Day Plans, Plan Phases, Action Plans and Time Actions
--
CREATE TABLE iris.day_matcher (
	name VARCHAR(32) PRIMARY KEY,
	holiday BOOLEAN NOT NULL,
	month INTEGER NOT NULL,
	day INTEGER NOT NULL,
	week INTEGER NOT NULL,
	weekday INTEGER NOT NULL,
	shift INTEGER NOT NULL
);

COPY iris.day_matcher (name, holiday, month, day, week, weekday, shift) FROM stdin;
Any Day	f	-1	0	0	0	0
Sunday Holiday	t	-1	0	0	1	0
Saturday Holiday	t	-1	0	0	7	0
New Years Day	t	0	1	0	0	0
Memorial Day	t	4	0	-1	2	0
Independence Day	t	6	4	0	0	0
Labor Day	t	8	0	1	2	0
Thanksgiving Day	t	10	0	4	5	0
Black Friday	t	10	0	4	5	1
Christmas Eve	t	11	24	0	0	0
Christmas Day	t	11	25	0	0	0
New Years Eve	t	11	31	0	0	0
\.

CREATE TABLE iris.day_plan (
	name VARCHAR(10) PRIMARY KEY
);

COPY iris.day_plan (name) FROM stdin;
EVERY_DAY
WEEKDAYS
WORK_DAYS
\.

CREATE TABLE iris.day_plan_day_matcher (
	day_plan VARCHAR(10) NOT NULL REFERENCES iris.day_plan,
	day_matcher VARCHAR(32) NOT NULL REFERENCES iris.day_matcher
);
ALTER TABLE iris.day_plan_day_matcher ADD PRIMARY KEY (day_plan, day_matcher);

COPY iris.day_plan_day_matcher (day_plan, day_matcher) FROM stdin;
EVERY_DAY	Any Day
WEEKDAYS	Any Day
WEEKDAYS	Sunday Holiday
WEEKDAYS	Saturday Holiday
WORK_DAYS	Any Day
WORK_DAYS	Sunday Holiday
WORK_DAYS	Saturday Holiday
WORK_DAYS	New Years Day
WORK_DAYS	Memorial Day
WORK_DAYS	Independence Day
WORK_DAYS	Labor Day
WORK_DAYS	Thanksgiving Day
WORK_DAYS	Black Friday
WORK_DAYS	Christmas Eve
WORK_DAYS	Christmas Day
WORK_DAYS	New Years Eve
\.

CREATE TABLE iris.plan_phase (
	name VARCHAR(12) PRIMARY KEY,
	hold_time INTEGER NOT NULL,
	next_phase VARCHAR(12) REFERENCES iris.plan_phase
);

COPY iris.plan_phase (name, hold_time, next_phase) FROM stdin;
deployed	0	\N
undeployed	0	\N
\.

CREATE TABLE iris.action_plan (
	name VARCHAR(16) PRIMARY KEY,
	description VARCHAR(64) NOT NULL,
	group_n VARCHAR(16),
	sync_actions BOOLEAN NOT NULL,
	sticky BOOLEAN NOT NULL,
	active BOOLEAN NOT NULL,
	default_phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase
);

CREATE VIEW action_plan_view AS
	SELECT name, description, group_n, sync_actions, sticky, active,
	       default_phase, phase
	FROM iris.action_plan;
GRANT SELECT ON action_plan_view TO PUBLIC;

CREATE TABLE iris.time_action (
	name VARCHAR(30) PRIMARY KEY,
	action_plan VARCHAR(16) NOT NULL REFERENCES iris.action_plan,
	day_plan VARCHAR(10) REFERENCES iris.day_plan,
	sched_date DATE,
	time_of_day TIME WITHOUT TIME ZONE NOT NULL,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase,
	CONSTRAINT time_action_date CHECK (
		((day_plan IS NULL) OR (sched_date IS NULL)) AND
		((day_plan IS NOT NULL) OR (sched_date IS NOT NULL))
	)
);

CREATE VIEW time_action_view AS
	SELECT name, action_plan, day_plan, sched_date, time_of_day, phase
	FROM iris.time_action;
GRANT SELECT ON time_action_view TO PUBLIC;

CREATE TABLE event.action_plan_event (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	action_plan VARCHAR(16) NOT NULL,
	detail VARCHAR(15) NOT NULL
);

CREATE VIEW action_plan_event_view AS
	SELECT e.event_id, e.event_date, ed.description AS event_description,
	       e.action_plan, e.detail
	FROM event.action_plan_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id;
GRANT SELECT ON action_plan_event_view TO PUBLIC;

--
-- Comm Protocols, Comm Links, Modems, Cabinets, Controllers
--
CREATE TABLE iris.comm_protocol (
	id SMALLINT PRIMARY KEY,
	description VARCHAR(20) NOT NULL
);

COPY iris.comm_protocol (id, description) FROM stdin;
0	NTCIP Class B
1	MnDOT 170 (4-bit)
2	MnDOT 170 (5-bit)
3	SmartSensor 105
4	Canoga
5	Pelco P
6	Pelco D PTZ
7	NTCIP Class C
8	Manchester PTZ
9	DMS XML
10	MSG_FEED
11	NTCIP Class A
12	Banner DXM
13	Vicon PTZ
14	SmartSensor 125 HD
15	OSi ORG-815
16	Infinova D PTZ
17	RTMS G4
18	RTMS
19	Infotek Wizard
20	Sensys
21	PeMS
22	SSI
23	CHP Incidents
24	URMS
25	DLI DIN Relay
26	Axis 292
27	Axis PTZ
28	HySecurity STC
29	Cohu PTZ
30	DR-500
31	ADDCO
32	TransCore E6
33	CBW
34	Incident Feed
35	MonStream
36	Gate NDORv5
37	GPS TAIP
38	GPS NMEA
39	GPS RedLion
\.

CREATE TABLE iris.comm_link (
	name VARCHAR(20) PRIMARY KEY,
	description VARCHAR(32) NOT NULL,
	modem BOOLEAN NOT NULL,
	uri VARCHAR(64) NOT NULL,
	protocol SMALLINT NOT NULL REFERENCES iris.comm_protocol(id),
	poll_enabled BOOLEAN NOT NULL,
	poll_period INTEGER NOT NULL,
	timeout INTEGER NOT NULL
);

CREATE VIEW comm_link_view AS
	SELECT cl.name, cl.description, modem, uri, cp.description AS protocol,
	       poll_enabled, poll_period, timeout
	FROM iris.comm_link cl
	JOIN iris.comm_protocol cp ON cl.protocol = cp.id;
GRANT SELECT ON comm_link_view TO PUBLIC;

CREATE TABLE iris.modem (
	name VARCHAR(20) PRIMARY KEY,
	uri VARCHAR(64) NOT NULL,
	config VARCHAR(64) NOT NULL,
	timeout INTEGER NOT NULL,
	enabled BOOLEAN NOT NULL
);

CREATE VIEW modem_view AS
	SELECT name, uri, config, timeout, enabled
	FROM iris.modem;
GRANT SELECT ON modem_view TO PUBLIC;

CREATE TABLE iris.cabinet_style (
	name VARCHAR(20) PRIMARY KEY,
	dip INTEGER
);

CREATE TABLE iris.cabinet (
	name VARCHAR(20) PRIMARY KEY,
	style VARCHAR(20) REFERENCES iris.cabinet_style(name),
	geo_loc VARCHAR(20) NOT NULL REFERENCES iris.geo_loc(name)
);

CREATE VIEW cabinet_view AS
	SELECT name, style, geo_loc
	FROM iris.cabinet;
GRANT SELECT ON cabinet_view TO PUBLIC;

CREATE TABLE iris.condition (
	id INTEGER PRIMARY KEY,
	description VARCHAR(12) NOT NULL
);

COPY iris.condition (id, description) FROM stdin;
0	Planned
1	Active
2	Construction
3	Removed
4	Testing
\.

CREATE TABLE iris.controller (
	name VARCHAR(20) PRIMARY KEY,
	drop_id SMALLINT NOT NULL,
	comm_link VARCHAR(20) NOT NULL REFERENCES iris.comm_link(name),
	cabinet VARCHAR(20) NOT NULL REFERENCES iris.cabinet(name),
	condition INTEGER NOT NULL REFERENCES iris.condition,
	password VARCHAR(32),
	notes VARCHAR(128) NOT NULL,
	fail_time TIMESTAMP WITH time zone,
	version VARCHAR(64)
);

CREATE UNIQUE INDEX ctrl_link_drop_idx ON iris.controller
	USING btree (comm_link, drop_id);

CREATE VIEW controller_view AS
	SELECT c.name, drop_id, comm_link, cabinet,
	       cnd.description AS condition, notes, cab.geo_loc, fail_time,
	       version
	FROM iris.controller c
	LEFT JOIN iris.cabinet cab ON c.cabinet = cab.name
	LEFT JOIN iris.condition cnd ON c.condition = cnd.id;
GRANT SELECT ON controller_view TO PUBLIC;

CREATE VIEW controller_loc_view AS
	SELECT c.name, drop_id, comm_link, cabinet, condition, c.notes,
	       l.roadway, l.road_dir, l.cross_mod, l.cross_street, l.cross_dir
	FROM controller_view c
	LEFT JOIN geo_loc_view l ON c.geo_loc = l.name;
GRANT SELECT ON controller_loc_view TO PUBLIC;

CREATE TABLE event.comm_event (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	controller VARCHAR(20) NOT NULL REFERENCES iris.controller(name)
		ON DELETE CASCADE,
	device_id VARCHAR(20)
);

CREATE VIEW comm_event_view AS
	SELECT e.event_id, e.event_date, ed.description, e.controller,
	       c.comm_link, c.drop_id
	FROM event.comm_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id
	LEFT JOIN iris.controller c ON e.controller = c.name;
GRANT SELECT ON comm_event_view TO PUBLIC;

CREATE TABLE iris._device_io (
	name VARCHAR(20) PRIMARY KEY,
	controller VARCHAR(20) REFERENCES iris.controller(name),
	pin INTEGER NOT NULL
);

CREATE UNIQUE INDEX _device_io_ctrl_pin ON iris._device_io
	USING btree (controller, pin);

CREATE VIEW device_controller_view AS
	SELECT name, controller, pin
	FROM iris._device_io;
GRANT SELECT ON device_controller_view TO PUBLIC;

--
-- Cameras, Encoders, Play Lists, Catalogs, Presets
--
CREATE TABLE iris.encoding (
	id INTEGER PRIMARY KEY,
	description VARCHAR(20) NOT NULL
);

COPY iris.encoding (id, description) FROM stdin;
0	UNKNOWN
1	MJPEG
2	MPEG2
3	MPEG4
4	H264
5	H265
\.

CREATE TABLE iris.encoder_type (
	name VARCHAR(24) PRIMARY KEY,
	encoding INTEGER NOT NULL REFERENCES iris.encoding,
	uri_scheme VARCHAR(8) NOT NULL,
	uri_path VARCHAR(64) NOT NULL,
	latency INTEGER NOT NULL
);

CREATE VIEW encoder_type_view AS
	SELECT name, enc.description AS encoding, uri_scheme, uri_path, latency
	FROM iris.encoder_type et
	LEFT JOIN iris.encoding enc ON et.encoding = enc.id;
GRANT SELECT ON encoder_type_view TO PUBLIC;

CREATE TABLE iris._camera (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes text NOT NULL,
	cam_num INTEGER UNIQUE,
	encoder_type VARCHAR(24) REFERENCES iris.encoder_type,
	encoder VARCHAR(64) NOT NULL,
	enc_mcast VARCHAR(64) NOT NULL,
	encoder_channel INTEGER NOT NULL,
	publish BOOLEAN NOT NULL,
	video_loss BOOLEAN NOT NULL
);

ALTER TABLE iris._camera ADD CONSTRAINT _camera_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.camera AS
	SELECT c.name, geo_loc, controller, pin, notes, cam_num, encoder_type,
	       encoder, enc_mcast, encoder_channel, publish, video_loss
	FROM iris._camera c
	JOIN iris._device_io d ON c.name = d.name;

CREATE FUNCTION iris.camera_insert() RETURNS TRIGGER AS
	$camera_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._camera (name, geo_loc, notes, cam_num, encoder_type,
	            encoder, enc_mcast, encoder_channel, publish, video_loss)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.cam_num,
	             NEW.encoder_type, NEW.encoder, NEW.enc_mcast,
	             NEW.encoder_channel, NEW.publish, NEW.video_loss);
	RETURN NEW;
END;
$camera_insert$ LANGUAGE plpgsql;

CREATE TRIGGER camera_insert_trig
    INSTEAD OF INSERT ON iris.camera
    FOR EACH ROW EXECUTE PROCEDURE iris.camera_insert();

CREATE FUNCTION iris.camera_update() RETURNS TRIGGER AS
	$camera_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._camera
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       cam_num = NEW.cam_num,
	       encoder_type = NEW.encoder_type,
	       encoder = NEW.encoder,
	       enc_mcast = NEW.enc_mcast,
	       encoder_channel = NEW.encoder_channel,
	       publish = NEW.publish,
	       video_loss = NEW.video_loss
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$camera_update$ LANGUAGE plpgsql;

CREATE TRIGGER camera_update_trig
    INSTEAD OF UPDATE ON iris.camera
    FOR EACH ROW EXECUTE PROCEDURE iris.camera_update();

CREATE FUNCTION iris.camera_delete() RETURNS TRIGGER AS
	$camera_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$camera_delete$ LANGUAGE plpgsql;

CREATE TRIGGER camera_delete_trig
    INSTEAD OF DELETE ON iris.camera
    FOR EACH ROW EXECUTE PROCEDURE iris.camera_delete();

CREATE VIEW camera_view AS
	SELECT c.name, c.notes, cam_num, encoder_type, c.encoder, c.enc_mcast,
	       c.encoder_channel, c.publish, c.video_loss, c.geo_loc,
	       l.roadway, l.road_dir, l.cross_mod, l.cross_street, l.cross_dir,
	       l.location, l.lat, l.lon,
	       c.controller, ctr.comm_link, ctr.drop_id, ctr.condition
	FROM iris.camera c
	LEFT JOIN geo_loc_view l ON c.geo_loc = l.name
	LEFT JOIN controller_view ctr ON c.controller = ctr.name;
GRANT SELECT ON camera_view TO PUBLIC;

CREATE TABLE iris._cam_sequence (
	seq_num INTEGER PRIMARY KEY
);

CREATE TABLE iris._play_list (
	name VARCHAR(20) PRIMARY KEY,
	seq_num INTEGER REFERENCES iris._cam_sequence,
	description VARCHAR(32)
);

CREATE VIEW iris.play_list AS
	SELECT name, seq_num, description
	FROM iris._play_list;

CREATE FUNCTION iris.play_list_insert() RETURNS TRIGGER AS
	$play_list_insert$
BEGIN
	IF NEW.seq_num IS NOT NULL THEN
		INSERT INTO iris._cam_sequence (seq_num) VALUES (NEW.seq_num);
	END IF;
	INSERT INTO iris._play_list (name, seq_num, description)
	     VALUES (NEW.name, NEW.seq_num, NEW.description);
	RETURN NEW;
END;
$play_list_insert$ LANGUAGE plpgsql;

CREATE TRIGGER play_list_insert_trig
    INSTEAD OF INSERT ON iris.play_list
    FOR EACH ROW EXECUTE PROCEDURE iris.play_list_insert();

CREATE FUNCTION iris.play_list_update() RETURNS TRIGGER AS
	$play_list_update$
BEGIN
	IF NEW.seq_num IS NOT NULL AND (OLD.seq_num IS NULL OR
	                                NEW.seq_num != OLD.seq_num)
	THEN
		INSERT INTO iris._cam_sequence (seq_num) VALUES (NEW.seq_num);
	END IF;
	UPDATE iris._play_list
	   SET seq_num = NEW.seq_num,
	       description = NEW.description
	 WHERE name = OLD.name;
	IF OLD.seq_num IS NOT NULL AND (NEW.seq_num IS NULL OR
	                                NEW.seq_num != OLD.seq_num)
	THEN
		DELETE FROM iris._cam_sequence WHERE seq_num = OLD.seq_num;
	END IF;
	RETURN NEW;
END;
$play_list_update$ LANGUAGE plpgsql;

CREATE TRIGGER play_list_update_trig
    INSTEAD OF UPDATE ON iris.play_list
    FOR EACH ROW EXECUTE PROCEDURE iris.play_list_update();

CREATE FUNCTION iris.play_list_delete() RETURNS TRIGGER AS
	$play_list_delete$
BEGIN
	DELETE FROM iris._play_list WHERE name = OLD.name;
	IF FOUND THEN
		DELETE FROM iris._cam_sequence WHERE seq_num = OLD.seq_num;
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$play_list_delete$ LANGUAGE plpgsql;

CREATE TRIGGER play_list_delete_trig
    INSTEAD OF DELETE ON iris.play_list
    FOR EACH ROW EXECUTE PROCEDURE iris.play_list_delete();

CREATE TABLE iris.play_list_camera (
	play_list VARCHAR(20) NOT NULL REFERENCES iris._play_list,
	ordinal INTEGER NOT NULL,
	camera VARCHAR(20) NOT NULL REFERENCES iris._camera
);
ALTER TABLE iris.play_list_camera ADD PRIMARY KEY (play_list, ordinal);

CREATE VIEW play_list_view AS
	SELECT play_list, ordinal, seq_num, camera
	FROM iris.play_list_camera
	JOIN iris.play_list ON play_list_camera.play_list = play_list.name;
GRANT SELECT ON play_list_view TO PUBLIC;

CREATE TABLE iris._catalog (
	name VARCHAR(20) PRIMARY KEY,
	seq_num INTEGER NOT NULL REFERENCES iris._cam_sequence,
	description VARCHAR(32)
);

CREATE VIEW iris.catalog AS
	SELECT name, seq_num, description
	FROM iris._catalog;

CREATE FUNCTION iris.catalog_insert() RETURNS TRIGGER AS
	$catalog_insert$
BEGIN
	INSERT INTO iris._cam_sequence (seq_num) VALUES (NEW.seq_num);
	INSERT INTO iris._catalog (name, seq_num, description)
	     VALUES (NEW.name,NEW.seq_num, NEW.catalog);
	RETURN NEW;
END;
$catalog_insert$ LANGUAGE plpgsql;

CREATE TRIGGER catalog_insert_trig
    INSTEAD OF INSERT ON iris.catalog
    FOR EACH ROW EXECUTE PROCEDURE iris.catalog_insert();

CREATE FUNCTION iris.catalog_update() RETURNS TRIGGER AS
	$catalog_update$
BEGIN
	IF NEW.seq_num != OLD.seq_num THEN
		INSERT INTO iris._cam_sequence (seq_num) VALUES (NEW.seq_num);
	END IF;
	UPDATE iris._catalog
	   SET seq_num = NEW.seq_num,
	       description = NEW.description
	 WHERE name = OLD.name;
	IF NEW.seq_num != OLD.seq_num THEN
		DELETE FROM iris._cam_sequence WHERE seq_num = OLD.seq_num;
	END IF;
	RETURN NEW;
END;
$catalog_update$ LANGUAGE plpgsql;

CREATE TRIGGER catalog_update_trig
    INSTEAD OF UPDATE ON iris.catalog
    FOR EACH ROW EXECUTE PROCEDURE iris.catalog_update();

CREATE FUNCTION iris.catalog_delete() RETURNS TRIGGER AS
	$catalog_delete$
BEGIN
	DELETE FROM iris._catalog WHERE name = OLD.name;
	IF FOUND THEN
		DELETE FROM iris._cam_sequence WHERE seq_num = OLD.seq_num;
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$catalog_delete$ LANGUAGE plpgsql;

CREATE TRIGGER catalog_delete_trig
    INSTEAD OF DELETE ON iris.catalog
    FOR EACH ROW EXECUTE PROCEDURE iris.catalog_delete();

CREATE TABLE iris.catalog_play_list (
	catalog VARCHAR(20) NOT NULL REFERENCES iris._catalog,
	ordinal INTEGER NOT NULL,
	play_list VARCHAR(20) NOT NULL REFERENCES iris._play_list
);
ALTER TABLE iris.catalog_play_list ADD PRIMARY KEY (catalog, ordinal);

CREATE TABLE event.camera_switch_event (
	event_id SERIAL PRIMARY KEY,
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	monitor_id VARCHAR(12),
	camera_id VARCHAR(20),
	source VARCHAR(20)
);

CREATE VIEW camera_switch_event_view AS
	SELECT event_id, event_date, event_description.description, monitor_id,
	       camera_id, source
	FROM event.camera_switch_event
	JOIN event.event_description
	ON camera_switch_event.event_desc_id = event_description.event_desc_id;
GRANT SELECT ON camera_switch_event_view TO PUBLIC;

CREATE TABLE iris.camera_preset (
	name VARCHAR(20) PRIMARY KEY,
	camera VARCHAR(20) NOT NULL REFERENCES iris._camera,
	preset_num INTEGER NOT NULL CHECK (preset_num > 0 AND preset_num <= 12),
	direction SMALLINT REFERENCES iris.direction(id),
	UNIQUE(camera, preset_num)
);

CREATE TABLE iris._device_preset (
	name VARCHAR(20) PRIMARY KEY,
	preset VARCHAR(20) UNIQUE REFERENCES iris.camera_preset(name)
);

CREATE VIEW camera_preset_view AS
	SELECT cp.name, camera, preset_num, direction, dp.name AS device
	FROM iris.camera_preset cp
	JOIN iris._device_preset dp ON cp.name = dp.preset;
GRANT SELECT ON camera_preset_view TO PUBLIC;

--
-- Alarms
--
CREATE TABLE iris._alarm (
	name VARCHAR(20) PRIMARY KEY,
	description VARCHAR(24) NOT NULL,
	state BOOLEAN NOT NULL,
	trigger_time TIMESTAMP WITH time zone
);

ALTER TABLE iris._alarm ADD CONSTRAINT _alarm_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.alarm AS
	SELECT a.name, description, controller, pin, state, trigger_time
	FROM iris._alarm a JOIN iris._device_io d ON a.name = d.name;

CREATE FUNCTION iris.alarm_insert() RETURNS TRIGGER AS
	$alarm_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._alarm (name, description, state, trigger_time)
	     VALUES (NEW.name, NEW.description, NEW.state, NEW.trigger_time);
	RETURN NEW;
END;
$alarm_insert$ LANGUAGE plpgsql;

CREATE TRIGGER alarm_insert_trig
    INSTEAD OF INSERT ON iris.alarm
    FOR EACH ROW EXECUTE PROCEDURE iris.alarm_insert();

CREATE FUNCTION iris.alarm_update() RETURNS TRIGGER AS
	$alarm_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._alarm
	   SET description = NEW.description,
	       state = NEW.state,
	       trigger_time = NEW.trigger_time
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$alarm_update$ LANGUAGE plpgsql;

CREATE TRIGGER alarm_update_trig
    INSTEAD OF UPDATE ON iris.alarm
    FOR EACH ROW EXECUTE PROCEDURE iris.alarm_update();

CREATE FUNCTION iris.alarm_delete() RETURNS TRIGGER AS
	$alarm_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$alarm_delete$ LANGUAGE plpgsql;

CREATE TRIGGER alarm_delete_trig
    INSTEAD OF DELETE ON iris.alarm
    FOR EACH ROW EXECUTE PROCEDURE iris.alarm_delete();

CREATE VIEW alarm_view AS
	SELECT a.name, a.description, a.state, a.trigger_time, a.controller,
	       a.pin, c.comm_link, c.drop_id
	FROM iris.alarm a
	LEFT JOIN iris.controller c ON a.controller = c.name;
GRANT SELECT ON alarm_view TO PUBLIC;

CREATE TABLE event.alarm_event (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	alarm VARCHAR(20) NOT NULL REFERENCES iris._alarm(name)
		ON DELETE CASCADE
);

CREATE VIEW alarm_event_view AS
	SELECT e.event_id, e.event_date, ed.description AS event_description,
		e.alarm, a.description
	FROM event.alarm_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id
	JOIN iris.alarm a ON e.alarm = a.name;
GRANT SELECT ON alarm_event_view TO PUBLIC;

--
-- Beacons
--
CREATE TABLE iris._beacon (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes text NOT NULL,
	message text NOT NULL,
	verify_pin INTEGER -- FIXME: make unique on _device_io_ctrl_pin
);

ALTER TABLE iris._beacon ADD CONSTRAINT _beacon_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.beacon AS
	SELECT b.name, geo_loc, controller, pin, notes, message, verify_pin,
	       preset
	FROM iris._beacon b
	JOIN iris._device_io d ON b.name = d.name
	JOIN iris._device_preset p ON b.name = p.name;

CREATE FUNCTION iris.beacon_insert() RETURNS TRIGGER AS
	$beacon_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	    VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._device_preset (name, preset)
	    VALUES (NEW.name, NEW.preset);
	INSERT INTO iris._beacon (name, geo_loc, notes, message, verify_pin)
	    VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.message,
	            NEW.verify_pin);
	RETURN NEW;
END;
$beacon_insert$ LANGUAGE plpgsql;

CREATE TRIGGER beacon_insert_trig
    INSTEAD OF INSERT ON iris.beacon
    FOR EACH ROW EXECUTE PROCEDURE iris.beacon_insert();

CREATE FUNCTION iris.beacon_update() RETURNS TRIGGER AS
	$beacon_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._device_preset
	   SET preset = NEW.preset
	 WHERE name = OLD.name;
	UPDATE iris._beacon
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       message = NEW.message,
	       verify_pin = NEW.verify_pin
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$beacon_update$ LANGUAGE plpgsql;

CREATE TRIGGER beacon_update_trig
    INSTEAD OF UPDATE ON iris.beacon
    FOR EACH ROW EXECUTE PROCEDURE iris.beacon_update();

CREATE FUNCTION iris.beacon_delete() RETURNS TRIGGER AS
	$beacon_delete$
BEGIN
	DELETE FROM iris._device_preset WHERE name = OLD.name;
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$beacon_delete$ LANGUAGE plpgsql;

CREATE TRIGGER beacon_delete_trig
    INSTEAD OF DELETE ON iris.beacon
    FOR EACH ROW EXECUTE PROCEDURE iris.beacon_delete();

CREATE VIEW beacon_view AS
	SELECT b.name, b.notes, b.message, p.camera, p.preset_num, b.geo_loc,
	       l.roadway, l.road_dir, l.cross_mod, l.cross_street, l.cross_dir,
	       l.lat, l.lon,
	       b.controller, b.pin, b.verify_pin, ctr.comm_link, ctr.drop_id,
	       ctr.condition
	FROM iris.beacon b
	LEFT JOIN iris.camera_preset p ON b.preset = p.name
	LEFT JOIN geo_loc_view l ON b.geo_loc = l.name
	LEFT JOIN controller_view ctr ON b.controller = ctr.name;
GRANT SELECT ON beacon_view TO PUBLIC;

CREATE TABLE iris.beacon_action (
	name VARCHAR(30) PRIMARY KEY,
	action_plan VARCHAR(16) NOT NULL REFERENCES iris.action_plan,
	beacon VARCHAR(20) NOT NULL REFERENCES iris._beacon,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase
);

CREATE TABLE event.beacon_event (
	event_id SERIAL PRIMARY KEY,
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	beacon VARCHAR(20) NOT NULL REFERENCES iris._beacon
		ON DELETE CASCADE
);

CREATE VIEW beacon_event_view AS
	SELECT event_id, event_date, event_description.description, beacon
	FROM event.beacon_event
	JOIN event.event_description
	ON beacon_event.event_desc_id = event_description.event_desc_id;
GRANT SELECT ON beacon_event_view TO PUBLIC;

--
-- Lane Types, Detectors
--
CREATE TABLE iris.lane_type (
	id SMALLINT PRIMARY KEY,
	description VARCHAR(12) NOT NULL,
	dcode VARCHAR(2) NOT NULL
);

COPY iris.lane_type (id, description, dcode) FROM stdin;
0		
1	Mainline	
2	Auxiliary	A
3	CD Lane	CD
4	Reversible	R
5	Merge	M
6	Queue	Q
7	Exit	X
8	Bypass	B
9	Passage	P
10	Velocity	V
11	Omnibus	O
12	Green	G
13	Wrong Way	Y
14	HOV	H
15	HOT	HT
16	Shoulder	D
17	Parking	PK
\.

CREATE VIEW lane_type_view AS
	SELECT id, description, dcode FROM iris.lane_type;
GRANT SELECT ON lane_type_view TO PUBLIC;

CREATE TABLE iris._detector (
	name VARCHAR(20) PRIMARY KEY,
	r_node VARCHAR(10) NOT NULL REFERENCES iris.r_node(name),
	lane_type SMALLINT NOT NULL REFERENCES iris.lane_type(id),
	lane_number SMALLINT NOT NULL,
	abandoned BOOLEAN NOT NULL,
	force_fail BOOLEAN NOT NULL,
	field_length REAL NOT NULL,
	fake VARCHAR(32),
	notes VARCHAR(32)
);

ALTER TABLE iris._detector ADD CONSTRAINT _detector_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.detector AS SELECT
	det.name, controller, pin, r_node, lane_type, lane_number, abandoned,
	force_fail, field_length, fake, notes
	FROM iris._detector det JOIN iris._device_io d ON det.name = d.name;

CREATE FUNCTION iris.detector_insert() RETURNS TRIGGER AS
	$detector_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._detector
	            (name, r_node, lane_type, lane_number, abandoned,
	             force_fail, field_length, fake, notes)
	     VALUES (NEW.name, NEW.r_node, NEW.lane_type, NEW.lane_number,
	             NEW.abandoned, NEW.force_fail, NEW.field_length, NEW.fake,
	             NEW.notes);
	RETURN NEW;
END;
$detector_insert$ LANGUAGE plpgsql;

CREATE TRIGGER detector_insert_trig
    INSTEAD OF INSERT ON iris.detector
    FOR EACH ROW EXECUTE PROCEDURE iris.detector_insert();

CREATE FUNCTION iris.detector_update() RETURNS TRIGGER AS
	$detector_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._detector
	   SET r_node = NEW.r_node,
	       lane_type = NEW.lane_type,
	       lane_number = NEW.lane_number,
	       abandoned = NEW.abandoned,
	       force_fail = NEW.force_fail,
	       field_length = NEW.field_length,
	       fake = NEW.fake,
	       notes = NEW.notes
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$detector_update$ LANGUAGE plpgsql;

CREATE TRIGGER detector_update_trig
    INSTEAD OF UPDATE ON iris.detector
    FOR EACH ROW EXECUTE PROCEDURE iris.detector_update();

CREATE FUNCTION iris.detector_delete() RETURNS TRIGGER AS
	$detector_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$detector_delete$ LANGUAGE plpgsql;

CREATE TRIGGER detector_delete_trig
    INSTEAD OF DELETE ON iris.detector
    FOR EACH ROW EXECUTE PROCEDURE iris.detector_delete();

CREATE FUNCTION iris.detector_label(VARCHAR(6), VARCHAR(4), VARCHAR(6),
	VARCHAR(4), VARCHAR(2), SMALLINT, SMALLINT, BOOLEAN)
	RETURNS TEXT AS $detector_label$
DECLARE
	rd ALIAS FOR $1;
	rdir ALIAS FOR $2;
	xst ALIAS FOR $3;
	xdir ALIAS FOR $4;
	xmod ALIAS FOR $5;
	l_type ALIAS FOR $6;
	lane_number ALIAS FOR $7;
	abandoned ALIAS FOR $8;
	xmd VARCHAR(2);
	ltyp VARCHAR(2);
	lnum VARCHAR(2);
	suffix VARCHAR(5);
BEGIN
	IF rd IS NULL OR xst IS NULL THEN
		RETURN 'FUTURE';
	END IF;
	SELECT dcode INTO ltyp FROM lane_type_view WHERE id = l_type;
	lnum = '';
	IF lane_number > 0 THEN
		lnum = TO_CHAR(lane_number, 'FM9');
	END IF;
	xmd = '';
	IF xmod != '@' THEN
		xmd = xmod;
	END IF;
	suffix = '';
	IF abandoned THEN
		suffix = '-ABND';
	END IF;
	RETURN rd || '/' || xdir || xmd || xst || rdir || ltyp || lnum ||
	       suffix;
END;
$detector_label$ LANGUAGE plpgsql;

CREATE VIEW detector_label_view AS
	SELECT d.name AS det_id,
	       iris.detector_label(l.rd, l.rdir, l.xst, l.cross_dir, l.xmod,
	                           d.lane_type, d.lane_number, d.abandoned)
	       AS label
	FROM iris.detector d
	LEFT JOIN iris.r_node rnd ON d.r_node = rnd.name
	LEFT JOIN geo_loc_view l ON rnd.geo_loc = l.name;
GRANT SELECT ON detector_label_view TO PUBLIC;

CREATE TABLE event.detector_event (
	event_id INTEGER DEFAULT nextval('event.event_id_seq') NOT NULL,
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	device_id VARCHAR(20) REFERENCES iris._detector(name) ON DELETE CASCADE
);

CREATE VIEW detector_fail_view AS
	SELECT DISTINCT ON (device_id) device_id, description AS fail_reason,
	                               event_date AS fail_date
	FROM event.detector_event de
	JOIN event.event_description ed ON de.event_desc_id = ed.event_desc_id
	ORDER BY device_id, event_id DESC;
GRANT SELECT ON detector_fail_view TO PUBLIC;

CREATE VIEW detector_view AS
	SELECT d.name, d.r_node, d.controller, c.comm_link, c.drop_id, d.pin,
	       iris.detector_label(l.rd, l.rdir, l.xst, l.cross_dir, l.xmod,
	       d.lane_type, d.lane_number, d.abandoned) AS label,
	       rnd.geo_loc, l.roadway, l.road_dir, l.cross_mod, l.cross_street,
	       l.cross_dir, d.lane_number, d.field_length,
	       ln.description AS lane_type, d.abandoned, d.force_fail,
	       df.fail_reason, df.fail_date, c.condition, d.fake, d.notes
	FROM (iris.detector d
	LEFT OUTER JOIN detector_fail_view df
		ON d.name = df.device_id AND force_fail = 't')
	LEFT JOIN iris.r_node rnd ON d.r_node = rnd.name
	LEFT JOIN geo_loc_view l ON rnd.geo_loc = l.name
	LEFT JOIN iris.lane_type ln ON d.lane_type = ln.id
	LEFT JOIN controller_view c ON d.controller = c.name;
GRANT SELECT ON detector_view TO PUBLIC;

CREATE VIEW detector_event_view AS
	SELECT e.event_id, e.event_date, ed.description, e.device_id, dl.label
	FROM event.detector_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id
	JOIN detector_label_view dl ON e.device_id = dl.det_id;
GRANT SELECT ON detector_event_view TO PUBLIC;

--
-- GPS
--
CREATE TABLE iris._gps (
	name VARCHAR(20) PRIMARY KEY,
	notes VARCHAR(32),
	latest_poll TIMESTAMP WITH time zone,
	latest_sample TIMESTAMP WITH time zone,
	lat double precision,
	lon double precision
);

ALTER TABLE iris._gps ADD CONSTRAINT _gps_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.gps AS
	SELECT g.name, d.controller, d.pin, g.notes, g.latest_poll,
               g.latest_sample, g.lat, g.lon
	FROM iris._gps g
	JOIN iris._device_io d ON g.name = d.name;

CREATE FUNCTION iris.gps_insert() RETURNS TRIGGER AS
	$gps_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._gps (name, notes, latest_poll, latest_sample, lat,lon)
	     VALUES (NEW.name, NEW.notes, NEW.latest_poll, NEW.latest_sample,
                     NEW.lat, NEW.lon);
	RETURN NEW;
END;
$gps_insert$ LANGUAGE plpgsql;

CREATE TRIGGER gps_insert_trig
	INSTEAD OF INSERT ON iris.gps
	FOR EACH ROW EXECUTE PROCEDURE iris.gps_insert();

CREATE FUNCTION iris.gps_update() RETURNS TRIGGER AS
	$gps_update$
BEGIN
        UPDATE iris._device_io
           SET controller = NEW.controller,
               pin = NEW.pin
         WHERE name = OLD.name;
	UPDATE iris._gps
	   SET notes = NEW.notes,
               latest_poll = NEW.latest_poll,
	       latest_sample = NEW.latest_sample,
	       lat = NEW.lat,
	       lon = NEW.lon
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$gps_update$ LANGUAGE plpgsql;

CREATE TRIGGER gps_update_trig
	INSTEAD OF UPDATE ON iris.gps
	FOR EACH ROW EXECUTE PROCEDURE iris.gps_update();

CREATE FUNCTION iris.gps_delete() RETURNS TRIGGER AS
	$gps_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$gps_delete$ LANGUAGE plpgsql;

CREATE TRIGGER gps_delete_trig
	INSTEAD OF DELETE ON iris.gps
	FOR EACH ROW EXECUTE PROCEDURE iris.gps_delete();

--
-- DMS, Graphic, Font, Sign Message, Quick Message, Word, Color Scheme
--
CREATE TABLE iris.font (
	name VARCHAR(16) PRIMARY KEY,
	f_number INTEGER UNIQUE NOT NULL,
	height INTEGER NOT NULL,
	width INTEGER NOT NULL,
	line_spacing INTEGER NOT NULL,
	char_spacing INTEGER NOT NULL,
	version_id INTEGER NOT NULL
);

ALTER TABLE iris.font
	ADD CONSTRAINT font_number_ck
	CHECK (f_number > 0 AND f_number <= 255);
ALTER TABLE iris.font
	ADD CONSTRAINT font_height_ck
	CHECK (height > 0 AND height <= 30);
ALTER TABLE iris.font
	ADD CONSTRAINT font_width_ck
	CHECK (width >= 0 AND width <= 12);
ALTER TABLE iris.font
	ADD CONSTRAINT font_line_sp_ck
	CHECK (line_spacing >= 0 AND line_spacing <= 9);
ALTER TABLE iris.font
	ADD CONSTRAINT font_char_sp_ck
	CHECK (char_spacing >= 0 AND char_spacing <= 6);

CREATE FUNCTION iris.font_ck() RETURNS TRIGGER AS
	$font_ck$
DECLARE
	g_width INTEGER;
BEGIN
	IF NEW.width > 0 THEN
		SELECT width INTO g_width FROM iris.glyph WHERE font = NEW.name;
		IF FOUND AND NEW.width != g_width THEN
			RAISE EXCEPTION 'width does not match glyph';
		END IF;
	END IF;
	RETURN NEW;
END;
$font_ck$ LANGUAGE plpgsql;

CREATE TRIGGER font_ck_trig
	BEFORE UPDATE ON iris.font
	FOR EACH ROW EXECUTE PROCEDURE iris.font_ck();

CREATE VIEW font_view AS
	SELECT name, f_number, height, width, line_spacing, char_spacing,
	       version_id
	FROM iris.font;
GRANT SELECT ON font_view TO PUBLIC;

CREATE TABLE iris.glyph (
	name VARCHAR(20) PRIMARY KEY,
	font VARCHAR(16) NOT NULL REFERENCES iris.font(name),
	code_point INTEGER NOT NULL,
	width INTEGER NOT NULL,
	pixels VARCHAR(128) NOT NULL
);

ALTER TABLE iris.glyph
	ADD CONSTRAINT glyph_code_point_ck
	CHECK (code_point > 0 AND code_point < 128);
ALTER TABLE iris.glyph
	ADD CONSTRAINT glyph_width_ck
	CHECK (width >= 0 AND width <= 24);

CREATE FUNCTION iris.glyph_ck() RETURNS TRIGGER AS
	$glyph_ck$
DECLARE
	f_width INTEGER;
BEGIN
	SELECT width INTO f_width FROM iris.font WHERE name = NEW.font;
	IF f_width > 0 AND f_width != NEW.width THEN
		RAISE EXCEPTION 'width does not match font';
	END IF;
	RETURN NEW;
END;
$glyph_ck$ LANGUAGE plpgsql;

CREATE TRIGGER glyph_ck_trig
	BEFORE INSERT OR UPDATE ON iris.glyph
	FOR EACH ROW EXECUTE PROCEDURE iris.glyph_ck();

CREATE VIEW glyph_view AS
	SELECT name, font, code_point, width, pixels
	FROM iris.glyph;
GRANT SELECT ON glyph_view TO PUBLIC;

CREATE TABLE iris.dms_type (
	id INTEGER PRIMARY KEY,
	description VARCHAR(32) NOT NULL
);

COPY iris.dms_type (id, description) FROM stdin;
0	Unknown
1	Other
2	BOS (blank-out sign)
3	CMS (changeable message sign)
4	VMS Character-matrix
5	VMS Line-matrix
6	VMS Full-matrix
\.

CREATE TABLE iris.color_scheme (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY iris.color_scheme (id, description) FROM stdin;
1	monochrome1Bit
2	monochrome8Bit
3	colorClassic
4	color24Bit
\.

CREATE TABLE iris.sign_config (
	name VARCHAR(12) PRIMARY KEY,
	dms_type INTEGER NOT NULL REFERENCES iris.dms_type,
	portable BOOLEAN NOT NULL,
	technology VARCHAR(12) NOT NULL,
	sign_access VARCHAR(12) NOT NULL,
	legend VARCHAR(12) NOT NULL,
	beacon_type VARCHAR(32) NOT NULL,
	face_width INTEGER NOT NULL,
	face_height INTEGER NOT NULL,
	border_horiz INTEGER NOT NULL,
	border_vert INTEGER NOT NULL,
	pitch_horiz INTEGER NOT NULL,
	pitch_vert INTEGER NOT NULL,
	pixel_width INTEGER NOT NULL,
	pixel_height INTEGER NOT NULL,
	char_width INTEGER NOT NULL,
	char_height INTEGER NOT NULL,
	color_scheme INTEGER NOT NULL REFERENCES iris.color_scheme,
	monochrome_foreground INTEGER NOT NULL,
	monochrome_background INTEGER NOT NULL,
	default_font VARCHAR(16) REFERENCES iris.font
);

CREATE VIEW sign_config_view AS
	SELECT name, dt.description AS dms_type, portable, technology,
	       sign_access, legend, beacon_type, face_width, face_height,
	       border_horiz, border_vert, pitch_horiz, pitch_vert,
	       pixel_width, pixel_height, char_width, char_height,
	       cs.description AS color_scheme,
	       monochrome_foreground, monochrome_background, default_font
	FROM iris.sign_config
	JOIN iris.dms_type dt ON sign_config.dms_type = dt.id
	JOIN iris.color_scheme cs ON sign_config.color_scheme = cs.id;
GRANT SELECT ON sign_config_view TO PUBLIC;

CREATE TABLE iris.sign_msg_source (
	bit INTEGER PRIMARY KEY,
	source VARCHAR(16) NOT NULL
);
ALTER TABLE iris.sign_msg_source ADD CONSTRAINT msg_source_bit_ck
	CHECK (bit >= 0 AND bit < 32);

COPY iris.sign_msg_source (bit, source) FROM stdin;
0	blank
1	operator
2	schedule
3	tolling
4	gate arm
5	lcs
6	aws
7	external
8	travel time
9	incident
10	slow warning
11	speed advisory
12	parking
\.

CREATE FUNCTION iris.sign_msg_sources(INTEGER) RETURNS TEXT
	AS $sign_msg_sources$
DECLARE
	src ALIAS FOR $1;
	res TEXT;
	ms RECORD;
	b INTEGER;
BEGIN
	res = '';
	FOR ms IN SELECT bit, source FROM iris.sign_msg_source ORDER BY bit LOOP
		b = 1 << ms.bit;
		IF (src & b) = b THEN
			IF char_length(res) > 0 THEN
				res = res || ', ' || ms.source;
			ELSE
				res = ms.source;
			END IF;
		END IF;
	END LOOP;
	RETURN res;
END;
$sign_msg_sources$ LANGUAGE plpgsql;

CREATE TABLE iris.sign_message (
	name VARCHAR(20) PRIMARY KEY,
	sign_config VARCHAR(12) NOT NULL REFERENCES iris.sign_config,
	incident VARCHAR(16),
	multi VARCHAR(1024) NOT NULL,
	beacon_enabled BOOLEAN NOT NULL,
	prefix_page BOOLEAN NOT NULL,
	msg_priority INTEGER NOT NULL,
	source INTEGER NOT NULL,
	owner VARCHAR(15),
	duration INTEGER
);

CREATE VIEW sign_message_view AS
	SELECT name, sign_config, incident, multi, beacon_enabled, prefix_page,
	       msg_priority, iris.sign_msg_sources(source) AS sources, owner,
	       duration
	FROM iris.sign_message;
GRANT SELECT ON sign_message_view TO PUBLIC;

CREATE TABLE iris.word (
	name VARCHAR(24) PRIMARY KEY,
	abbr VARCHAR(12),
	allowed BOOLEAN DEFAULT false NOT NULL
);

CREATE TABLE iris.graphic (
	name VARCHAR(20) PRIMARY KEY,
	g_number INTEGER NOT NULL UNIQUE,
	color_scheme INTEGER NOT NULL REFERENCES iris.color_scheme,
	height INTEGER NOT NULL,
	width INTEGER NOT NULL,
	transparent_color INTEGER,
	pixels TEXT NOT NULL
);

ALTER TABLE iris.graphic
	ADD CONSTRAINT graphic_number_ck
	CHECK (g_number > 0 AND g_number <= 999);
ALTER TABLE iris.graphic
	ADD CONSTRAINT graphic_height_ck
	CHECK (height > 0);
ALTER TABLE iris.graphic
	ADD CONSTRAINT graphic_width_ck
	CHECK (width > 0);

CREATE VIEW graphic_view AS
	SELECT name, g_number, cs.description AS color_scheme, height, width,
	       transparent_color, pixels
	FROM iris.graphic
	JOIN iris.color_scheme cs ON graphic.color_scheme = cs.id;
GRANT SELECT ON graphic_view TO PUBLIC;

CREATE TABLE iris._dms (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc,
	notes text NOT NULL,
	gps VARCHAR(20) REFERENCES iris._gps,
	static_graphic VARCHAR(20) REFERENCES iris.graphic,
	beacon VARCHAR(20) REFERENCES iris._beacon,
	sign_config VARCHAR(12) REFERENCES iris.sign_config,
	override_font VARCHAR(16) REFERENCES iris.font,
	msg_sched VARCHAR(20) REFERENCES iris.sign_message,
	msg_current VARCHAR(20) REFERENCES iris.sign_message,
	expire_time TIMESTAMP WITH time zone
);

ALTER TABLE iris._dms ADD CONSTRAINT _dms_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.dms AS
	SELECT d.name, geo_loc, controller, pin, notes, gps, static_graphic,
	       beacon, preset, sign_config, override_font, msg_sched,
	       msg_current, expire_time
	FROM iris._dms dms
	JOIN iris._device_io d ON dms.name = d.name
	JOIN iris._device_preset p ON dms.name = p.name;

CREATE FUNCTION iris.dms_insert() RETURNS TRIGGER AS
	$dms_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._device_preset (name, preset)
	     VALUES (NEW.name, NEW.preset);
	INSERT INTO iris._dms (name, geo_loc, notes, gps, static_graphic,
	                       beacon, sign_config, override_font, msg_sched,
	                       msg_current, expire_time)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.gps,
	             NEW.static_graphic, NEW.beacon, NEW.sign_config,
	             NEW.override_font, NEW.msg_sched, NEW.msg_current,
	             NEW.expire_time);
	RETURN NEW;
END;
$dms_insert$ LANGUAGE plpgsql;

CREATE TRIGGER dms_insert_trig
    INSTEAD OF INSERT ON iris.dms
    FOR EACH ROW EXECUTE PROCEDURE iris.dms_insert();

CREATE FUNCTION iris.dms_update() RETURNS TRIGGER AS
	$dms_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._device_preset
	   SET preset = NEW.preset
	 WHERE name = OLD.name;
	UPDATE iris._dms
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       gps = NEW.gps,
	       static_graphic = NEW.static_graphic,
	       beacon = NEW.beacon,
	       sign_config = NEW.sign_config,
	       override_font = NEW.override_font,
	       msg_sched = NEW.msg_sched,
	       msg_current = NEW.msg_current,
	       expire_time = NEW.expire_time
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$dms_update$ LANGUAGE plpgsql;

CREATE TRIGGER dms_update_trig
    INSTEAD OF UPDATE ON iris.dms
    FOR EACH ROW EXECUTE PROCEDURE iris.dms_update();

CREATE FUNCTION iris.dms_delete() RETURNS TRIGGER AS
	$dms_delete$
BEGIN
	DELETE FROM iris._device_preset WHERE name = OLD.name;
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$dms_delete$ LANGUAGE plpgsql;

CREATE TRIGGER dms_delete_trig
    INSTEAD OF DELETE ON iris.dms
    FOR EACH ROW EXECUTE PROCEDURE iris.dms_delete();

CREATE VIEW dms_view AS
	SELECT d.name, d.geo_loc, d.controller, d.pin, d.notes, d.gps,
	       d.static_graphic, d.beacon, p.camera, p.preset_num, d.sign_config,
	       default_font, override_font, msg_sched, msg_current, expire_time,
	       l.roadway, l.road_dir, l.cross_mod, l.cross_street, l.cross_dir,
	       l.location, l.lat, l.lon
	FROM iris.dms d
	LEFT JOIN iris.camera_preset p ON d.preset = p.name
	LEFT JOIN geo_loc_view l ON d.geo_loc = l.name
	LEFT JOIN sign_config_view sc ON d.sign_config = sc.name;
GRANT SELECT ON dms_view TO PUBLIC;

CREATE VIEW dms_message_view AS
	SELECT d.name, msg_current, cc.description AS condition, multi,
	       beacon_enabled, prefix_page, msg_priority,
	       iris.sign_msg_sources(source) AS sources, duration, expire_time
	FROM iris.dms d
	LEFT JOIN iris.controller c ON d.controller = c.name
	LEFT JOIN iris.condition cc ON c.condition = cc.id
	LEFT JOIN iris.sign_message s ON d.msg_current = s.name;
GRANT SELECT ON dms_message_view TO PUBLIC;

CREATE TABLE iris.sign_group (
	name VARCHAR(20) PRIMARY KEY,
	local BOOLEAN NOT NULL,
	hidden BOOLEAN NOT NULL
);

CREATE TABLE iris.dms_sign_group (
	name VARCHAR(42) PRIMARY KEY,
	dms VARCHAR(20) NOT NULL REFERENCES iris._dms,
	sign_group VARCHAR(20) NOT NULL REFERENCES iris.sign_group
);

CREATE TABLE iris.quick_message (
	name VARCHAR(20) PRIMARY KEY,
	sign_group VARCHAR(20) REFERENCES iris.sign_group,
	sign_config VARCHAR(12) REFERENCES iris.sign_config,
	prefix_page BOOLEAN NOT NULL,
	multi VARCHAR(1024) NOT NULL
);

CREATE VIEW quick_message_view AS
	SELECT name, sign_group, sign_config, prefix_page, multi
	FROM iris.quick_message;
GRANT SELECT ON quick_message_view TO PUBLIC;

CREATE TABLE iris.sign_text (
	name VARCHAR(20) PRIMARY KEY,
	sign_group VARCHAR(20) NOT NULL REFERENCES iris.sign_group,
	line SMALLINT NOT NULL,
	multi VARCHAR(64) NOT NULL,
	rank SMALLINT NOT NULL,
	CONSTRAINT sign_text_line CHECK ((line >= 1) AND (line <= 12)),
	CONSTRAINT sign_text_rank CHECK ((rank >= 1) AND (rank <= 99))
);

CREATE VIEW sign_text_view AS
	SELECT dms, local, line, multi, rank
	FROM iris.dms_sign_group dsg
	JOIN iris.sign_group sg ON dsg.sign_group = sg.name
	JOIN iris.sign_text st ON sg.name = st.sign_group;
GRANT SELECT ON sign_text_view TO PUBLIC;

CREATE TABLE iris.dms_action (
	name VARCHAR(30) PRIMARY KEY,
	action_plan VARCHAR(16) NOT NULL REFERENCES iris.action_plan,
	sign_group VARCHAR(20) NOT NULL REFERENCES iris.sign_group,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase,
	quick_message VARCHAR(20) REFERENCES iris.quick_message,
	beacon_enabled BOOLEAN NOT NULL,
	msg_priority INTEGER NOT NULL
);

CREATE VIEW dms_action_view AS
	SELECT name, action_plan, sign_group, phase, quick_message,
	       beacon_enabled, msg_priority
	FROM iris.dms_action;
GRANT SELECT ON dms_action_view TO PUBLIC;

CREATE TABLE event.sign_event (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	device_id VARCHAR(20),
	message text,
	iris_user VARCHAR(15)
);
CREATE INDEX ON event.sign_event(event_date);

CREATE VIEW sign_event_view AS
	SELECT event_id, event_date, description, device_id,
	       regexp_replace(replace(replace(message, '[nl]', E'\n'), '[np]',
	                      E'\n'), '\[.+?\]', ' ', 'g') AS message,
	       message AS multi, iris_user
	FROM event.sign_event JOIN event.event_description
	ON sign_event.event_desc_id = event_description.event_desc_id;
GRANT SELECT ON sign_event_view TO PUBLIC;

CREATE VIEW recent_sign_event_view AS
	SELECT event_id, event_date, description, device_id, message, multi,
	       iris_user
	FROM sign_event_view
	WHERE event_date > (CURRENT_TIMESTAMP - interval '90 days');
GRANT SELECT ON recent_sign_event_view TO PUBLIC;

CREATE TABLE event.travel_time_event (
	event_id SERIAL PRIMARY KEY,
	event_date timestamp WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	device_id VARCHAR(20)
);

CREATE VIEW travel_time_event_view AS
	SELECT event_id, event_date, event_description.description, device_id
	FROM event.travel_time_event
	JOIN event.event_description
	ON travel_time_event.event_desc_id = event_description.event_desc_id;
GRANT SELECT ON travel_time_event_view TO PUBLIC;

CREATE TABLE event.brightness_sample (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	dms VARCHAR(20) NOT NULL REFERENCES iris._dms(name)
		ON DELETE CASCADE,
	photocell INTEGER NOT NULL,
	output INTEGER NOT NULL
);

--
-- Gate Arms
--
CREATE TABLE iris._gate_arm_array (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc,
	notes VARCHAR(64) NOT NULL,
	prereq VARCHAR(20) REFERENCES iris._gate_arm_array,
	camera VARCHAR(20) REFERENCES iris._camera,
	approach VARCHAR(20) REFERENCES iris._camera,
	action_plan VARCHAR(16) REFERENCES iris.action_plan,
	open_phase VARCHAR(12) REFERENCES iris.plan_phase,
	closed_phase VARCHAR(12) REFERENCES iris.plan_phase
);

ALTER TABLE iris._gate_arm_array ADD CONSTRAINT _gate_arm_array_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.gate_arm_array AS
	SELECT _gate_arm_array.name, geo_loc, controller, pin, notes, prereq,
	       camera, approach, action_plan, open_phase, closed_phase
	FROM iris._gate_arm_array JOIN iris._device_io
	ON _gate_arm_array.name = _device_io.name;

CREATE FUNCTION iris.gate_arm_array_insert() RETURNS TRIGGER AS
	$gate_arm_array_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._gate_arm_array (name, geo_loc, notes, prereq, camera,
	                                  approach, action_plan, open_phase,
	                                  closed_phase)
	    VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.prereq, NEW.camera,
	            NEW.approach, NEW.action_plan, NEW.open_phase,
	            NEW.closed_phase);
	RETURN NEW;
END;
$gate_arm_array_insert$ LANGUAGE plpgsql;

CREATE TRIGGER gate_arm_array_insert_trig
    INSTEAD OF INSERT ON iris.gate_arm_array
    FOR EACH ROW EXECUTE PROCEDURE iris.gate_arm_array_insert();

CREATE FUNCTION iris.gate_arm_array_update() RETURNS TRIGGER AS
	$gate_arm_array_update$
BEGIN
	UPDATE iris._device_io SET controller = NEW.controller, pin = NEW.pin
	WHERE name = OLD.name;
	UPDATE iris._gate_arm_array
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       prereq = NEW.prereq,
	       camera = NEW.camera,
	       approach = NEW.approach,
	       action_plan = NEW.action_plan,
	       open_phase = NEW.open_phase,
	       closed_phase = NEW.closed_phase
	WHERE name = OLD.name;
	RETURN NEW;
END;
$gate_arm_array_update$ LANGUAGE plpgsql;

CREATE TRIGGER gate_arm_array_update_trig
    INSTEAD OF UPDATE ON iris.gate_arm_array
    FOR EACH ROW EXECUTE PROCEDURE iris.gate_arm_array_update();

CREATE FUNCTION iris.gate_arm_array_delete() RETURNS TRIGGER AS
	$gate_arm_array_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$gate_arm_array_delete$ LANGUAGE plpgsql;

CREATE TRIGGER gate_arm_array_delete_trig
    INSTEAD OF DELETE ON iris.gate_arm_array
    FOR EACH ROW EXECUTE PROCEDURE iris.gate_arm_array_delete();

CREATE VIEW gate_arm_array_view AS
	SELECT ga.name, ga.notes, ga.geo_loc, l.roadway, l.road_dir,
	       l.cross_mod, l.cross_street, l.cross_dir, l.lat, l.lon,
	       ga.controller, ga.pin, ctr.comm_link, ctr.drop_id, ctr.condition,
	       ga.prereq, ga.camera, ga.approach, ga.action_plan, ga.open_phase,
	       ga.closed_phase
	FROM iris.gate_arm_array ga
	LEFT JOIN geo_loc_view l ON ga.geo_loc = l.name
	LEFT JOIN controller_view ctr ON ga.controller = ctr.name;
GRANT SELECT ON gate_arm_array_view TO PUBLIC;

CREATE TABLE iris._gate_arm (
	name VARCHAR(20) PRIMARY KEY,
	ga_array VARCHAR(20) NOT NULL REFERENCES iris._gate_arm_array,
	idx INTEGER NOT NULL,
	notes VARCHAR(32) NOT NULL
);

ALTER TABLE iris._gate_arm ADD CONSTRAINT _gate_arm_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE UNIQUE INDEX gate_arm_array_idx ON iris._gate_arm
	USING btree (ga_array, idx);

CREATE VIEW iris.gate_arm AS
	SELECT _gate_arm.name, ga_array, idx, controller, pin, notes
	FROM iris._gate_arm JOIN iris._device_io
	ON _gate_arm.name = _device_io.name;

CREATE FUNCTION iris.gate_arm_update() RETURNS TRIGGER AS $gate_arm_update$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO iris._device_io (name, controller, pin)
            VALUES (NEW.name, NEW.controller, NEW.pin);
        INSERT INTO iris._gate_arm (name, ga_array, idx, notes)
            VALUES (NEW.name, NEW.ga_array, NEW.idx, NEW.notes);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
	UPDATE iris._device_io SET controller = NEW.controller, pin = NEW.pin
	WHERE name = OLD.name;
        UPDATE iris._gate_arm SET ga_array = NEW.ga_array, idx = NEW.idx,
            notes = NEW.notes
	WHERE name = OLD.name;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM iris._device_io WHERE name = OLD.name;
        IF FOUND THEN
            RETURN OLD;
        ELSE
            RETURN NULL;
	END IF;
    END IF;
    RETURN NEW;
END;
$gate_arm_update$ LANGUAGE plpgsql;

CREATE TRIGGER gate_arm_update_trig
    INSTEAD OF INSERT OR UPDATE OR DELETE ON iris.gate_arm
    FOR EACH ROW EXECUTE PROCEDURE iris.gate_arm_update();

CREATE VIEW gate_arm_view AS
	SELECT g.name, g.ga_array, g.notes, ga.geo_loc, l.roadway, l.road_dir,
	       l.cross_mod, l.cross_street, l.cross_dir, l.lat, l.lon,
	       g.controller, g.pin, ctr.comm_link, ctr.drop_id, ctr.condition,
	       ga.prereq, ga.camera, ga.approach
	FROM iris.gate_arm g
	JOIN iris.gate_arm_array ga ON g.ga_array = ga.name
	LEFT JOIN geo_loc_view l ON ga.geo_loc = l.name
	LEFT JOIN controller_view ctr ON g.controller = ctr.name;
GRANT SELECT ON gate_arm_view TO PUBLIC;

CREATE TABLE event.gate_arm_event (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	device_id VARCHAR(20),
	iris_user VARCHAR(15)
);

CREATE VIEW gate_arm_event_view AS
	SELECT e.event_id, e.event_date, ed.description, device_id, e.iris_user
	FROM event.gate_arm_event e
	JOIN event.event_description ed ON e.event_desc_id = ed.event_desc_id;
GRANT SELECT ON gate_arm_event_view TO PUBLIC;

--
-- Incidents
--
CREATE TABLE event.incident_detail (
	name VARCHAR(8) PRIMARY KEY,
	description VARCHAR(32) NOT NULL
);

COPY event.incident_detail (name, description) FROM stdin;
animal	Animal on Road
debris	Debris
detour	Detour
emrg_veh	Emergency Vehicles
event	Event Congestion
flooding	Flash Flooding
gr_fire	Grass Fire
ice	Ice
jacknife	Jacknifed Trailer
pavement	Pavement Failure
ped	Pedestrian
rollover	Rollover
sgnl_out	Traffic Lights Out
snow_rmv	Snow Removal
spill	Spilled Load
test	Test Incident
veh_fire	Vehicle Fire
\.

CREATE TABLE event.incident (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	name VARCHAR(16) NOT NULL UNIQUE,
	replaces VARCHAR(16) REFERENCES event.incident(name),
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	detail VARCHAR(8) REFERENCES event.incident_detail(name),
	lane_type SMALLINT NOT NULL REFERENCES iris.lane_type(id),
	road VARCHAR(20) NOT NULL,
	dir SMALLINT NOT NULL REFERENCES iris.direction(id),
	lat double precision NOT NULL,
	lon double precision NOT NULL,
	camera VARCHAR(20),
	impact VARCHAR(20) NOT NULL,
	cleared BOOLEAN NOT NULL,
	confirmed BOOLEAN NOT NULL
);

CREATE VIEW incident_view AS
    SELECT event_id, name, event_date, ed.description, road, d.direction,
           impact, cleared, confirmed, camera, ln.description AS lane_type,
           detail, replaces, lat, lon
    FROM event.incident i
    LEFT JOIN event.event_description ed ON i.event_desc_id = ed.event_desc_id
    LEFT JOIN iris.direction d ON i.dir = d.id
    LEFT JOIN iris.lane_type ln ON i.lane_type = ln.id;
GRANT SELECT ON incident_view TO PUBLIC;

CREATE TABLE event.incident_update (
	event_id INTEGER PRIMARY KEY DEFAULT nextval('event.event_id_seq'),
	incident VARCHAR(16) NOT NULL REFERENCES event.incident(name),
	event_date TIMESTAMP WITH time zone NOT NULL,
	impact VARCHAR(20) NOT NULL,
	cleared BOOLEAN NOT NULL,
	confirmed BOOLEAN NOT NULL
);

CREATE FUNCTION event.incident_update_trig() RETURNS TRIGGER AS
$incident_update_trig$
BEGIN
    INSERT INTO event.incident_update
               (incident, event_date, impact, cleared, confirmed)
        VALUES (NEW.name, now(), NEW.impact, NEW.cleared, NEW.confirmed);
    RETURN NEW;
END;
$incident_update_trig$ LANGUAGE plpgsql;

CREATE TRIGGER incident_update_trigger
	AFTER INSERT OR UPDATE ON event.incident
	FOR EACH ROW EXECUTE PROCEDURE event.incident_update_trig();

CREATE VIEW incident_update_view AS
    SELECT iu.event_id, name, iu.event_date, ed.description, road,
           d.direction, iu.impact, iu.cleared, iu.confirmed, camera,
           ln.description AS lane_type, detail, replaces, lat, lon
    FROM event.incident i
    JOIN event.incident_update iu ON i.name = iu.incident
    LEFT JOIN event.event_description ed ON i.event_desc_id = ed.event_desc_id
    LEFT JOIN iris.direction d ON i.dir = d.id
    LEFT JOIN iris.lane_type ln ON i.lane_type = ln.id;
GRANT SELECT ON incident_update_view TO PUBLIC;

CREATE TABLE iris.inc_descriptor (
	name VARCHAR(10) PRIMARY KEY,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	lane_type SMALLINT NOT NULL REFERENCES iris.lane_type(id),
	detail VARCHAR(8) REFERENCES event.incident_detail(name),
	cleared BOOLEAN NOT NULL,
	multi VARCHAR(64) NOT NULL,
	abbrev VARCHAR(32)
);

CREATE FUNCTION iris.inc_descriptor_ck() RETURNS TRIGGER AS
	$inc_descriptor_ck$
BEGIN
	-- Only incident event IDs are allowed
	IF NEW.event_desc_id < 21 OR NEW.event_desc_id > 24 THEN
		RAISE EXCEPTION 'invalid incident event_desc_id';
	END IF;
	-- Only mainline, cd road, merge and exit lane types are allowed
	IF NEW.lane_type != 1 AND NEW.lane_type != 3 AND
	   NEW.lane_type != 5 AND NEW.lane_type != 7 THEN
		RAISE EXCEPTION 'invalid incident lane_type';
	END IF;
	RETURN NEW;
END;
$inc_descriptor_ck$ LANGUAGE plpgsql;

CREATE TRIGGER inc_descriptor_ck_trig
	BEFORE INSERT OR UPDATE ON iris.inc_descriptor
	FOR EACH ROW EXECUTE PROCEDURE iris.inc_descriptor_ck();

CREATE TABLE iris.inc_range (
	id INTEGER PRIMARY KEY,
	description VARCHAR(10) NOT NULL
);

COPY iris.inc_range (id, description) FROM stdin;
0	near
1	middle
2	far
\.

CREATE TABLE iris.inc_locator (
	name VARCHAR(10) PRIMARY KEY,
	range INTEGER NOT NULL REFERENCES iris.inc_range(id),
	branched BOOLEAN NOT NULL,
	pickable BOOLEAN NOT NULL,
	multi VARCHAR(64) NOT NULL,
	abbrev VARCHAR(32)
);

CREATE TABLE iris.inc_advice (
	name VARCHAR(10) PRIMARY KEY,
	range INTEGER NOT NULL REFERENCES iris.inc_range(id),
	lane_type SMALLINT NOT NULL REFERENCES iris.lane_type(id),
	impact VARCHAR(20) NOT NULL,
	cleared BOOLEAN NOT NULL,
	multi VARCHAR(64) NOT NULL,
	abbrev VARCHAR(32)
);

CREATE FUNCTION iris.inc_advice_ck() RETURNS TRIGGER AS
	$inc_advice_ck$
BEGIN
	-- Only mainline, cd road, merge and exit lane types are allowed
	IF NEW.lane_type != 1 AND NEW.lane_type != 3 AND
	   NEW.lane_type != 5 AND NEW.lane_type != 7 THEN
		RAISE EXCEPTION 'invalid incident lane_type';
	END IF;
	RETURN NEW;
END;
$inc_advice_ck$ LANGUAGE plpgsql;

CREATE TRIGGER inc_advice_ck_trig
	BEFORE INSERT OR UPDATE ON iris.inc_advice
	FOR EACH ROW EXECUTE PROCEDURE iris.inc_advice_ck();

--
-- Lane Markings
--
CREATE TABLE iris._lane_marking (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes VARCHAR(64) NOT NULL
);

ALTER TABLE iris._lane_marking ADD CONSTRAINT _lane_marking_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.lane_marking AS
	SELECT m.name, geo_loc, controller, pin, notes
	FROM iris._lane_marking m
	JOIN iris._device_io d ON m.name = d.name;

CREATE FUNCTION iris.lane_marking_insert() RETURNS TRIGGER AS
	$lane_marking_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._lane_marking (name, geo_loc, notes)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes);
	RETURN NEW;
END;
$lane_marking_insert$ LANGUAGE plpgsql;

CREATE TRIGGER lane_marking_insert_trig
    INSTEAD OF INSERT ON iris.lane_marking
    FOR EACH ROW EXECUTE PROCEDURE iris.lane_marking_insert();

CREATE FUNCTION iris.lane_marking_update() RETURNS TRIGGER AS
	$lane_marking_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._lane_marking
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$lane_marking_update$ LANGUAGE plpgsql;

CREATE TRIGGER lane_marking_update_trig
    INSTEAD OF UPDATE ON iris.lane_marking
    FOR EACH ROW EXECUTE PROCEDURE iris.lane_marking_update();

CREATE FUNCTION iris.lane_marking_delete() RETURNS TRIGGER AS
	$lane_marking_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$lane_marking_delete$ LANGUAGE plpgsql;

CREATE TRIGGER lane_marking_delete_trig
    INSTEAD OF DELETE ON iris.lane_marking
    FOR EACH ROW EXECUTE PROCEDURE iris.lane_marking_delete();

CREATE VIEW lane_marking_view AS
	SELECT m.name, m.notes, m.geo_loc, l.roadway, l.road_dir, l.cross_mod,
	       l.cross_street, l.cross_dir, l.lat, l.lon,
	       m.controller, m.pin, ctr.comm_link, ctr.drop_id, ctr.condition
	FROM iris.lane_marking m
	LEFT JOIN geo_loc_view l ON m.geo_loc = l.name
	LEFT JOIN controller_view ctr ON m.controller = ctr.name;
GRANT SELECT ON lane_marking_view TO PUBLIC;

CREATE TABLE iris.lane_action (
	name VARCHAR(30) PRIMARY KEY,
	action_plan VARCHAR(16) NOT NULL REFERENCES iris.action_plan,
	lane_marking VARCHAR(20) NOT NULL REFERENCES iris._lane_marking,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase
);

--
-- Lane-Use Control Signals
--
CREATE TABLE iris.lcs_lock (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY iris.lcs_lock (id, description) FROM stdin;
1	Incident
2	Maintenance
3	Testing
4	Other reason
\.

CREATE TABLE iris._lcs_array (
	name VARCHAR(20) PRIMARY KEY,
	notes text NOT NULL,
	shift INTEGER NOT NULL,
	lcs_lock INTEGER REFERENCES iris.lcs_lock(id)
);

ALTER TABLE iris._lcs_array ADD CONSTRAINT _lcs_array_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.lcs_array AS SELECT
	d.name, controller, pin, notes, shift, lcs_lock
	FROM iris._lcs_array la JOIN iris._device_io d ON la.name = d.name;

CREATE FUNCTION iris.lcs_array_insert() RETURNS TRIGGER AS
	$lcs_array_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._lcs_array(name, notes, shift, lcs_lock)
	     VALUES (NEW.name, NEW.notes, NEW.shift, NEW.lcs_lock);
	RETURN NEW;
END;
$lcs_array_insert$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_array_insert_trig
    INSTEAD OF INSERT ON iris.lcs_array
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_array_insert();

CREATE FUNCTION iris.lcs_array_update() RETURNS TRIGGER AS
	$lcs_array_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._lcs_array
	   SET notes = NEW.notes,
	       shift = NEW.shift,
	       lcs_lock = NEW.lcs_lock
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$lcs_array_update$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_array_update_trig
    INSTEAD OF UPDATE ON iris.lcs_array
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_array_update();

CREATE FUNCTION iris.lcs_array_delete() RETURNS TRIGGER AS
	$lcs_array_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$lcs_array_delete$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_array_delete_trig
    INSTEAD OF DELETE ON iris.lcs_array
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_array_delete();

CREATE VIEW lcs_array_view AS
	SELECT name, shift, notes, lcs_lock
	FROM iris.lcs_array;
GRANT SELECT ON lcs_array_view TO PUBLIC;

CREATE TABLE iris.lcs (
	name VARCHAR(20) PRIMARY KEY REFERENCES iris._dms,
	lcs_array VARCHAR(20) NOT NULL REFERENCES iris._lcs_array,
	lane INTEGER NOT NULL
);
CREATE UNIQUE INDEX lcs_array_lane ON iris.lcs USING btree (lcs_array, lane);

CREATE VIEW lcs_view AS
	SELECT name, lcs_array, lane
	FROM iris.lcs;
GRANT SELECT ON lcs_view TO PUBLIC;

CREATE TABLE iris.lane_use_indication (
	id INTEGER PRIMARY KEY,
	description VARCHAR(32) NOT NULL
);

COPY iris.lane_use_indication (id, description) FROM stdin;
0	Dark
1	Lane open
2	Use caution
3	Lane closed ahead
4	Lane closed
5	HOV / HOT
6	Merge right
7	Merge left
8	Merge left or right
9	Must exit right
10	Must exit left
11	Advisory variable speed limit
12	Variable speed limit
13	Low visibility
14	HOV / HOT begins
\.

CREATE TABLE iris._lcs_indication (
	name VARCHAR(20) PRIMARY KEY,
	lcs VARCHAR(20) NOT NULL REFERENCES iris.lcs,
	indication INTEGER NOT NULL REFERENCES iris.lane_use_indication
);

ALTER TABLE iris._lcs_indication ADD CONSTRAINT _lcs_indication_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.lcs_indication AS
	SELECT d.name, controller, pin, lcs, indication
	FROM iris._lcs_indication li
	JOIN iris._device_io d ON li.name = d.name;

CREATE FUNCTION iris.lcs_indication_insert() RETURNS TRIGGER AS
	$lcs_indication_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._lcs_indication(name, lcs, indication)
	     VALUES (NEW.name, NEW.lcs, NEW.indication);
	RETURN NEW;
END;
$lcs_indication_insert$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_indication_insert_trig
    INSTEAD OF INSERT ON iris.lcs_indication
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_indication_insert();

CREATE FUNCTION iris.lcs_indication_update() RETURNS TRIGGER AS
	$lcs_indication_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._lcs_indication
	   SET lcs = NEW.lcs,
	       indication = NEW.indication
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$lcs_indication_update$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_indication_update_trig
    INSTEAD OF UPDATE ON iris.lcs_indication
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_indication_update();

CREATE FUNCTION iris.lcs_indication_delete() RETURNS TRIGGER AS
	$lcs_indication_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$lcs_indication_delete$ LANGUAGE plpgsql;

CREATE TRIGGER lcs_indication_delete_trig
    INSTEAD OF DELETE ON iris.lcs_indication
    FOR EACH ROW EXECUTE PROCEDURE iris.lcs_indication_delete();

CREATE VIEW lcs_indication_view AS
	SELECT name, controller, pin, lcs, description AS indication
	FROM iris.lcs_indication
	JOIN iris.lane_use_indication ON indication = id;
GRANT SELECT ON lcs_indication_view TO PUBLIC;

CREATE TABLE iris.lane_use_multi (
	name VARCHAR(10) PRIMARY KEY,
	indication INTEGER NOT NULL REFERENCES iris.lane_use_indication,
	msg_num INTEGER,
	width INTEGER NOT NULL,
	height INTEGER NOT NULL,
	quick_message VARCHAR(20) REFERENCES iris.quick_message
);

CREATE UNIQUE INDEX lane_use_multi_indication_idx ON iris.lane_use_multi
	USING btree (indication, width, height);

CREATE UNIQUE INDEX lane_use_multi_msg_num_idx ON iris.lane_use_multi
	USING btree (msg_num, width, height);

--
-- Parking Areas
--
CREATE TABLE iris.parking_area (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) NOT NULL REFERENCES iris.geo_loc(name),
	preset_1 VARCHAR(20) REFERENCES iris.camera_preset(name),
	preset_2 VARCHAR(20) REFERENCES iris.camera_preset(name),
	preset_3 VARCHAR(20) REFERENCES iris.camera_preset(name),
	-- static site data
	site_id VARCHAR(25) UNIQUE,
	time_stamp_static TIMESTAMP WITH time zone,
	relevant_highway VARCHAR(10),
	reference_post VARCHAR(10),
	exit_id VARCHAR(10),
	facility_name VARCHAR(30),
	street_adr VARCHAR(30),
	city VARCHAR(30),
	state VARCHAR(2),
	zip VARCHAR(10),
	time_zone VARCHAR(10),
	ownership VARCHAR(2),
	capacity INTEGER,
	low_threshold INTEGER,
	amenities INTEGER,
	-- dynamic site data
	time_stamp timestamp WITH time zone,
	reported_available VARCHAR(8),
	true_available INTEGER,
	trend VARCHAR(8),
	open BOOLEAN,
	trust_data BOOLEAN,
	last_verification_check TIMESTAMP WITH time zone,
	verification_check_amplitude INTEGER
);

CREATE TABLE iris.parking_area_amenities (
	bit INTEGER PRIMARY KEY,
	amenity VARCHAR(32) NOT NULL
);
ALTER TABLE iris.parking_area_amenities ADD CONSTRAINT amenity_bit_ck
	CHECK (bit >= 0 AND bit < 32);

COPY iris.parking_area_amenities (bit, amenity) FROM stdin;
0	Flush toilet
1	Assisted restroom
2	Drinking fountain
3	Shower
4	Picnic table
5	Picnic shelter
6	Pay phone
7	TTY pay phone
8	Wireless internet
9	ATM
10	Vending machine
11	Shop
12	Play area
13	Pet excercise area
14	Interpretive information
\.

CREATE FUNCTION iris.parking_area_amenities(INTEGER)
	RETURNS SETOF iris.parking_area_amenities AS $parking_area_amenities$
DECLARE
	ms RECORD;
	b INTEGER;
BEGIN
	FOR ms IN SELECT bit, amenity FROM iris.parking_area_amenities LOOP
		b = 1 << ms.bit;
		IF ($1 & b) = b THEN
			RETURN NEXT ms;
		END IF;
	END LOOP;
END;
$parking_area_amenities$ LANGUAGE plpgsql;

CREATE VIEW parking_area_view AS
	SELECT pa.name, site_id, time_stamp_static, relevant_highway,
	       reference_post, exit_id, facility_name, street_adr, city, state,
	       zip, time_zone, ownership, capacity, low_threshold,
	       (SELECT string_agg(a.amenity, ', ') FROM
	        (SELECT bit, amenity FROM iris.parking_area_amenities(amenities)
	         ORDER BY bit) AS a) AS amenities,
	       time_stamp, reported_available, true_available, trend, open,
	       trust_data, last_verification_check, verification_check_amplitude,
	       p1.camera AS camera_1, p2.camera AS camera_2,
	       p3.camera AS camera_3,
	       l.roadway, l.road_dir, l.cross_mod, l.cross_street, l.cross_dir,
	       l.lat, l.lon, sa.value AS camera_image_base_url
	FROM iris.parking_area pa
	LEFT JOIN iris.camera_preset p1 ON preset_1 = p1.name
	LEFT JOIN iris.camera_preset p2 ON preset_2 = p2.name
	LEFT JOIN iris.camera_preset p3 ON preset_3 = p3.name
	LEFT JOIN geo_loc_view l ON pa.geo_loc = l.name
	LEFT JOIN iris.system_attribute sa ON sa.name = 'camera_image_base_url';
GRANT SELECT ON parking_area_view TO PUBLIC;

--
-- Ramp Meters
--
CREATE TABLE iris.meter_type (
	id INTEGER PRIMARY KEY,
	description VARCHAR(32) NOT NULL,
	lanes INTEGER NOT NULL
);

COPY iris.meter_type (id, description, lanes) FROM stdin;
0	One Lane	1
1	Two Lane, Alternate Release	2
2	Two Lane, Simultaneous Release	2
\.

CREATE TABLE iris.meter_algorithm (
	id INTEGER PRIMARY KEY,
	description VARCHAR(32) NOT NULL
);

COPY iris.meter_algorithm (id, description) FROM stdin;
0	No Metering
1	Simple Metering
2	SZM (obsolete)
3	K Adaptive Metering
\.

CREATE TABLE iris.meter_lock (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY iris.meter_lock (id, description) FROM stdin;
1	Maintenance
2	Incident
3	Construction
4	Testing
5	Police panel
6	Manual mode
\.

CREATE TABLE iris._ramp_meter (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes text NOT NULL,
	meter_type INTEGER NOT NULL REFERENCES iris.meter_type(id),
	storage INTEGER NOT NULL,
	max_wait INTEGER NOT NULL,
	algorithm INTEGER NOT NULL REFERENCES iris.meter_algorithm,
	am_target INTEGER NOT NULL,
	pm_target INTEGER NOT NULL,
	beacon VARCHAR(20) REFERENCES iris._beacon,
	m_lock INTEGER REFERENCES iris.meter_lock(id)
);

ALTER TABLE iris._ramp_meter ADD CONSTRAINT _ramp_meter_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.ramp_meter AS
	SELECT m.name, geo_loc, controller, pin, notes, meter_type, storage,
	       max_wait, algorithm, am_target, pm_target, beacon, preset, m_lock
	FROM iris._ramp_meter m
	JOIN iris._device_io d ON m.name = d.name
	JOIN iris._device_preset p ON m.name = p.name;

CREATE FUNCTION iris.ramp_meter_insert() RETURNS TRIGGER AS
	$ramp_meter_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._device_preset (name, preset)
	     VALUES (NEW.name, NEW.preset);
	INSERT INTO iris._ramp_meter
	            (name, geo_loc, notes, meter_type, storage, max_wait,
	             algorithm, am_target, pm_target, beacon, m_lock)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.meter_type,
	             NEW.storage, NEW.max_wait, NEW.algorithm, NEW.am_target,
	             NEW.pm_target, NEW.beacon, NEW.m_lock);
	RETURN NEW;
END;
$ramp_meter_insert$ LANGUAGE plpgsql;

CREATE TRIGGER ramp_meter_insert_trig
    INSTEAD OF INSERT ON iris.ramp_meter
    FOR EACH ROW EXECUTE PROCEDURE iris.ramp_meter_insert();

CREATE FUNCTION iris.ramp_meter_update() RETURNS TRIGGER AS
	$ramp_meter_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._device_preset
	   SET preset = NEW.preset
	 WHERE name = OLD.name;
	UPDATE iris._ramp_meter
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       meter_type = NEW.meter_type,
	       storage = NEW.storage,
	       max_wait = NEW.max_wait,
	       algorithm = NEW.algorithm,
	       am_target = NEW.am_target,
	       pm_target = NEW.pm_target,
	       beacon = NEW.beacon,
	       m_lock = NEW.m_lock
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$ramp_meter_update$ LANGUAGE plpgsql;

CREATE TRIGGER ramp_meter_update_trig
    INSTEAD OF UPDATE ON iris.ramp_meter
    FOR EACH ROW EXECUTE PROCEDURE iris.ramp_meter_update();

CREATE FUNCTION iris.ramp_meter_delete() RETURNS TRIGGER AS
	$ramp_meter_delete$
BEGIN
	DELETE FROM iris._device_preset WHERE name = OLD.name;
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$ramp_meter_delete$ LANGUAGE plpgsql;

CREATE TRIGGER ramp_meter_delete_trig
    INSTEAD OF DELETE ON iris.ramp_meter
    FOR EACH ROW EXECUTE PROCEDURE iris.ramp_meter_delete();

CREATE VIEW ramp_meter_view AS
	SELECT m.name, geo_loc, controller, pin, notes,
	       mt.description AS meter_type, storage, max_wait,
	       alg.description AS algorithm, am_target, pm_target, beacon,
	       camera, preset_num, ml.description AS meter_lock,
	       l.rd, l.roadway, l.road_dir, l.cross_mod, l.cross_street,
	       l.cross_dir, l.lat, l.lon
	FROM iris.ramp_meter m
	LEFT JOIN iris.meter_type mt ON m.meter_type = mt.id
	LEFT JOIN iris.meter_algorithm alg ON m.algorithm = alg.id
	LEFT JOIN iris.camera_preset p ON m.preset = p.name
	LEFT JOIN iris.meter_lock ml ON m.m_lock = ml.id
	LEFT JOIN geo_loc_view l ON m.geo_loc = l.name;
GRANT SELECT ON ramp_meter_view TO PUBLIC;

CREATE TABLE iris.meter_action (
	name VARCHAR(30) PRIMARY KEY,
	action_plan VARCHAR(16) NOT NULL REFERENCES iris.action_plan,
	ramp_meter VARCHAR(20) NOT NULL REFERENCES iris._ramp_meter,
	phase VARCHAR(12) NOT NULL REFERENCES iris.plan_phase
);

CREATE VIEW meter_action_view AS
	SELECT ramp_meter, ta.phase, time_of_day, day_plan, sched_date
	FROM iris.meter_action ma, iris.action_plan ap, iris.time_action ta
	WHERE ma.action_plan = ap.name
	AND ap.name = ta.action_plan
	AND active = true
	ORDER BY ramp_meter, time_of_day;
GRANT SELECT ON meter_action_view TO PUBLIC;

CREATE TABLE event.meter_phase (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY event.meter_phase (id, description) FROM stdin;
0	not started
1	metering
2	flushing
3	stopped
\.

CREATE TABLE event.meter_queue_state (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY event.meter_queue_state (id, description) FROM stdin;
0	unknown
1	empty
2	exists
3	full
\.

CREATE TABLE event.meter_limit_control (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY event.meter_limit_control (id, description) FROM stdin;
0	passage fail
1	storage limit
2	wait limit
3	target minimum
4	backup limit
\.

CREATE TABLE event.meter_event (
	event_id SERIAL PRIMARY KEY,
	event_date TIMESTAMP WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	ramp_meter VARCHAR(20) NOT NULL REFERENCES iris._ramp_meter
		ON DELETE CASCADE,
	phase INTEGER NOT NULL REFERENCES event.meter_phase,
	q_state INTEGER NOT NULL REFERENCES event.meter_queue_state,
	q_len REAL NOT NULL,
	dem_adj REAL NOT NULL,
	wait_secs INTEGER NOT NULL,
	limit_ctrl INTEGER NOT NULL REFERENCES event.meter_limit_control,
	min_rate INTEGER NOT NULL,
	rel_rate INTEGER NOT NULL,
	max_rate INTEGER NOT NULL,
	d_node VARCHAR(10),
	seg_density REAL NOT NULL
);

CREATE VIEW meter_event_view AS
	SELECT event_id, event_date, event_description.description,
	       ramp_meter, meter_phase.description AS phase,
	       meter_queue_state.description AS q_state, q_len, dem_adj,
	       wait_secs, meter_limit_control.description AS limit_ctrl,
	       min_rate, rel_rate, max_rate, d_node, seg_density
	FROM event.meter_event
	JOIN event.event_description
	ON meter_event.event_desc_id = event_description.event_desc_id
	JOIN event.meter_phase ON phase = meter_phase.id
	JOIN event.meter_queue_state ON q_state = meter_queue_state.id
	JOIN event.meter_limit_control ON limit_ctrl = meter_limit_control.id;
GRANT SELECT ON meter_event_view TO PUBLIC;

--
-- Toll Zones, Tag Readers
--
CREATE TABLE iris.toll_zone (
	name VARCHAR(20) PRIMARY KEY,
	start_id VARCHAR(10) REFERENCES iris.r_node(station_id),
	end_id VARCHAR(10) REFERENCES iris.r_node(station_id),
	tollway VARCHAR(16),
	alpha REAL,
	beta REAL,
	max_price REAL
);

CREATE VIEW toll_zone_view AS
	SELECT name, start_id, end_id, tollway, alpha, beta, max_price
	FROM iris.toll_zone;
GRANT SELECT ON toll_zone_view TO PUBLIC;

CREATE TABLE iris.tag_reader_sync_mode (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY iris.tag_reader_sync_mode (id, description) FROM stdin;
0	slave
1	master
2	GPS secondary
3	GPS primary
\.

CREATE TABLE iris._tag_reader (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes VARCHAR(64) NOT NULL,
	toll_zone VARCHAR(20) REFERENCES iris.toll_zone(name),
	downlink_freq_khz INTEGER,
	uplink_freq_khz INTEGER,
	sego_atten_downlink_db INTEGER,
	sego_atten_uplink_db INTEGER,
	sego_data_detect_db INTEGER,
	sego_seen_count INTEGER,
	sego_unique_count INTEGER,
	iag_atten_downlink_db INTEGER,
	iag_atten_uplink_db INTEGER,
	iag_data_detect_db INTEGER,
	iag_seen_count INTEGER,
	iag_unique_count INTEGER,
	line_loss_db INTEGER,
	sync_mode INTEGER REFERENCES iris.tag_reader_sync_mode,
	slave_select_count INTEGER
);

ALTER TABLE iris._tag_reader ADD CONSTRAINT _tag_reader_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.tag_reader AS
	SELECT t.name, geo_loc, controller, pin, notes, toll_zone,
	       downlink_freq_khz, uplink_freq_khz, sego_atten_downlink_db,
	       sego_atten_uplink_db, sego_data_detect_db, sego_seen_count,
	       sego_unique_count, iag_atten_downlink_db, iag_atten_uplink_db,
	       iag_data_detect_db, iag_seen_count, iag_unique_count,
	       line_loss_db, sync_mode, slave_select_count
	FROM iris._tag_reader t JOIN iris._device_io d ON t.name = d.name;

CREATE FUNCTION iris.tag_reader_insert() RETURNS TRIGGER AS
	$tag_reader_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._tag_reader (name, geo_loc, notes, toll_zone,
	                              downlink_freq_khz, uplink_freq_khz,
	                              sego_atten_downlink_db,
	                              sego_atten_uplink_db, sego_data_detect_db,
	                              sego_seen_count, sego_unique_count,
	                              iag_atten_downlink_db,
	                              iag_atten_uplink_db, iag_data_detect_db,
	                              iag_seen_count, iag_unique_count,
	                              line_loss_db, sync_mode,
	                              slave_select_count)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes, NEW.toll_zone,
	             NEW.downlink_freq_khz, NEW.uplink_freq_khz,
	             NEW.sego_atten_downlink_db, NEW.sego_atten_uplink_db,
	             NEW.sego_data_detect_db, NEW.sego_seen_count,
	             NEW.sego_unique_count, NEW.iag_atten_downlink_db,
	             NEW.iag_atten_uplink_db, NEW.iag_data_detect_db,
	             NEW.iag_seen_count, NEW.iag_unique_count, NEW.line_loss_db,
	             NEW.sync_mode, NEW.slave_select_count);
	RETURN NEW;
END;
$tag_reader_insert$ LANGUAGE plpgsql;

CREATE TRIGGER tag_reader_insert_trig
    INSTEAD OF INSERT ON iris.tag_reader
    FOR EACH ROW EXECUTE PROCEDURE iris.tag_reader_insert();

CREATE FUNCTION iris.tag_reader_update() RETURNS TRIGGER AS
	$tag_reader_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._tag_reader
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes,
	       toll_zone = NEW.toll_zone,
	       downlink_freq_khz = NEW.downlink_freq_khz,
	       uplink_freq_khz = NEW.uplink_freq_khz,
	       sego_atten_downlink_db = NEW.sego_atten_downlink_db,
	       sego_atten_uplink_db = NEW.sego_atten_uplink_db,
	       sego_data_detect_db = NEW.sego_data_detect_db,
	       sego_seen_count = NEW.sego_seen_count,
	       sego_unique_count = NEW.sego_unique_count,
	       iag_atten_downlink_db = NEW.iag_atten_downlink_db,
	       iag_atten_uplink_db = NEW.iag_atten_uplink_db,
	       iag_data_detect_db = NEW.iag_data_detect_db,
	       iag_seen_count = NEW.iag_seen_count,
	       iag_unique_count = NEW.iag_unique_count,
	       line_loss_db = NEW.line_loss_db,
	       sync_mode = NEW.sync_mode,
	       slave_select_count = NEW.slave_select_count
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$tag_reader_update$ LANGUAGE plpgsql;

CREATE TRIGGER tag_reader_update_trig
    INSTEAD OF UPDATE ON iris.tag_reader
    FOR EACH ROW EXECUTE PROCEDURE iris.tag_reader_update();

CREATE FUNCTION iris.tag_reader_delete() RETURNS TRIGGER AS
	$tag_reader_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$tag_reader_delete$ LANGUAGE plpgsql;

CREATE TRIGGER tag_reader_delete_trig
    INSTEAD OF DELETE ON iris.tag_reader
    FOR EACH ROW EXECUTE PROCEDURE iris.tag_reader_delete();

CREATE VIEW tag_reader_view AS
	SELECT t.name, t.geo_loc, location, controller, pin, notes, toll_zone,
	       downlink_freq_khz, uplink_freq_khz,
	       sego_atten_downlink_db, sego_atten_uplink_db, sego_data_detect_db,
	       sego_seen_count, sego_unique_count,
	       iag_atten_downlink_db, iag_atten_uplink_db, iag_data_detect_db,
	       iag_seen_count, iag_unique_count, line_loss_db,
	       m.description AS sync_mode, slave_select_count
	FROM iris.tag_reader t
	LEFT JOIN geo_loc_view l ON t.geo_loc = l.name
	LEFT JOIN iris.tag_reader_sync_mode m ON t.sync_mode = m.id;
GRANT SELECT ON tag_reader_view TO PUBLIC;

CREATE TABLE iris.tag_reader_dms (
	tag_reader VARCHAR(20) NOT NULL REFERENCES iris._tag_reader,
	dms VARCHAR(20) NOT NULL REFERENCES iris._dms
);
ALTER TABLE iris.tag_reader_dms ADD PRIMARY KEY (tag_reader, dms);

CREATE VIEW tag_reader_dms_view AS
	SELECT tag_reader, dms
	FROM iris.tag_reader_dms;
GRANT SELECT ON tag_reader_dms_view TO PUBLIC;

CREATE TABLE event.tag_type (
	id INTEGER PRIMARY KEY,
	description VARCHAR(16) NOT NULL
);

COPY event.tag_type (id, description) FROM stdin;
0	Unknown
1	SeGo
2	IAG
3	ASTMv6
\.

CREATE TABLE event.tag_read_event (
	event_id SERIAL PRIMARY KEY,
	event_date timestamp WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	tag_type INTEGER NOT NULL REFERENCES event.tag_type,
	agency INTEGER,
	tag_id INTEGER NOT NULL,
	tag_reader VARCHAR(20) NOT NULL,
	hov BOOLEAN NOT NULL,
	trip_id INTEGER
);

CREATE INDEX ON event.tag_read_event(tag_id);

CREATE VIEW tag_read_event_view AS
	SELECT event_id, event_date, event_description.description,
	       tag_type.description AS tag_type, agency, tag_id, tag_reader,
	       toll_zone, tollway, hov, trip_id
	FROM event.tag_read_event
	JOIN event.event_description
	ON   tag_read_event.event_desc_id = event_description.event_desc_id
	JOIN event.tag_type
	ON   tag_read_event.tag_type = tag_type.id
	JOIN iris._tag_reader
	ON   tag_read_event.tag_reader = _tag_reader.name
	LEFT JOIN iris.toll_zone
	ON        _tag_reader.toll_zone = toll_zone.name;
GRANT SELECT ON tag_read_event_view TO PUBLIC;

-- Allow trip_id column to be updated by roles which have been granted
-- update permission on tag_read_event_view
CREATE FUNCTION event.tag_read_event_view_update() RETURNS TRIGGER AS
	$tag_read_event_view_update$
BEGIN
	UPDATE event.tag_read_event
	   SET trip_id = NEW.trip_id
	 WHERE event_id = OLD.event_id;
	RETURN NEW;
END;
$tag_read_event_view_update$ LANGUAGE plpgsql;

CREATE TRIGGER tag_read_event_view_update_trig
    INSTEAD OF UPDATE ON tag_read_event_view
    FOR EACH ROW EXECUTE PROCEDURE event.tag_read_event_view_update();

CREATE TABLE event.price_message_event (
	event_id SERIAL PRIMARY KEY,
	event_date timestamp WITH time zone NOT NULL,
	event_desc_id INTEGER NOT NULL
		REFERENCES event.event_description(event_desc_id),
	device_id VARCHAR(20) NOT NULL,
	toll_zone VARCHAR(20) NOT NULL,
	price NUMERIC(4,2) NOT NULL
);

CREATE INDEX ON event.price_message_event(event_date);
CREATE INDEX ON event.price_message_event(device_id);

CREATE VIEW price_message_event_view AS
	SELECT event_id, event_date, event_description.description,
	       device_id, toll_zone, price
	FROM event.price_message_event
	JOIN event.event_description
	ON price_message_event.event_desc_id = event_description.event_desc_id;
GRANT SELECT ON price_message_event_view TO PUBLIC;

CREATE VIEW iris.quick_message_priced AS
    SELECT name AS quick_message, 'priced'::VARCHAR(6) AS state,
        unnest(string_to_array(substring(multi FROM '%tzp,#"[^]]*#"]%' FOR '#'),
        ',')) AS toll_zone
    FROM iris.quick_message WHERE multi LIKE '%tzp%';

CREATE VIEW iris.quick_message_open AS
    SELECT name AS quick_message, 'open'::VARCHAR(6) AS state,
        unnest(string_to_array(substring(multi FROM '%tzo,#"[^]]*#"]%' FOR '#'),
        ',')) AS toll_zone
    FROM iris.quick_message WHERE multi LIKE '%tzo%';

CREATE VIEW iris.quick_message_closed AS
    SELECT name AS quick_message, 'closed'::VARCHAR(6) AS state,
        unnest(string_to_array(substring(multi FROM '%tzc,#"[^]]*#"]%' FOR '#'),
        ',')) AS toll_zone
    FROM iris.quick_message WHERE multi LIKE '%tzc%';

CREATE VIEW iris.quick_message_toll_zone AS
    SELECT quick_message, state, toll_zone
        FROM iris.quick_message_priced UNION ALL
    SELECT quick_message, state, toll_zone
        FROM iris.quick_message_open UNION ALL
    SELECT quick_message, state, toll_zone
        FROM iris.quick_message_closed;

CREATE VIEW dms_toll_zone_view AS
    SELECT dms, state, toll_zone, action_plan, dms_action_view.quick_message
    FROM dms_action_view
    JOIN iris.dms_sign_group
    ON dms_action_view.sign_group = dms_sign_group.sign_group
    JOIN iris.quick_message
    ON dms_action_view.quick_message = quick_message.name
    JOIN iris.quick_message_toll_zone
    ON dms_action_view.quick_message = quick_message_toll_zone.quick_message;
GRANT SELECT ON dms_toll_zone_view TO PUBLIC;

--
-- Video Monitors
--
CREATE TABLE iris.monitor_style (
	name VARCHAR(24) PRIMARY KEY,
	force_aspect BOOLEAN NOT NULL,
	accent VARCHAR(8) NOT NULL,
	font_sz INTEGER NOT NULL,
	title_bar BOOLEAN NOT NULL,
	auto_expand BOOLEAN NOT NULL,
	hgap INTEGER NOT NULL,
	vgap INTEGER NOT NULL
);

CREATE VIEW monitor_style_view AS
	SELECT name, force_aspect, accent, font_sz, title_bar, auto_expand,
	       hgap, vgap
	FROM iris.monitor_style;
GRANT SELECT ON monitor_style_view TO PUBLIC;

CREATE TABLE iris._video_monitor (
	name VARCHAR(12) PRIMARY KEY,
	notes VARCHAR(32) NOT NULL,
	group_n VARCHAR(16),
	mon_num INTEGER NOT NULL,
	restricted BOOLEAN NOT NULL,
	monitor_style VARCHAR(24) REFERENCES iris.monitor_style,
	camera VARCHAR(20) REFERENCES iris._camera
);

ALTER TABLE iris._video_monitor ADD CONSTRAINT _video_monitor_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.video_monitor AS
	SELECT m.name, controller, pin, notes, group_n, mon_num, restricted,
	       monitor_style, camera
	FROM iris._video_monitor m JOIN iris._device_io d ON m.name = d.name;

CREATE FUNCTION iris.video_monitor_insert() RETURNS TRIGGER AS
	$video_monitor_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._video_monitor (name, notes, group_n, mon_num,
	                                 restricted, monitor_style, camera)
	     VALUES (NEW.name, NEW.notes, NEW.group_n, NEW.mon_num,
	             NEW.restricted, NEW.monitor_style, NEW.camera);
	RETURN NEW;
END;
$video_monitor_insert$ LANGUAGE plpgsql;

CREATE TRIGGER video_monitor_insert_trig
    INSTEAD OF INSERT ON iris.video_monitor
    FOR EACH ROW EXECUTE PROCEDURE iris.video_monitor_insert();

CREATE FUNCTION iris.video_monitor_update() RETURNS TRIGGER AS
	$video_monitor_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._video_monitor
	   SET notes = NEW.notes,
	       group_n = NEW.group_n,
	       mon_num = NEW.mon_num,
	       restricted = NEW.restricted,
	       monitor_style = NEW.monitor_style,
	       camera = NEW.camera
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$video_monitor_update$ LANGUAGE plpgsql;

CREATE TRIGGER video_monitor_update_trig
    INSTEAD OF UPDATE ON iris.video_monitor
    FOR EACH ROW EXECUTE PROCEDURE iris.video_monitor_update();

CREATE FUNCTION iris.video_monitor_delete() RETURNS TRIGGER AS
	$video_monitor_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$video_monitor_delete$ LANGUAGE plpgsql;

CREATE TRIGGER video_monitor_delete_trig
    INSTEAD OF DELETE ON iris.video_monitor
    FOR EACH ROW EXECUTE PROCEDURE iris.video_monitor_delete();

CREATE VIEW video_monitor_view AS
	SELECT m.name, m.notes, group_n, mon_num, restricted, monitor_style,
	       m.controller, m.pin, ctr.condition, ctr.comm_link, camera
	FROM iris.video_monitor m
	LEFT JOIN controller_view ctr ON m.controller = ctr.name;
GRANT SELECT ON video_monitor_view TO PUBLIC;

--
-- Weather Sensors
--
CREATE TABLE iris._weather_sensor (
	name VARCHAR(20) PRIMARY KEY,
	geo_loc VARCHAR(20) REFERENCES iris.geo_loc(name),
	notes VARCHAR(64) NOT NULL
);

ALTER TABLE iris._weather_sensor ADD CONSTRAINT _weather_sensor_fkey
	FOREIGN KEY (name) REFERENCES iris._device_io(name) ON DELETE CASCADE;

CREATE VIEW iris.weather_sensor AS SELECT
	m.name, geo_loc, controller, pin, notes
	FROM iris._weather_sensor m JOIN iris._device_io d ON m.name = d.name;

CREATE FUNCTION iris.weather_sensor_insert() RETURNS TRIGGER AS
	$weather_sensor_insert$
BEGIN
	INSERT INTO iris._device_io (name, controller, pin)
	     VALUES (NEW.name, NEW.controller, NEW.pin);
	INSERT INTO iris._weather_sensor (name, geo_loc, notes)
	     VALUES (NEW.name, NEW.geo_loc, NEW.notes);
	RETURN NEW;
END;
$weather_sensor_insert$ LANGUAGE plpgsql;

CREATE TRIGGER weather_sensor_insert_trig
    INSTEAD OF INSERT ON iris.weather_sensor
    FOR EACH ROW EXECUTE PROCEDURE iris.weather_sensor_insert();

CREATE FUNCTION iris.weather_sensor_update() RETURNS TRIGGER AS
	$weather_sensor_update$
BEGIN
	UPDATE iris._device_io
	   SET controller = NEW.controller,
	       pin = NEW.pin
	 WHERE name = OLD.name;
	UPDATE iris._weather_sensor
	   SET geo_loc = NEW.geo_loc,
	       notes = NEW.notes
	 WHERE name = OLD.name;
	RETURN NEW;
END;
$weather_sensor_update$ LANGUAGE plpgsql;

CREATE TRIGGER weather_sensor_update_trig
    INSTEAD OF UPDATE ON iris.weather_sensor
    FOR EACH ROW EXECUTE PROCEDURE iris.weather_sensor_update();

CREATE FUNCTION iris.weather_sensor_delete() RETURNS TRIGGER AS
	$weather_sensor_delete$
BEGIN
	DELETE FROM iris._device_io WHERE name = OLD.name;
	IF FOUND THEN
		RETURN OLD;
	ELSE
		RETURN NULL;
	END IF;
END;
$weather_sensor_delete$ LANGUAGE plpgsql;

CREATE TRIGGER weather_sensor_delete_trig
    INSTEAD OF DELETE ON iris.weather_sensor
    FOR EACH ROW EXECUTE PROCEDURE iris.weather_sensor_delete();

CREATE VIEW weather_sensor_view AS
	SELECT w.name, w.notes, w.geo_loc, l.roadway, l.road_dir, l.cross_mod,
	       l.cross_street, l.cross_dir, l.lat, l.lon,
	       w.controller, w.pin, ctr.comm_link, ctr.drop_id, ctr.condition
	FROM iris.weather_sensor w
	LEFT JOIN geo_loc_view l ON w.geo_loc = l.name
	LEFT JOIN controller_view ctr ON w.controller = ctr.name;
GRANT SELECT ON weather_sensor_view TO PUBLIC;

--
-- Device / Controller views
--
CREATE VIEW iris.device_geo_loc_view AS
	SELECT name, geo_loc FROM iris._lane_marking UNION ALL
	SELECT name, geo_loc FROM iris._beacon UNION ALL
	SELECT name, geo_loc FROM iris._weather_sensor UNION ALL
	SELECT name, geo_loc FROM iris._tag_reader UNION ALL
	SELECT name, geo_loc FROM iris._camera UNION ALL
	SELECT name, geo_loc FROM iris._dms UNION ALL
	SELECT name, geo_loc FROM iris._ramp_meter UNION ALL
	SELECT g.name, geo_loc FROM iris._gate_arm g
	JOIN iris._gate_arm_array ga ON g.ga_array = ga.name UNION ALL
	SELECT d.name, geo_loc FROM iris._detector d
	JOIN iris.r_node rn ON d.r_node = rn.name;

CREATE VIEW controller_device_view AS
	SELECT d.name, d.controller, d.pin, g.geo_loc,
	trim(l.roadway || ' ' || l.road_dir) AS corridor,
	trim(trim(' @' FROM l.cross_mod || ' ' || l.cross_street)
		|| ' ' || l.cross_dir) AS cross_loc
	FROM iris._device_io d
	JOIN iris.device_geo_loc_view g ON d.name = g.name
	JOIN geo_loc_view l ON g.geo_loc = l.name;
GRANT SELECT ON controller_device_view TO PUBLIC;

CREATE VIEW controller_report AS
	SELECT c.name, c.comm_link, c.drop_id, l.landmark, cab.geo_loc,
	       l.location, cab.style AS "type", d.name AS device, d.pin,
	       d.cross_loc, d.corridor, c.notes
	FROM iris.controller c
	LEFT JOIN iris.cabinet cab ON c.cabinet = cab.name
	LEFT JOIN geo_loc_view l ON cab.geo_loc = l.name
	LEFT JOIN controller_device_view d ON d.controller = c.name;
GRANT SELECT ON controller_report TO PUBLIC;

COMMIT;
