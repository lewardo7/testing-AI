insert into public.departments(code,name) values
('NEU','Neurology'),('PUL','Pulmonology'),('INT','Internal Medicine'),
('SUR','General Surgery'),('OBG','Obstetrics & Gynecology'),('PED','Pediatrics')
on conflict(code) do update set name=excluded.name;
