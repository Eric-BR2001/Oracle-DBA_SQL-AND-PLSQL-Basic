/*
-- QUOTAS

DROP VIEW emp_details_view;

DROP SEQUENCE departamentos_seq;
DROP SEQUENCE funcionarios_seq;
DROP SEQUENCE localizacoes_seq;

DROP TABLE regioes     CASCADE CONSTRAINTS;
DROP TABLE departamentos CASCADE CONSTRAINTS;
DROP TABLE localizacoes   CASCADE CONSTRAINTS;
DROP TABLE cargos        CASCADE CONSTRAINTS;
DROP TABLE cargo_hist CASCADE CONSTRAINTS;
DROP TABLE funcionarios   CASCADE CONSTRAINTS;
DROP TABLE paises   CASCADE CONSTRAINTS;  
drop table mensagens;
*/

create table mensagens (texto varchar2(300));

Rem
Rem $Header: hr_cre.sql 29-aug-2002.11:44:03 hyeh Exp $
Rem
Rem hr_cre.sql
Rem
Rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      hr_cre.sql - Create data objects for HR schema
Rem
Rem    DESCRIPTION
Rem      This script creates six tables, associated constraints
Rem      and indexes in the human resources (HR) schema.
Rem
Rem    NOTES
Rem
Rem    CREATED by Nancy Greenberg, Nagavalli Pataballa - 06/01/00
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hyeh        08/29/02 - hyeh_mv_comschema_to_rdbms
Rem    ahunold     09/14/00 - Added emp_details_view
Rem    ahunold     02/20/01 - New header
Rem    vpatabal	 03/02/01 - Added regioes table, modified regioes
Rem			            column in countries table to NUMBER.
Rem			            Added foreign key from countries table
Rem			            to regioes table on region_id.
Rem		                    Removed currency name, currency symbol 
Rem			            columns from the countries table.
Rem		      	            Removed dn columns from funcionarios and
Rem			            departamentos tables.
Rem			            Added sequences.	
Rem			            Removed not null constraint from 
Rem 			            salary column of the funcionarios table.

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 

REM ********************************************************************
REM Create the regioes table to hold region information for localizacoes
REM HR.localizacoes table has a foreign key to this table.

Prompt ******  Creating regioes table ....

CREATE TABLE regioes
    ( id_regiao      NUMBER 
       CONSTRAINT  id_regiao NOT NULL 
    , nome_regiao    VARCHAR2(25) 
    );

CREATE UNIQUE INDEX reg_id_pk
ON regioes (id_regiao);

ALTER TABLE regioes
ADD ( CONSTRAINT reg_id_pk
       		 PRIMARY KEY (id_regiao)
    ) ;

REM ********************************************************************
REM Create the COUNTRIES table to hold country information for customers
REM and company localizacoes. 
REM OE.CUSTOMERS table and HR.localizacoes have a foreign key to this table.

Prompt ******  Creating COUNTRIES table ....

CREATE TABLE paises 
    ( id_pais      CHAR(2) 
       CONSTRAINT  id_pais NOT NULL 
    , nome_pais    VARCHAR2(40) 
    , id_regiao       NUMBER 
    , CONSTRAINT     pais_c_id_pk 
        	     PRIMARY KEY (id_pais) 
    ) 
    ORGANIZATION INDEX; 

ALTER TABLE paises
ADD ( CONSTRAINT pais_reg_fk
        	 FOREIGN KEY (id_regiao)
          	  REFERENCES regioes(id_regiao) 
    ) ;

REM ********************************************************************
REM Create the localizacoes table to hold address information for company departamentos.
REM HR.departamentos has a foreign key to this table.

Prompt ******  Creating localizacoes table ....

CREATE TABLE localizacoes
    ( id_localizacao    NUMBER(4)
    , endereco VARCHAR2(40)
    , cep    VARCHAR2(12)
    , cidade       VARCHAR2(30)
	CONSTRAINT     cidade  NOT NULL
    , estado VARCHAR2(25)
    , id_pais     CHAR(2)
    ) ;

CREATE UNIQUE INDEX loc_id_pk
ON localizacoes (id_localizacao) ;

ALTER TABLE localizacoes
ADD ( CONSTRAINT loc_id_pk
       		 PRIMARY KEY (id_localizacao)
    , CONSTRAINT loc_c_id_fk
       		 FOREIGN KEY (id_pais)
        	  REFERENCES paises(id_pais) 
    ) ;

Rem 	Useful for any subsequent addition of rows to localizacoes table
Rem 	Starts with 3300

CREATE SEQUENCE localizacoes_seq
 START WITH     3300
 INCREMENT BY   100
 MAXVALUE       9900
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the departamentos table to hold company department information.
REM HR.funcionarios and HR.cargo_hist have a foreign key to this table.

Prompt ******  Creating departamentos table ....

CREATE TABLE departamentos
    ( id_departamento    NUMBER(4)
    , nome_departamento  VARCHAR2(30)
	CONSTRAINT  dept_nome_nn  NOT NULL
    , id_gerente       NUMBER(6)
    , id_localizacao      NUMBER(4)
    ) ;

CREATE UNIQUE INDEX dept_id_pk
ON departamentos (id_departamento) ;

ALTER TABLE departamentos
ADD ( CONSTRAINT dept_id_pk
       		 PRIMARY KEY (id_departamento)
    , CONSTRAINT dept_loc_fk
       		 FOREIGN KEY (id_localizacao)
        	  REFERENCES localizacoes (id_localizacao)
     ) ;

Rem 	Useful for any subsequent addition of rows to departamentos table
Rem 	Starts with 280 

CREATE SEQUENCE departamentos_seq
 START WITH     280
 INCREMENT BY   10
 MAXVALUE       9990
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the cargos table to hold the different names of job roles within the company.
REM HR.funcionarios has a foreign key to this table.

Prompt ******  Creating cargos table ....

CREATE TABLE cargos
    ( id_cargo         VARCHAR2(10)
    , cargo      VARCHAR2(35)
	CONSTRAINT     job_title_nn  NOT NULL
    , salario_minimo     NUMBER(6)
    , salario_maximo     NUMBER(6)
    ) ;

CREATE UNIQUE INDEX job_id_pk 
ON cargos (id_cargo) ;

ALTER TABLE cargos
ADD ( CONSTRAINT cargo_id_pk
      		 PRIMARY KEY(id_cargo)
    ) ;

REM ********************************************************************
REM Create the funcionarios table to hold the employee personnel 
REM information for the company.
REM HR.funcionarios has a self referencing foreign key to this table.

Prompt ******  Creating funcionarios table ....

CREATE TABLE funcionarios
    ( id_funcionario    NUMBER(6)
    , primeiro_nome     VARCHAR2(20)
    , ultimo_nome      VARCHAR2(25)
	 CONSTRAINT     fun_ultimo_nome_nn  NOT NULL
    , email          VARCHAR2(25)
	CONSTRAINT     fun_email_nn  NOT NULL
    , telefone   VARCHAR2(20)
    , dt_admissao      DATE
	CONSTRAINT     fun_dt_adm_nn  NOT NULL
    , id_cargo         VARCHAR2(10)
	CONSTRAINT     fun_cargo_nn  NOT NULL
    , salario         NUMBER(8,2)
    , pct_comissao NUMBER(2,2)
    , id_gerente     NUMBER(6)
    , id_departamento  NUMBER(4)
    , CONSTRAINT     fum_salario_min
                     CHECK (salario > 0) 
    , CONSTRAINT     fun_email_uk
                     UNIQUE (email)
    ) ;

CREATE UNIQUE INDEX fun_fun_id_pk
ON funcionarios (id_funcionario) ;


ALTER TABLE funcionarios
ADD ( CONSTRAINT     fun_id_pk
                     PRIMARY KEY (id_funcionario)
    , CONSTRAINT     fun_dept_fk
                     FOREIGN KEY (id_departamento)
                      REFERENCES departamentos
    , CONSTRAINT     fun_cargo_fk
                     FOREIGN KEY (id_cargo)
                      REFERENCES cargos (id_cargo)
    , CONSTRAINT     fun_gerente_fk
                     FOREIGN KEY (id_gerente)
                      REFERENCES funcionarios
    ) ;

ALTER TABLE departamentos
ADD ( CONSTRAINT dept_mgr_fk
      		 FOREIGN KEY (id_gerente)
      		  REFERENCES funcionarios (id_funcionario)
    ) ;


Rem 	Useful for any subsequent addition of rows to funcionarios table
Rem 	Starts with 207 


CREATE SEQUENCE funcionarios_seq
 START WITH     207
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

REM ********************************************************************
REM Create the cargo_hist table to hold the history of cargos that 
REM funcionarios have held in the past.
REM HR.cargos, HR_departamentos, and HR.funcionarios have a foreign key to this table.

Prompt ******  Creating cargo_hist table ....

CREATE TABLE cargo_hist
    ( id_funcionario   NUMBER(6)
	 CONSTRAINT    jhist_func_nn  NOT NULL
    , dt_inicio    DATE
	CONSTRAINT    jhist_start_date_nn  NOT NULL
    , dt_fim      DATE
	CONSTRAINT    jhist_end_date_nn  NOT NULL
    , id_cargo        VARCHAR2(10)
	CONSTRAINT    jhist_job_nn  NOT NULL
    , id_departamento NUMBER(4)
    , CONSTRAINT    jhist_date_interval
                    CHECK (dt_fim > dt_inicio)
    ) ;

CREATE UNIQUE INDEX jhist_fun_id_st_date_pk 
ON cargo_hist (id_funcionario, dt_inicio) ;

ALTER TABLE cargo_hist
ADD ( CONSTRAINT jhist_emp_id_st_date_pk
      PRIMARY KEY (id_funcionario, dt_inicio)
    , CONSTRAINT     jhist_job_fk
                     FOREIGN KEY (id_cargo)
                     REFERENCES cargos
    , CONSTRAINT     jhist_fun_fk
                     FOREIGN KEY (id_funcionario)
                     REFERENCES funcionarios
    , CONSTRAINT     jhist_dept_fk
                     FOREIGN KEY (id_departamento)
                     REFERENCES departamentos
    ) ;

REM ********************************************************************
REM Create the EMP_DETAILS_VIEW that joins the funcionarios, cargos, 
REM departamentos, cargos, countries, and localizacoes table to provide details
REM about funcionarios.

Prompt ******  Creating EMP_DETAILS_VIEW view ...

CREATE OR REPLACE VIEW vw_detalhes_func
AS SELECT
  e.id_funcionario, 
  e.id_cargo, 
  e.id_gerente, 
  e.id_departamento,
  d.id_localizacao,
  l.id_pais,
  e.primeiro_nome,
  e.ultimo_nome,
  e.salario,
  e.pct_comissao,
  d.nome_departamento,
  j.cargo,
  l.cidade,
  l.estado,
  c.nome_pais,
  r.nome_regiao
FROM
  funcionarios e,
  departamentos d,
  cargos j,
  localizacoes l,
  paises c,
  regioes r
WHERE e.id_departamento = d.id_departamento
  AND d.id_localizacao = l.id_localizacao
  AND l.id_pais = c.id_pais
  AND c.id_regiao = r.id_regiao
  AND j.id_cargo = e.id_cargo 
WITH READ ONLY;

COMMIT;

Rem
Rem $Header: hr_idx.sql 29-aug-2002.11:44:09 hyeh Exp $
Rem
Rem hr_idx.sql
Rem
Rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      hr_idx.sql - Create indexes for HR schema
Rem
Rem    DESCRIPTION
Rem
Rem
Rem    NOTES
Rem
Rem
Rem    CREATED by Nancy Greenberg - 06/01/00
Rem    MODIFIED   (MM/DD/YY)
Rem    hyeh        08/29/02 - hyeh_mv_comschema_to_rdbms
Rem    ahunold     02/20/01 - New header
Rem    vpatabal    03/02/01 - Removed DROP INDEX statements

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 

CREATE INDEX fun_department_ix
       ON funcionarios (id_departamento);

CREATE INDEX fun_job_ix
       ON funcionarios (id_cargo);

CREATE INDEX fun_manager_ix
       ON funcionarios (id_gerente);

CREATE INDEX fun_nome_ix
       ON funcionarios (ultimo_nome, primeiro_nome);

CREATE INDEX dept_loc_ix
       ON departamentos (id_localizacao);

CREATE INDEX jhist_job_ix
       ON cargo_hist (id_cargo);

CREATE INDEX jhist_fun_ix
       ON cargo_hist (id_funcionario);

CREATE INDEX jhist_department_ix
       ON cargo_hist (id_departamento);

CREATE INDEX loc_cidade_ix
       ON localizacoes (cidade);

CREATE INDEX loc_stado_province_ix	
       ON localizacoes (estado);

CREATE INDEX loc_pais_ix
       ON localizacoes (id_pais);

COMMIT;

Rem
Rem $Header: hr_code.sql 29-aug-2002.11:44:01 hyeh Exp $
Rem
Rem hr_code.sql
Rem
Rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      hr_code.sql - Create procedural objects for HR schema
Rem
Rem    DESCRIPTION
Rem      Create a statement level trigger on EMPLOYEES
Rem      to allow DML during business hours.
Rem      Create a row level trigger on the EMPLOYEES table,
Rem      after UPDATES on the department_id or job_id columns.
Rem      Create a stored procedure to insert a row into the
Rem      JOB_HISTORY table.  Have the above row level trigger
Rem      row level trigger call this stored procedure. 
Rem
Rem    NOTES
Rem
Rem    CREATED by Nancy Greenberg - 06/01/00
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hyeh        08/29/02 - hyeh_mv_comschema_to_rdbms
Rem    ahunold     05/11/01 - disable
Rem    ahunold     03/03/01 - HR simplification, REGIONS table
Rem    ahunold     02/20/01 - Created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF

REM **************************************************************************

REM procedure and statement trigger to allow dmls during business hours:
CREATE OR REPLACE PROCEDURE secure_dml
IS
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE_APPLICATION_ERROR (-20205, 
		'You may only make changes during normal office hours');
  END IF;
END secure_dml;
/

CREATE OR REPLACE TRIGGER secure_funcionarios
  BEFORE INSERT OR UPDATE OR DELETE ON funcionarios
BEGIN
  secure_dml;
END secure_funcionarios;
/

ALTER TRIGGER secure_funcionarios DISABLE;

REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:

CREATE OR REPLACE PROCEDURE add_cargo_hist
  (  p_id_funcionario          cargo_hist.id_funcionario%type
   , p_dt_inicio      cargo_hist.dt_inicio%type
   , p_dt_fim        cargo_hist.dt_fim%type
   , p_id_cargo          cargo_hist.id_cargo%type
   , p_id_departamento   cargo_hist.id_departamento%type 
   )
IS
BEGIN
  INSERT INTO cargo_hist (id_funcionario, dt_inicio, dt_fim, 
                           id_cargo, id_departamento)
    VALUES(p_id_funcionario, p_dt_inicio, p_dt_fim, p_id_cargo, p_id_departamento);
END add_cargo_hist;
/

CREATE OR REPLACE TRIGGER update_cargo_hist
  AFTER UPDATE OF id_cargo, id_departamento ON funcionarios
  FOR EACH ROW
BEGIN
  add_cargo_hist(:old.id_funcionario, :old.dt_admissao, sysdate, 
                  :old.id_cargo, :old.id_departamento);
END;
/

COMMIT;

rem
rem Header: hr_popul.sql 09-jan-01
rem
rem Copyright (c) 2001, 2008, Oracle. All rights reserved.
rem
rem Owner  : ahunold
rem
rem NAME
rem   hr_popul.sql - Populate script for HR schema
rem
rem DESCRIPTON
rem
rem
rem NOTES
rem   There is a circular foreign key reference between 
rem   EMPLOYESS and departamentos. That's why we disable '
rem   the FK constraints here
rem
rem CREATED
rem   Nancy Greenberg, Nagavalli Pataballa - 06/01/00
rem
rem MODIFIED   (MM/DD/YY)
rem   celsbern  08/07/08 - fixing date strings to use all numbers, no month
rem                        names
rem   cbauwens  02/13/08 - funcionarios.hire_date rolled forward 8 years
rem                        cargo_hist start_date end_date rolled forward 8 years
rem   hyeh      08/29/02 - hyeh_mv_comschema_to_rdbms
rem   ahunold   03/07/01 - small data errors corrected
rem                      - Modified region values of paises table
rem                      - Replaced ID sequence values for funcionarios
rem                        and departamentos tables with numbers
rem                      - Moved create sequence statements to hr_cre
rem                      - Removed dn values for funcionarios and
rem                        departamentos tables
rem                      - Removed currency columns values from
rem                        paises table
rem   ngreenbe           - Updated employee 178 for no department
rem   pnathan            - Insert new rows to cargo_hist table
rem   ahunold   02/20/01 - NLS_LANGUAGE, replacing non American
rem   ahunold   01/09/01 - checkin ADE

SET VERIFY OFF
ALTER SESSION SET NLS_LANGUAGE=American; 

REM ***************************insert data into the regioes table

Prompt ******  Populating regioes table ....

INSERT INTO regioes VALUES 
        ( 1
        , 'Europe' 
        );

INSERT INTO regioes VALUES 
        ( 2
        , 'Americas' 
        );

INSERT INTO regioes VALUES 
        ( 3
        , 'Asia' 
        );

INSERT INTO regioes VALUES 
        ( 4
        , 'Middle East and Africa' 
        );

REM ***************************insert data into the paises table

Prompt ******  Populating COUNTIRES table ....

INSERT INTO paises VALUES 
        ( 'IT'
        , 'Italy'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'JP'
        , 'Japan'
	, 3 
        );

INSERT INTO paises VALUES 
        ( 'US'
        , 'United States of America'
        , 2 
        );

INSERT INTO paises VALUES 
        ( 'CA'
        , 'Canada'
        , 2 
        );

INSERT INTO paises VALUES 
        ( 'CN'
        , 'China'
        , 3 
        );

INSERT INTO paises VALUES 
        ( 'IN'
        , 'India'
        , 3 
        );

INSERT INTO paises VALUES 
        ( 'AU'
        , 'Australia'
        , 3 
        );

INSERT INTO paises VALUES 
        ( 'ZW'
        , 'Zimbabwe'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'SG'
        , 'Singapore'
        , 3 
        );

INSERT INTO paises VALUES 
        ( 'UK'
        , 'United Kingdom'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'FR'
        , 'France'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'DE'
        , 'Germany'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'ZM'
        , 'Zambia'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'EG'
        , 'Egypt'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'BR'
        , 'Brazil'
        , 2 
        );

INSERT INTO paises VALUES 
        ( 'CH'
        , 'Switzerland'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'NL'
        , 'Netherlands'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'MX'
        , 'Mexico'
        , 2 
        );

INSERT INTO paises VALUES 
        ( 'KW'
        , 'Kuwait'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'IL'
        , 'Israel'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'DK'
        , 'Denmark'
        , 1 
        );

INSERT INTO paises VALUES 
        ( 'ML'
        , 'Malaysia'
        , 3 
        );

INSERT INTO paises VALUES 
        ( 'NG'
        , 'Nigeria'
        , 4 
        );

INSERT INTO paises VALUES 
        ( 'AR'
        , 'Argentina'
        , 2 
        );

INSERT INTO paises VALUES 
        ( 'BE'
        , 'Belgium'
        , 1 
        );


REM ***************************insert data into the localizacoes table

Prompt ******  Populating localizacoes table ....

INSERT INTO localizacoes VALUES 
        ( 1000 
        , '1297 Via Cola di Rie'
        , '00989'
        , 'Roma'
        , NULL
        , 'IT'
        );

INSERT INTO localizacoes VALUES 
        ( 1100 
        , '93091 Calle della Testa'
        , '10934'
        , 'Venice'
        , NULL
        , 'IT'
        );

INSERT INTO localizacoes VALUES 
        ( 1200 
        , '2017 Shinjuku-ku'
        , '1689'
        , 'Tokyo'
        , 'Tokyo Prefecture'
        , 'JP'
        );

INSERT INTO localizacoes VALUES 
        ( 1300 
        , '9450 Kamiya-cho'
        , '6823'
        , 'Hiroshima'
        , NULL
        , 'JP'
        );

INSERT INTO localizacoes VALUES 
        ( 1400 
        , '2014 Jabberwocky Rd'
        , '26192'
        , 'Southlake'
        , 'Texas'
        , 'US'
        );

INSERT INTO localizacoes VALUES 
        ( 1500 
        , '2011 Interiors Blvd'
        , '99236'
        , 'South San Francisco'
        , 'California'
        , 'US'
        );

INSERT INTO localizacoes VALUES 
        ( 1600 
        , '2007 Zagora St'
        , '50090'
        , 'South Brunswick'
        , 'New Jersey'
        , 'US'
        );

INSERT INTO localizacoes VALUES 
        ( 1700 
        , '2004 Charade Rd'
        , '98199'
        , 'Seattle'
        , 'Washington'
        , 'US'
        );

INSERT INTO localizacoes VALUES 
        ( 1800 
        , '147 Spadina Ave'
        , 'M5V 2L7'
        , 'Toronto'
        , 'Ontario'
        , 'CA'
        );

INSERT INTO localizacoes VALUES 
        ( 1900 
        , '6092 Boxwood St'
        , 'YSW 9T2'
        , 'Whitehorse'
        , 'Yukon'
        , 'CA'
        );

INSERT INTO localizacoes VALUES 
        ( 2000 
        , '40-5-12 Laogianggen'
        , '190518'
        , 'Beijing'
        , NULL
        , 'CN'
        );

INSERT INTO localizacoes VALUES 
        ( 2100 
        , '1298 Vileparle (E)'
        , '490231'
        , 'Bombay'
        , 'Maharashtra'
        , 'IN'
        );

INSERT INTO localizacoes VALUES 
        ( 2200 
        , '12-98 Victoria Street'
        , '2901'
        , 'Sydney'
        , 'New South Wales'
        , 'AU'
        );

INSERT INTO localizacoes VALUES 
        ( 2300 
        , '198 Clementi North'
        , '540198'
        , 'Singapore'
        , NULL
        , 'SG'
        );

INSERT INTO localizacoes VALUES 
        ( 2400 
        , '8204 Arthur St'
        , NULL
        , 'London'
        , NULL
        , 'UK'
        );

INSERT INTO localizacoes VALUES 
        ( 2500 
        , 'Magdalen Centre, The Oxford Science Park'
        , 'OX9 9ZB'
        , 'Oxford'
        , 'Oxford'
        , 'UK'
        );

INSERT INTO localizacoes VALUES 
        ( 2600 
        , '9702 Chester Road'
        , '09629850293'
        , 'Stretford'
        , 'Manchester'
        , 'UK'
        );

INSERT INTO localizacoes VALUES 
        ( 2700 
        , 'Schwanthalerstr. 7031'
        , '80925'
        , 'Munich'
        , 'Bavaria'
        , 'DE'
        );

INSERT INTO localizacoes VALUES 
        ( 2800 
        , 'Rua Frei Caneca 1360 '
        , '01307-002'
        , 'Sao Paulo'
        , 'Sao Paulo'
        , 'BR'
        );

INSERT INTO localizacoes VALUES 
        ( 2900 
        , '20 Rue des Corps-Saints'
        , '1730'
        , 'Geneva'
        , 'Geneve'
        , 'CH'
        );

INSERT INTO localizacoes VALUES 
        ( 3000 
        , 'Murtenstrasse 921'
        , '3095'
        , 'Bern'
        , 'BE'
        , 'CH'
        );

INSERT INTO localizacoes VALUES 
        ( 3100 
        , 'Pieter Breughelstraat 837'
        , '3029SK'
        , 'Utrecht'
        , 'Utrecht'
        , 'NL'
        );

INSERT INTO localizacoes VALUES 
        ( 3200 
        , 'Mariano Escobedo 9991'
        , '11932'
        , 'Mexico City'
        , 'Distrito Federal,'
        , 'MX'
        );


REM ****************************insert data into the departamentos table

Prompt ******  Populating departamentos table ....

REM disable integrity constraint to funcionarios to load data

ALTER TABLE departamentos 
  DISABLE CONSTRAINT dept_mgr_fk;

INSERT INTO departamentos VALUES 
        ( 10
        , 'Administration'
        , 200
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 20
        , 'Marketing'
        , 201
        , 1800
        );
                                
INSERT INTO departamentos VALUES 
        ( 30
        , 'Purchasing'
        , 114
        , 1700
	);
                
INSERT INTO departamentos VALUES 
        ( 40
        , 'Human Resources'
        , 203
        , 2400
        );

INSERT INTO departamentos VALUES 
        ( 50
        , 'Shipping'
        , 121
        , 1500
        );
                
INSERT INTO departamentos VALUES 
        ( 60 
        , 'IT'
        , 103
        , 1400
        );
                
INSERT INTO departamentos VALUES 
        ( 70 
        , 'Public Relations'
        , 204
        , 2700
        );
                
INSERT INTO departamentos VALUES 
        ( 80 
        , 'Sales'
        , 145
        , 2500
        );
                
INSERT INTO departamentos VALUES 
        ( 90 
        , 'Executive'
        , 100
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 100 
        , 'Finance'
        , 108
        , 1700
        );
                
INSERT INTO departamentos VALUES 
        ( 110 
        , 'Accounting'
        , 205
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 120 
        , 'Treasury'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 130 
        , 'Corporate Tax'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 140 
        , 'Control And Credit'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 150 
        , 'Shareholder Services'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 160 
        , 'Benefits'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 170 
        , 'Manufacturing'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 180 
        , 'Construction'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 190 
        , 'Contracting'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 200 
        , 'Operations'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 210 
        , 'IT Support'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 220 
        , 'NOC'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 230 
        , 'IT Helpdesk'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 240 
        , 'Government Sales'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 250 
        , 'Retail Sales'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 260 
        , 'Recruiting'
        , NULL
        , 1700
        );

INSERT INTO departamentos VALUES 
        ( 270 
        , 'Payroll'
        , NULL
        , 1700
        );


REM ***************************insert data into the cargos table

Prompt ******  Populating cargos table ....

INSERT INTO cargos VALUES 
        ( 'AD_PRES'
        , 'President'
        , 20080
        , 40000
        );
INSERT INTO cargos VALUES 
        ( 'AD_VP'
        , 'Administration Vice President'
        , 15000
        , 30000
        );

INSERT INTO cargos VALUES 
        ( 'AD_ASST'
        , 'Administration Assistant'
        , 3000
        , 6000
        );

INSERT INTO cargos VALUES 
        ( 'FI_MGR'
        , 'Finance Manager'
        , 8200
        , 16000
        );

INSERT INTO cargos VALUES 
        ( 'FI_ACCOUNT'
        , 'Accountant'
        , 4200
        , 9000
        );

INSERT INTO cargos VALUES 
        ( 'AC_MGR'
        , 'Accounting Manager'
        , 8200
        , 16000
        );

INSERT INTO cargos VALUES 
        ( 'AC_ACCOUNT'
        , 'Public Accountant'
        , 4200
        , 9000
        );
INSERT INTO cargos VALUES 
        ( 'SA_MAN'
        , 'Sales Manager'
        , 10000
        , 20080
        );

INSERT INTO cargos VALUES 
        ( 'SA_REP'
        , 'Sales Representative'
        , 6000
        , 12008
        );

INSERT INTO cargos VALUES 
        ( 'PU_MAN'
        , 'Purchasing Manager'
        , 8000
        , 15000
        );

INSERT INTO cargos VALUES 
        ( 'PU_CLERK'
        , 'Purchasing Clerk'
        , 2500
        , 5500
        );

INSERT INTO cargos VALUES 
        ( 'ST_MAN'
        , 'Stock Manager'
        , 5500
        , 8500
        );
INSERT INTO cargos VALUES 
        ( 'ST_CLERK'
        , 'Stock Clerk'
        , 2008
        , 5000
        );

INSERT INTO cargos VALUES 
        ( 'SH_CLERK'
        , 'Shipping Clerk'
        , 2500
        , 5500
        );

INSERT INTO cargos VALUES 
        ( 'IT_PROG'
        , 'Programmer'
        , 4000
        , 10000
        );

INSERT INTO cargos VALUES 
        ( 'MK_MAN'
        , 'Marketing Manager'
        , 9000
        , 15000
        );

INSERT INTO cargos VALUES 
        ( 'MK_REP'
        , 'Marketing Representative'
        , 4000
        , 9000
        );

INSERT INTO cargos VALUES 
        ( 'HR_REP'
        , 'Human Resources Representative'
        , 4000
        , 9000
        );

INSERT INTO cargos VALUES 
        ( 'PR_REP'
        , 'Public Relations Representative'
        , 4500
        , 10500
        );


REM ***************************insert data into the funcionarios table

Prompt ******  Populating funcionarios table ....

INSERT INTO funcionarios VALUES 
        ( 100
        , 'Steven'
        , 'King'
        , 'SKING'
        , '515.123.4567'
        , TO_DATE('17-06-2003', 'dd-MM-yyyy')
        , 'AD_PRES'
        , 24000
        , NULL
        , NULL
        , 90
        );

INSERT INTO funcionarios VALUES 
        ( 101
        , 'Neena'
        , 'Kochhar'
        , 'NKOCHHAR'
        , '515.123.4568'
        , TO_DATE('21-09-2005', 'dd-MM-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO funcionarios VALUES 
        ( 102
        , 'Lex'
        , 'De Haan'
        , 'LDEHAAN'
        , '515.123.4569'
        , TO_DATE('13-01-2001', 'dd-MM-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO funcionarios VALUES 
        ( 103
        , 'Alexander'
        , 'Hunold'
        , 'AHUNOLD'
        , '590.423.4567'
        , TO_DATE('03-01-2006', 'dd-MM-yyyy')
        , 'IT_PROG'
        , 9000
        , NULL
        , 102
        , 60
        );

INSERT INTO funcionarios VALUES 
        ( 104
        , 'Bruce'
        , 'Ernst'
        , 'BERNST'
        , '590.423.4568'
        , TO_DATE('21-05-2007', 'dd-MM-yyyy')
        , 'IT_PROG'
        , 6000
        , NULL
        , 103
        , 60
        );

INSERT INTO funcionarios VALUES 
        ( 105
        , 'David'
        , 'Austin'
        , 'DAUSTIN'
        , '590.423.4569'
        , TO_DATE('25-06-2005', 'dd-MM-yyyy')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO funcionarios VALUES 
        ( 106
        , 'Valli'
        , 'Pataballa'
        , 'VPATABAL'
        , '590.423.4560'
        , TO_DATE('05-02-2006', 'dd-MM-yyyy')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO funcionarios VALUES 
        ( 107
        , 'Diana'
        , 'Lorentz'
        , 'DLORENTZ'
        , '590.423.5567'
        , TO_DATE('07-02-2007', 'dd-MM-yyyy')
        , 'IT_PROG'
        , 4200
        , NULL
        , 103
        , 60
        );

INSERT INTO funcionarios VALUES 
        ( 108
        , 'Nancy'
        , 'Greenberg'
        , 'NGREENBE'
        , '515.124.4569'
        , TO_DATE('17-08-2002', 'dd-MM-yyyy')
        , 'FI_MGR'
        , 12008
        , NULL
        , 101
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 109
        , 'Daniel'
        , 'Faviet'
        , 'DFAVIET'
        , '515.124.4169'
        , TO_DATE('16-08-2002', 'dd-MM-yyyy')
        , 'FI_ACCOUNT'
        , 9000
        , NULL
        , 108
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 110
        , 'John'
        , 'Chen'
        , 'JCHEN'
        , '515.124.4269'
        , TO_DATE('28-09-2005', 'dd-MM-yyyy')
        , 'FI_ACCOUNT'
        , 8200
        , NULL
        , 108
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 111
        , 'Ismael'
        , 'Sciarra'
        , 'ISCIARRA'
        , '515.124.4369'
        , TO_DATE('30-09-2005', 'dd-MM-yyyy')
        , 'FI_ACCOUNT'
        , 7700
        , NULL
        , 108
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 112
        , 'Jose Manuel'
        , 'Urman'
        , 'JMURMAN'
        , '515.124.4469'
        , TO_DATE('07-03-2006', 'dd-MM-yyyy')
        , 'FI_ACCOUNT'
        , 7800
        , NULL
        , 108
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 113
        , 'Luis'
        , 'Popp'
        , 'LPOPP'
        , '515.124.4567'
        , TO_DATE('07-12-2007', 'dd-MM-yyyy')
        , 'FI_ACCOUNT'
        , 6900
        , NULL
        , 108
        , 100
        );

INSERT INTO funcionarios VALUES 
        ( 114
        , 'Den'
        , 'Raphaely'
        , 'DRAPHEAL'
        , '515.127.4561'
        , TO_DATE('07-12-2002', 'dd-MM-yyyy')
        , 'PU_MAN'
        , 11000
        , NULL
        , 100
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 115
        , 'Alexander'
        , 'Khoo'
        , 'AKHOO'
        , '515.127.4562'
        , TO_DATE('18-05-2003', 'dd-MM-yyyy')
        , 'PU_CLERK'
        , 3100
        , NULL
        , 114
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 116
        , 'Shelli'
        , 'Baida'
        , 'SBAIDA'
        , '515.127.4563'
        , TO_DATE('24-12-2005', 'dd-MM-yyyy')
        , 'PU_CLERK'
        , 2900
        , NULL
        , 114
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 117
        , 'Sigal'
        , 'Tobias'
        , 'STOBIAS'
        , '515.127.4564'
        , TO_DATE('24-07-2005', 'dd-MM-yyyy')
        , 'PU_CLERK'
        , 2800
        , NULL
        , 114
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 118
        , 'Guy'
        , 'Himuro'
        , 'GHIMURO'
        , '515.127.4565'
        , TO_DATE('15-11-2006', 'dd-MM-yyyy')
        , 'PU_CLERK'
        , 2600
        , NULL
        , 114
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 119
        , 'Karen'
        , 'Colmenares'
        , 'KCOLMENA'
        , '515.127.4566'
        , TO_DATE('10-08-2007', 'dd-MM-yyyy')
        , 'PU_CLERK'
        , 2500
        , NULL
        , 114
        , 30
        );

INSERT INTO funcionarios VALUES 
        ( 120
        , 'Matthew'
        , 'Weiss'
        , 'MWEISS'
        , '650.123.1234'
        , TO_DATE('18-07-2004', 'dd-MM-yyyy')
        , 'ST_MAN'
        , 8000
        , NULL
        , 100
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 121
        , 'Adam'
        , 'Fripp'
        , 'AFRIPP'
        , '650.123.2234'
        , TO_DATE('10-04-2005', 'dd-MM-yyyy')
        , 'ST_MAN'
        , 8200
        , NULL
        , 100
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 122
        , 'Payam'
        , 'Kaufling'
        , 'PKAUFLIN'
        , '650.123.3234'
        , TO_DATE('01-05-2003', 'dd-MM-yyyy')
        , 'ST_MAN'
        , 7900
        , NULL
        , 100
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 123
        , 'Shanta'
        , 'Vollman'
        , 'SVOLLMAN'
        , '650.123.4234'
        , TO_DATE('10-10-2005', 'dd-MM-yyyy')
        , 'ST_MAN'
        , 6500
        , NULL
        , 100
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 124
        , 'Kevin'
        , 'Mourgos'
        , 'KMOURGOS'
        , '650.123.5234'
        , TO_DATE('16-11-2007', 'dd-MM-yyyy')
        , 'ST_MAN'
        , 5800
        , NULL
        , 100
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 125
        , 'Julia'
        , 'Nayer'
        , 'JNAYER'
        , '650.124.1214'
        , TO_DATE('16-07-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 126
        , 'Irene'
        , 'Mikkilineni'
        , 'IMIKKILI'
        , '650.124.1224'
        , TO_DATE('28-09-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 127
        , 'James'
        , 'Landry'
        , 'JLANDRY'
        , '650.124.1334'
        , TO_DATE('14-01-2007', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 128
        , 'Steven'
        , 'Markle'
        , 'SMARKLE'
        , '650.124.1434'
        , TO_DATE('08-03-2008', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 129
        , 'Laura'
        , 'Bissot'
        , 'LBISSOT'
        , '650.124.5234'
        , TO_DATE('20-08-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 130
        , 'Mozhe'
        , 'Atkinson'
        , 'MATKINSO'
        , '650.124.6234'
        , TO_DATE('30-10-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2800
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 131
        , 'James'
        , 'Marlow'
        , 'JAMRLOW'
        , '650.124.7234'
        , TO_DATE('16-02-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 132
        , 'TJ'
        , 'Olson'
        , 'TJOLSON'
        , '650.124.8234'
        , TO_DATE('10-04-2007', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2100
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 133
        , 'Jason'
        , 'Mallin'
        , 'JMALLIN'
        , '650.127.1934'
        , TO_DATE('14-06-2004', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 134
        , 'Michael'
        , 'Rogers'
        , 'MROGERS'
        , '650.127.1834'
        , TO_DATE('26-08-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 135
        , 'Ki'
        , 'Gee'
        , 'KGEE'
        , '650.127.1734'
        , TO_DATE('12-12-2007', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 136
        , 'Hazel'
        , 'Philtanker'
        , 'HPHILTAN'
        , '650.127.1634'
        , TO_DATE('06-02-2008', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 137
        , 'Renske'
        , 'Ladwig'
        , 'RLADWIG'
        , '650.121.1234'
        , TO_DATE('14-07-2003', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3600
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 138
        , 'Stephen'
        , 'Stiles'
        , 'SSTILES'
        , '650.121.2034'
        , TO_DATE('26-10-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 139
        , 'John'
        , 'Seo'
        , 'JSEO'
        , '650.121.2019'
        , TO_DATE('12-02-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 140
        , 'Joshua'
        , 'Patel'
        , 'JPATEL'
        , '650.121.1834'
        , TO_DATE('06-04-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 141
        , 'Trenna'
        , 'Rajs'
        , 'TRAJS'
        , '650.121.8009'
        , TO_DATE('17-10-2003', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3500
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 142
        , 'Curtis'
        , 'Davies'
        , 'CDAVIES'
        , '650.121.2994'
        , TO_DATE('29-01-2005', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 143
        , 'Randall'
        , 'Matos'
        , 'RMATOS'
        , '650.121.2874'
        , TO_DATE('15-03-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 144
        , 'Peter'
        , 'Vargas'
        , 'PVARGAS'
        , '650.121.2004'
        , TO_DATE('09-07-2006', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 145
        , 'John'
        , 'Russell'
        , 'JRUSSEL'
        , '011.44.1344.429268'
        , TO_DATE('01-10-2004', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 14000
        , .4
        , 100
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 146
        , 'Karen'
        , 'Partners'
        , 'KPARTNER'
        , '011.44.1344.467268'
        , TO_DATE('05-01-2005', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 13500
        , .3
        , 100
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 147
        , 'Alberto'
        , 'Errazuriz'
        , 'AERRAZUR'
        , '011.44.1344.429278'
        , TO_DATE('10-03-2005', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 12000
        , .3
        , 100
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 148
        , 'Gerald'
        , 'Cambrault'
        , 'GCAMBRAU'
        , '011.44.1344.619268'
        , TO_DATE('15-10-2007', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 11000
        , .3
        , 100
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 149
        , 'Eleni'
        , 'Zlotkey'
        , 'EZLOTKEY'
        , '011.44.1344.429018'
        , TO_DATE('29-01-2008', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 10500
        , .2
        , 100
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 150
        , 'Peter'
        , 'Tucker'
        , 'PTUCKER'
        , '011.44.1344.129268'
        , TO_DATE('30-01-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 10000
        , .3
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 151
        , 'David'
        , 'Bernstein'
        , 'DBERNSTE'
        , '011.44.1344.345268'
        , TO_DATE('24-03-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9500
        , .25
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 152
        , 'Peter'
        , 'Hall'
        , 'PHALL'
        , '011.44.1344.478968'
        , TO_DATE('20-08-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9000
        , .25
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 153
        , 'Christopher'
        , 'Olsen'
        , 'COLSEN'
        , '011.44.1344.498718'
        , TO_DATE('30-03-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 8000
        , .2
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 154
        , 'Nanette'
        , 'Cambrault'
        , 'NCAMBRAU'
        , '011.44.1344.987668'
        , TO_DATE('09-12-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7500
        , .2
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 155
        , 'Oliver'
        , 'Tuvault'
        , 'OTUVAULT'
        , '011.44.1344.486508'
        , TO_DATE('23-11-2007', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7000
        , .15
        , 145
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 156
        , 'Janette'
        , 'King'
        , 'JKING'
        , '011.44.1345.429268'
        , TO_DATE('30-01-2004', 'dd-MM-yyyy')
        , 'SA_REP'
        , 10000
        , .35
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 157
        , 'Patrick'
        , 'Sully'
        , 'PSULLY'
        , '011.44.1345.929268'
        , TO_DATE('04-03-2004', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9500
        , .35
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 158
        , 'Allan'
        , 'McEwen'
        , 'AMCEWEN'
        , '011.44.1345.829268'
        , TO_DATE('01-08-2004', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9000
        , .35
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 159
        , 'Lindsey'
        , 'Smith'
        , 'LSMITH'
        , '011.44.1345.729268'
        , TO_DATE('10-03-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 8000
        , .3
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 160
        , 'Louise'
        , 'Doran'
        , 'LDORAN'
        , '011.44.1345.629268'
        , TO_DATE('15-12-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7500
        , .3
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 161
        , 'Sarath'
        , 'Sewall'
        , 'SSEWALL'
        , '011.44.1345.529268'
        , TO_DATE('03-11-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7000
        , .25
        , 146
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 162
        , 'Clara'
        , 'Vishney'
        , 'CVISHNEY'
        , '011.44.1346.129268'
        , TO_DATE('11-11-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 10500
        , .25
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 163
        , 'Danielle'
        , 'Greene'
        , 'DGREENE'
        , '011.44.1346.229268'
        , TO_DATE('19-03-2007', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9500
        , .15
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 164
        , 'Mattea'
        , 'Marvins'
        , 'MMARVINS'
        , '011.44.1346.329268'
        , TO_DATE('24-01-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7200
        , .10
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 165
        , 'David'
        , 'Lee'
        , 'DLEE'
        , '011.44.1346.529268'
        , TO_DATE('23-02-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 6800
        , .1
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 166
        , 'Sundar'
        , 'Ande'
        , 'SANDE'
        , '011.44.1346.629268'
        , TO_DATE('24-03-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 6400
        , .10
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 167
        , 'Amit'
        , 'Banda'
        , 'ABANDA'
        , '011.44.1346.729268'
        , TO_DATE('21-04-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 6200
        , .10
        , 147
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 168
        , 'Lisa'
        , 'Ozer'
        , 'LOZER'
        , '011.44.1343.929268'
        , TO_DATE('11-03-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 11500
        , .25
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 169  
        , 'Harrison'
        , 'Bloom'
        , 'HBLOOM'
        , '011.44.1343.829268'
        , TO_DATE('23-03-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 10000
        , .20
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 170
        , 'Tayler'
        , 'Fox'
        , 'TFOX'
        , '011.44.1343.729268'
        , TO_DATE('24-01-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 9600
        , .20
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 171
        , 'William'
        , 'Smith'
        , 'WSMITH'
        , '011.44.1343.629268'
        , TO_DATE('23-02-2007', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7400
        , .15
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 172
        , 'Elizabeth'
        , 'Bates'
        , 'EBATES'
        , '011.44.1343.529268'
        , TO_DATE('24-03-2007', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7300
        , .15
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 173
        , 'Sundita'
        , 'Kumar'
        , 'SKUMAR'
        , '011.44.1343.329268'
        , TO_DATE('21-04-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 6100
        , .10
        , 148
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 174
        , 'Ellen'
        , 'Abel'
        , 'EABEL'
        , '011.44.1644.429267'
        , TO_DATE('11-05-2004', 'dd-MM-yyyy')
        , 'SA_REP'
        , 11000
        , .30
        , 149
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 175
        , 'Alyssa'
        , 'Hutton'
        , 'AHUTTON'
        , '011.44.1644.429266'
        , TO_DATE('19-03-2005', 'dd-MM-yyyy')
        , 'SA_REP'
        , 8800
        , .25
        , 149
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 176
        , 'Jonathon'
        , 'Taylor'
        , 'JTAYLOR'
        , '011.44.1644.429265'
        , TO_DATE('24-03-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 8600
        , .20
        , 149
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 177
        , 'Jack'
        , 'Livingston'
        , 'JLIVINGS'
        , '011.44.1644.429264'
        , TO_DATE('23-04-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 8400
        , .20
        , 149
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 178
        , 'Kimberely'
        , 'Grant'
        , 'KGRANT'
        , '011.44.1644.429263'
        , TO_DATE('24-05-2007', 'dd-MM-yyyy')
        , 'SA_REP'
        , 7000
        , .15
        , 149
        , NULL
        );

INSERT INTO funcionarios VALUES 
        ( 179
        , 'Charles'
        , 'Johnson'
        , 'CJOHNSON'
        , '011.44.1644.429262'
        , TO_DATE('04-01-2008', 'dd-MM-yyyy')
        , 'SA_REP'
        , 6200
        , .10
        , 149
        , 80
        );

INSERT INTO funcionarios VALUES 
        ( 180
        , 'Winston'
        , 'Taylor'
        , 'WTAYLOR'
        , '650.507.9876'
        , TO_DATE('24-01-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 181
        , 'Jean'
        , 'Fleaur'
        , 'JFLEAUR'
        , '650.507.9877'
        , TO_DATE('23-02-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 182
        , 'Martha'
        , 'Sullivan'
        , 'MSULLIVA'
        , '650.507.9878'
        , TO_DATE('21-06-2007', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 183
        , 'Girard'
        , 'Geoni'
        , 'GGEONI'
        , '650.507.9879'
        , TO_DATE('03-02-2008', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 120
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 184
        , 'Nandita'
        , 'Sarchand'
        , 'NSARCHAN'
        , '650.509.1876'
        , TO_DATE('27-01-2004', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 4200
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 185
        , 'Alexis'
        , 'Bull'
        , 'ABULL'
        , '650.509.2876'
        , TO_DATE('20-02-2005', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 4100
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 186
        , 'Julia'
        , 'Dellinger'
        , 'JDELLING'
        , '650.509.3876'
        , TO_DATE('24-06-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3400
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 187
        , 'Anthony'
        , 'Cabrio'
        , 'ACABRIO'
        , '650.509.4876'
        , TO_DATE('07-02-2007', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 121
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 188
        , 'Kelly'
        , 'Chung'
        , 'KCHUNG'
        , '650.505.1876'
        , TO_DATE('14-06-2005', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3800
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 189
        , 'Jennifer'
        , 'Dilly'
        , 'JDILLY'
        , '650.505.2876'
        , TO_DATE('13-08-2005', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3600
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 190
        , 'Timothy'
        , 'Gates'
        , 'TGATES'
        , '650.505.3876'
        , TO_DATE('11-07-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 191
        , 'Randall'
        , 'Perkins'
        , 'RPERKINS'
        , '650.505.4876'
        , TO_DATE('19-12-2007', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 122
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 192
        , 'Sarah'
        , 'Bell'
        , 'SBELL'
        , '650.501.1876'
        , TO_DATE('04-02-2004', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 4000
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 193
        , 'Britney'
        , 'Everett'
        , 'BEVERETT'
        , '650.501.2876'
        , TO_DATE('03-03-2005', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3900
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 194
        , 'Samuel'
        , 'McCain'
        , 'SMCCAIN'
        , '650.501.3876'
        , TO_DATE('01-07-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 195
        , 'Vance'
        , 'Jones'
        , 'VJONES'
        , '650.501.4876'
        , TO_DATE('17-03-2007', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 123
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 196
        , 'Alana'
        , 'Walsh'
        , 'AWALSH'
        , '650.507.9811'
        , TO_DATE('24-04-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 197
        , 'Kevin'
        , 'Feeney'
        , 'KFEENEY'
        , '650.507.9822'
        , TO_DATE('23-05-2006', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 198
        , 'Donald'
        , 'OConnell'
        , 'DOCONNEL'
        , '650.507.9833'
        , TO_DATE('21-06-2007', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 199
        , 'Douglas'
        , 'Grant'
        , 'DGRANT'
        , '650.507.9844'
        , TO_DATE('13-01-2008', 'dd-MM-yyyy')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO funcionarios VALUES 
        ( 200
        , 'Jennifer'
        , 'Whalen'
        , 'JWHALEN'
        , '515.123.4444'
        , TO_DATE('17-09-2003', 'dd-MM-yyyy')
        , 'AD_ASST'
        , 4400
        , NULL
        , 101
        , 10
        );

INSERT INTO funcionarios VALUES 
        ( 201
        , 'Michael'
        , 'Hartstein'
        , 'MHARTSTE'
        , '515.123.5555'
        , TO_DATE('17-02-2004', 'dd-MM-yyyy')
        , 'MK_MAN'
        , 13000
        , NULL
        , 100
        , 20
        );

INSERT INTO funcionarios VALUES 
        ( 202
        , 'Pat'
        , 'Fay'
        , 'PFAY'
        , '603.123.6666'
        , TO_DATE('17-08-2005', 'dd-MM-yyyy')
        , 'MK_REP'
        , 6000
        , NULL
        , 201
        , 20
        );

INSERT INTO funcionarios VALUES 
        ( 203
        , 'Susan'
        , 'Mavris'
        , 'SMAVRIS'
        , '515.123.7777'
        , TO_DATE('07-06-2002', 'dd-MM-yyyy')
        , 'HR_REP'
        , 6500
        , NULL
        , 101
        , 40
        );

INSERT INTO funcionarios VALUES 
        ( 204
        , 'Hermann'
        , 'Baer'
        , 'HBAER'
        , '515.123.8888'
        , TO_DATE('07-06-2002', 'dd-MM-yyyy')
        , 'PR_REP'
        , 10000
        , NULL
        , 101
        , 70
        );

INSERT INTO funcionarios VALUES 
        ( 205
        , 'Shelley'
        , 'Higgins'
        , 'SHIGGINS'
        , '515.123.8080'
        , TO_DATE('07-06-2002', 'dd-MM-yyyy')
        , 'AC_MGR'
        , 12008
        , NULL
        , 101
        , 110
        );

INSERT INTO funcionarios VALUES 
        ( 206
        , 'William'
        , 'Gietz'
        , 'WGIETZ'
        , '515.123.8181'
        , TO_DATE('07-06-2002', 'dd-MM-yyyy')
        , 'AC_ACCOUNT'
        , 8300
        , NULL
        , 205
        , 110
        );

REM ********* insert data into the cargo_hist table

Prompt ******  Populating cargo_hist table ....


INSERT INTO cargo_hist
VALUES (102
       , TO_DATE('13-01-2001', 'dd-MM-yyyy')
       , TO_DATE('24-07-2006', 'dd-MM-yyyy')
       , 'IT_PROG'
       , 60);

INSERT INTO cargo_hist
VALUES (101
       , TO_DATE('21-09-1997', 'dd-MM-yyyy')
       , TO_DATE('27-10-2001', 'dd-MM-yyyy')
       , 'AC_ACCOUNT'
       , 110);

INSERT INTO cargo_hist
VALUES (101
       , TO_DATE('28-10-2001', 'dd-MM-yyyy')
       , TO_DATE('15-03-2005', 'dd-MM-yyyy')
       , 'AC_MGR'
       , 110);

INSERT INTO cargo_hist
VALUES (201
       , TO_DATE('17-02-2004', 'dd-MM-yyyy')
       , TO_DATE('19-12-2007', 'dd-MM-yyyy')
       , 'MK_REP'
       , 20);

INSERT INTO cargo_hist
VALUES  (114
        , TO_DATE('24-03-2006', 'dd-MM-yyyy')
        , TO_DATE('31-12-2007', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO cargo_hist
VALUES  (122
        , TO_DATE('01-01-2007', 'dd-MM-yyyy')
        , TO_DATE('31-12-2007', 'dd-MM-yyyy')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO cargo_hist
VALUES  (200
        , TO_DATE('17-09-1995', 'dd-MM-yyyy')
        , TO_DATE('17-06-2001', 'dd-MM-yyyy')
        , 'AD_ASST'
        , 90
        );

INSERT INTO cargo_hist
VALUES  (176
        , TO_DATE('24-03-2006', 'dd-MM-yyyy')
        , TO_DATE('31-12-2006', 'dd-MM-yyyy')
        , 'SA_REP'
        , 80
        );

INSERT INTO cargo_hist
VALUES  (176
        , TO_DATE('01-01-2007', 'dd-MM-yyyy')
        , TO_DATE('31-12-2007', 'dd-MM-yyyy')
        , 'SA_MAN'
        , 80
        );

INSERT INTO cargo_hist
VALUES  (200
        , TO_DATE('01-07-2002', 'dd-MM-yyyy')
        , TO_DATE('31-12-2006', 'dd-MM-yyyy')
        , 'AC_ACCOUNT'
        , 90
        );

REM enable integrity constraint to departamentos

ALTER TABLE departamentos 
  ENABLE CONSTRAINT dept_mgr_fk;

COMMIT;


