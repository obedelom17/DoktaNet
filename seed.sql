-- Mot de passe de tous les comptes : Test1234!
insert into users (id,email,phone,password_hash,role,full_name,status,consent_at) values
('00000000-0000-0000-0000-000000000001','admin@doktanet.test','+22890000001','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','admin','Admin DoktaNet','active',now()),
('00000000-0000-0000-0000-000000000002','dr.kofi@doktanet.test','+22890000002','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','doctor','Kofi Mensah','active',now()),
('00000000-0000-0000-0000-000000000003','dr.ama@doktanet.test','+22890000003','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','doctor','Ama Agbodjan','active',now()),
('00000000-0000-0000-0000-000000000004','patient@doktanet.test','+22890000004','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','patient','Yao Amegah','active',now()),
('00000000-0000-0000-0000-000000000005','pharma.lome@doktanet.test','+22890000005','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','pharmacy','Pharmacie du Port','active',now()),
('00000000-0000-0000-0000-000000000006','pharma.tokoin@doktanet.test','+22890000006','BRYnOElaa3yNnq_A0eLzBA.lejMVtmY1jqSPgQdHPVJ1gqfTExOEtGrwZ0zxvBohY8','pharmacy','Pharmacie Tokoin','active',now())
on conflict do nothing;

insert into patient_profiles (user_id,birth_date,allergies,antecedents) values
('00000000-0000-0000-0000-000000000004','12/05/1995','Pénicilline','Asthme léger')
on conflict do nothing;

insert into doctor_profiles (user_id,order_number,specialty,city,fee,experience_years,languages,bio) values
('00000000-0000-0000-0000-000000000002','OMT-0001','Médecine générale','Lomé',5000,8,'Français, Ewé','Médecin généraliste.'),
('00000000-0000-0000-0000-000000000003','OMT-0002','Pédiatrie','Lomé',8000,12,'Français, Kabiyè','Pédiatre.')
on conflict do nothing;

insert into doctor_availability (doctor_id,weekday,start_time,end_time)
select '00000000-0000-0000-0000-000000000002', w, t.s::time, t.e::time
from generate_series(1,5) w, (values ('08:00','12:00'),('14:00','17:00')) t(s,e);
insert into doctor_availability (doctor_id,weekday,start_time,end_time)
select '00000000-0000-0000-0000-000000000003', w, '09:00'::time, '15:00'::time from generate_series(1,6) w;

insert into pharmacy_profiles (user_id,name,license_number,city,address,phone,lat,lng) values
('00000000-0000-0000-0000-000000000005','Pharmacie du Port','LIC-001','Lomé','Boulevard du Mono','+22890000005',6.1375,1.2123),
('00000000-0000-0000-0000-000000000006','Pharmacie Tokoin','LIC-002','Lomé','Rue de Tokoin','+22890000006',6.1530,1.2260)
on conflict do nothing;

insert into pharmacy_stock (pharmacy_id,name,quantity,price) values
('00000000-0000-0000-0000-000000000005','Paracétamol 500mg',120,500),
('00000000-0000-0000-0000-000000000005','Amoxicilline 500mg',40,1500),
('00000000-0000-0000-0000-000000000005','Ibuprofène 400mg',3,800),
('00000000-0000-0000-0000-000000000005','Artéméther-Luméfantrine',25,2500),
('00000000-0000-0000-0000-000000000006','Paracétamol 500mg',60,550),
('00000000-0000-0000-0000-000000000006','Sels de réhydratation orale',80,300),
('00000000-0000-0000-0000-000000000006','Vitamine C 500mg',2,1000)
on conflict do nothing;

insert into appointments (patient_id,doctor_id,starts_at)
select '00000000-0000-0000-0000-000000000004','00000000-0000-0000-0000-000000000002', date_trunc('day', now()) + interval '1 day 10 hours'
where not exists (select 1 from appointments where doctor_id='00000000-0000-0000-0000-000000000002' and status<>'cancelled' and starts_at = date_trunc('day', now()) + interval '1 day 10 hours');
