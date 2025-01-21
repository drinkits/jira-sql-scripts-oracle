SELECT DISTINCT USERNAME
FROM
	(select 
		u.lower_user_name as "USERNAME",
		u.display_name as "DISPLAYNAME",
		u.LOWER_EMAIL_ADDRESS as "EMAIL",
		LISTAGG(g.group_name, ', ') WITHIN GROUP (ORDER BY g.group_name) AS "Grupas"
	FROM CWD_USER u
	left join cwd_membership m on m.child_id = u.id
	left join cwd_group g on g.id = m.parent_id
	where u.id in (
		select u.id
		from cwd_user u
		left join cwd_membership m on m.child_id = u.id
		left join cwd_group g on g.id = m.parent_id
	)
	and u.active = 1
	and u.directory_id = 3
	and u.LOWER_USER_NAME not in
			(SELECT CWD_USER.LOWER_USER_NAME
				FROM CWD_USER,
					CWD_USER_ATTRIBUTES
				WHERE CWD_USER_ATTRIBUTES.USER_ID = CWD_USER.ID
					AND CWD_USER_ATTRIBUTES.ATTRIBUTE_NAME = 'login.count')
		AND u.CREATED_DATE <= to_date(SYSDATE - 182, 'yyyy-mm-dd')
		AND g.group_name != 'Tehniskie konti'
	group by u.lower_user_name, u.display_name, u.LOWER_EMAIL_ADDRESS

	UNION ALL

	select 
		u.lower_user_name as "USERNAME",
		u.display_name as "DISPLAYNAME",
		u.LOWER_EMAIL_ADDRESS as "EMAIL",
		LISTAGG(g.group_name, ', ') WITHIN GROUP (ORDER BY g.group_name) AS "Grupas"
	from cwd_user u
	left join app_user a on a.lower_user_name = u.lower_user_name
	left join cwd_membership m on m.child_id = u.id
	left join cwd_group g on g.id = m.parent_id
	join cwd_user_attributes ca on u.id = ca.user_id
	join le_bura_users lbu on u.lower_user_name = lbu.user_name
	where u.id in (
		select u.id
		from cwd_user u
		left join cwd_membership m on m.child_id = u.id
		left join cwd_group g on g.id = m.parent_id
	)
	and u.active = 1
	and u.directory_id = 3
	AND ca.attribute_name ='login.lastLoginMillis'
	AND g.group_name != 'Tehniskie konti'
	AND to_char(to_date('01.01.1970','dd.mm.yyyy') + to_number(ca.attribute_value)/1000/60/60/24, 'yyyy-mm-dd') <= to_date(SYSDATE - 182, 'yyyy-mm-dd')
	group by u.lower_user_name, u.display_name, u.LOWER_EMAIL_ADDRESS, lbu.org_name, lbu.org_tree, ca.attribute_value)
