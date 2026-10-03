-- CGE ARSTM — Nom du Président affiché : « NANGUI AKRE »
update public.bureau_members
set name = 'NANGUI AKRE'
where department = 'presidence' or name = 'NANGUI AKRE YOHAN'
returning name, role;
