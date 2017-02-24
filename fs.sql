drop schema if exists fs cascade;

create schema fs;

set search_path to fs;


create domain v varchar(50);

create table citta ( nome v primary key, na integer, nazione v);

insert into citta values('perugia','1000000','italia');
insert into citta values('roma','7000000','italia');
insert into citta values('milano','3000000','italia');
insert into citta values('bologna','2000000','italia');
insert into citta values('firenze','2500000','italia');

create table stazione ( codice v primary key, nome v, categoria v, citta v references citta(nome) on delete cascade on update cascade); 

insert into stazione values('abc01','bologna_centrale','gg', 'bologna');
insert into stazione values('abc02','perugia_centrale','gg', 'perugia');
insert into stazione values('abc03','roma_fontivegge','gg', 'roma');
insert into stazione values('abc04','milano_marittima','gg', 'milano');
insert into stazione values('abc05','firenze_santa_maria_novella','gg', 'firenze');
insert into stazione values('abc06','milano_ro','gg', 'milano');
insert into stazione values('abc07','roma_chianina','gg', 'roma');

create table treno (codice v primary key, orpar v, stpar v references stazione(codice) on delete cascade on update cascade, orarr v, starr v references stazione (codice) on delete cascade on update cascade, azienda v); 

insert into treno values('xyz01','8.20','abc01', '13.20', 'abc02', 'trenitalia');
insert into treno values('xyz02','9.20','abc02', '13.20', 'abc03', 'trenitalia');
insert into treno values('xyz03','10.20','abc03', '14.20', 'abc04', 'trenitalia');
insert into treno values('xyz04','10.20','abc04', '14.20', 'abc04', 'trenitalia');
insert into treno values('xyz05','10.20','abc05', '14.20', 'abc04', 'trenitalia');
insert into treno values('xyz06','10.20','abc06', '14.20', 'abc04', 'trenitalia');
insert into treno values('xyz07','10.20','abc07', '14.20', 'abc04', 'trenitalia');
insert into treno values('xyz08','11.20','abc04', '16.20', 'abc05', 'trenifrancia');
insert into treno values('xyz09','12.20','abc05', '17.20', 'abc01', 'trenigermania');

create table percorso(treno v references treno(codice) on delete cascade on update cascade, citta v references citta(nome) on delete cascade on update cascade, primary key (treno,citta));

insert into percorso values('xyz01', 'roma');
insert into percorso values('xyz02', 'milano');
insert into percorso values('xyz03', 'roma');
insert into percorso values('xyz04', 'roma');
insert into percorso values('xyz05', 'perugia');

select distinct treno.codice from treno where stpar = (select codice from stazione where nome='bologna') or starr = (select codice from stazione where nome = 'perugia');

select distinct treno.codice from treno where stpar = any(select codice from stazione where nome!= 'bologna');

select treno.azienda from treno where treno.stpar in (select stazione.codice from stazione) group by treno.azienda having count (*) = (select count(*) from stazione); 

alter table citta add numstazioni integer;

create function agg() returns trigger as $BODY$
declare
	citta v;
begin 
	update citta set numstazioni = (select count (s.citta) from stazione s where s.citta=new.citta group by s.citta) where nome = new.citta;
return new;
end 
$BODY$
language plpgsql;

create trigger agg after delete or update or insert on stazione for each row execute procedure agg();

 











