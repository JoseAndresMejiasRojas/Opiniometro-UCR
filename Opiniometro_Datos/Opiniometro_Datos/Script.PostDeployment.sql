﻿-- Borrar todas las tuplas existentes en la base de datos para evitar repeticion de llaves primarias.
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'DELETE FROM ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'

--PROCEDIMIENTOS

--The Strategists
IF OBJECT_ID('SP_AgregarUsuario') IS NOT NULL
	DROP PROCEDURE SP_AgregarUsuario
GO
CREATE PROCEDURE SP_AgregarUsuario
	@Correo			NVARCHAR(50),
	@Contrasenna	NVARCHAR(50),
	@Cedula			CHAR(9)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Id UNIQUEIDENTIFIER=NEWID()

	INSERT INTO Usuario
	VALUES (@Correo, HASHBYTES('SHA2_512', @Contrasenna+CAST(@Id AS NVARCHAR(36))), 1, @Cedula, @Id, 0)
END
GO

IF OBJECT_ID('SP_LoginUsuario') IS NOT NULL
	DROP PROCEDURE SP_LoginUsuario
GO
CREATE PROCEDURE SP_LoginUsuario
	@Correo			NVARCHAR(50),
	@Contrasenna	NVARCHAR(50),
	@Resultado		BIT OUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CorreoBuscar NVARCHAR(50)
	
	-- Buscar que el correo y la contrasenna sean correctos con lo que hay en la tabla Usuario.
	SET @CorreoBuscar =	(SELECT CorreoInstitucional 
						FROM Usuario
						WHERE CorreoInstitucional=@Correo AND Contrasena=HASHBYTES('SHA2_512', @Contrasenna+CAST(Id AS NVARCHAR(36))))

	IF(@CorreoBuscar IS NULL)	-- Si no calzan, no hay autenticacion.
		SET @Resultado = 0
	ELSE						-- Si hay autenticacion
		SET @Resultado = 1
END
GO

IF OBJECT_ID('SP_ExistenciaCorreo') IS NOT NULL
	DROP PROCEDURE SP_ExistenciaCorreo
GO
CREATE PROCEDURE SP_ExistenciaCorreo
	@Correo			NVARCHAR(50),
	@Resultado		BIT OUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CorreoBuscar NVARCHAR(50)
	
	-- Buscar que el correo sea correcto con lo que hay en la tabla Usuario.
	SET @CorreoBuscar =	(SELECT CorreoInstitucional 
						FROM Usuario
						WHERE CorreoInstitucional=@Correo)

	IF(@CorreoBuscar IS NULL)	-- Si no calzan, no hay autenticacion.
		SET @Resultado = 0
	ELSE						-- Si hay autenticacion
		SET @Resultado = 1
END
GO

IF OBJECT_ID('SP_CambiarContrasenna') IS NOT NULL
	DROP PROCEDURE SP_CambiarContrasenna
GO
CREATE PROCEDURE SP_CambiarContrasenna
	@Correo					NVARCHAR(50),
	@Contrasenna_Nueva		NVARCHAR(50),
	@RecuperarContrasenna	BIT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CorreoBuscar NVARCHAR(50)
	
	-- Buscar que el correo y la contrasenna sean correctos con lo que hay en la tabla Usuario.
	SET @CorreoBuscar =	(SELECT CorreoInstitucional 
						FROM Usuario
						WHERE CorreoInstitucional=@Correo)

	IF(@CorreoBuscar IS NOT NULL)	-- Si existe el correo
	BEGIN
		UPDATE Usuario
		SET Contrasena = HASHBYTES('SHA2_512', @Contrasenna_Nueva+CAST(Id AS NVARCHAR(36))), RecuperarContrasenna = @RecuperarContrasenna
		WHERE CorreoInstitucional = @CorreoBuscar
	END	
END
GO

-- Modificar Persona
IF OBJECT_ID('SP_ModificarPersona') IS NOT NULL
	DROP PROCEDURE SP_ModificarPersona
GO
CREATE PROCEDURE SP_ModificarPersona
	@CedulaBusqueda		VARCHAR(9),
	@Cedula				CHAR(9),
	@Nombre1			NVARCHAR(50),
	@Nombre2			NVARCHAR(50),
	@Apellido1			NVARCHAR(50),
	@Apellido2			NVARCHAR(50),
	@Correo				NVARCHAR(50)
AS
BEGIN
	UPDATE Persona
	SET Cedula = @Cedula, Nombre1 = @Nombre1, Nombre2 = @Nombre2, Apellido1 = @Apellido1, Apellido2 = @Apellido2
	WHERE Cedula = @CedulaBusqueda;

	UPDATE Usuario
	SET CorreoInstitucional = @Correo
	WHERE Cedula = @Cedula;
END
GO


IF OBJECT_ID('SP_ObtenerPermisosUsuario') IS NOT NULL
	DROP PROCEDURE SP_ObtenerPermisosUsuario
GO
CREATE PROCEDURE SP_ObtenerPermisosUsuario
	@Correo		NVARCHAR(50),
	@Perfil		VARCHAR(30)
AS
	SELECT TU.SiglaCarrera, PE.NumeroEnfasis, PE.IdPermiso
	FROM Tiene_Usuario_Perfil_Enfasis TU	JOIN Perfil ON TU.NombrePerfil = Perfil.Nombre
											JOIN Posee_Enfasis_Perfil_Permiso PE ON Perfil.Nombre = PE.NombrePerfil
	WHERE TU.CorreoInstitucional=@Correo AND TU.NombrePerfil = @Perfil
GO

IF OBJECT_ID('SP_ObtenerNombre') IS NOT NULL
	DROP PROCEDURE SP_ObtenerNombre
GO
CREATE PROCEDURE SP_ObtenerNombre
	@Correo			NVARCHAR(50),
	@Nombre			NVARCHAR(50) OUT,
	@Apellido		NVARCHAR(50) OUT
AS
BEGIN
	SET NOCOUNT ON
	
	SET @Nombre = (SELECT Nombre1
	FROM Usuario U	JOIN Persona P ON U.Cedula = p.Cedula
	WHERE U.CorreoInstitucional=@Correo)

	SET @Apellido = (SELECT Apellido1
	FROM Usuario U	JOIN Persona P ON U.Cedula = p.Cedula
	WHERE U.CorreoInstitucional=@Correo)
END
GO

--EXEC SP_ModificarPersona @CedulaBusqueda = '987654321', @Cedula='987654321', @Nombre1='Barry2', @Nombre2='', @Apellido1='Allen2', @Apellido2='Garcia2', @DireccionDetallada='Central City2';

IF OBJECT_ID('ValorRandom') IS NOT NULL
	DROP VIEW ValorRandom
GO
CREATE VIEW ValorRandom
AS
SELECT randomvalue = CRYPT_GEN_RANDOM(10)
GO

IF OBJECT_ID('SF_GenerarContrasena') IS NOT NULL
	DROP FUNCTION SF_GenerarContrasena
GO
CREATE FUNCTION SF_GenerarContrasena()
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @Resultado NVARCHAR(10);
	DECLARE @InfoBinario VARBINARY(10);
	DECLARE @DatosCaracteres NVARCHAR(10);

	SELECT @InfoBinario = randomvalue FROM ValorRandom;

	SET @DatosCaracteres = CAST ('' as xml).value('xs:base64Binary(sql:variable("@InfoBinario"))', 'varchar (max)');

	SET @Resultado = @DatosCaracteres;

	RETURN @Resultado;

END
GO

IF OBJECT_ID('SP_AgregarPersonaUsuario') IS NOT NULL
	DROP PROCEDURE SP_AgregarPersonaUsuario
GO
CREATE PROCEDURE SP_AgregarPersonaUsuario
	@Correo			NVARCHAR(50),
	@Contrasenna	NVARCHAR(50),
	@Cedula			CHAR(9),
	@Nombre1		NVARCHAR(50),
	@Nombre2		NVARCHAR(50),
	@Apellido1		NVARCHAR(50),
	@Apellido2		NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Id UNIQUEIDENTIFIER=NEWID()

	INSERT INTO Persona
	VALUES (@Cedula, @Nombre1, @Nombre2, @Apellido1, @Apellido2)
	SET @Contrasenna = (SELECT dbo.SF_GenerarContrasena());
	INSERT INTO Usuario
	VALUES (@Correo, HASHBYTES('SHA2_512', @Contrasenna+CAST(@Id AS NVARCHAR(36))), 1, @Cedula, @Id, 0)
END
GO




IF OBJECT_ID('ObtenerPerfilUsuario') IS NOT NULL
	DROP PROCEDURE ObtenerPerfilUsuario
GO
CREATE PROCEDURE ObtenerPerfilUsuario @correo nvarchar(100)
as 
	SELECT DISTINCT NombrePerfil
	FROM Tiene_Usuario_Perfil_Enfasis
	WHERE CorreoInstitucional = @correo;
go

IF OBJECT_ID('ObtenerPerfilPorDefecto') IS NOT NULL
	DROP PROCEDURE ObtenerPerfilPorDefecto
GO
CREATE PROCEDURE ObtenerPerfilPorDefecto @correo nvarchar(100)
as 
	SELECT TOP 1 NombrePerfil 
	FROM Tiene_Usuario_Perfil_Enfasis
	WHERE CorreoInstitucional = @correo;
go

--JJAPH
IF OBJECT_ID('MostrarEstudiantes', 'P') IS NOT NULL 
	DROP PROC MostrarEstudiantes

IF OBJECT_ID('NombrePersona', 'P') IS NOT NULL 
	DROP PROC NombrePersona

IF OBJECT_ID('DatosEstudiante', 'P') IS NOT NULL 
	DROP PROC DatosEstudiante

GO
--Pantalla 1, Home
CREATE PROCEDURE MostrarEstudiantes
AS 
	SELECT Nombre1, Apellido1, Apellido2, Carne
	FROM Persona P JOIN Estudiante E ON P.Cedula = E.CedulaEstudiante;
GO

--Pantalla 2 solo el nombre para bienvenida
GO
CREATE PROCEDURE NombrePersona 
@Cedula VARCHAR(9)
AS
	SELECT Nombre1
	FROM Persona
	WHERE Cedula = @Cedula;

--Pantalla 3, informacion de un estudiante
GO
CREATE PROCEDURE DatosEstudiante
@Cedula VARCHAR(9)
AS
	SELECT CONCAT(Nombre1, ' ' ,Apellido1, ' ', Apellido2) as 'Nombre Completo', Carne, Cedula
	FROM Persona P JOIN Estudiante E ON P.Cedula = E.CedulaEstudiante
	WHERE Cedula = @Cedula;
GO

GO
IF OBJECT_ID('ObtenerPerfilesUsuario') IS NOT NULL
	DROP PROCEDURE ObtenerPerfilesUsuario
GO
CREATE PROC ObtenerPerfilesUsuario
	@Correo	NVARCHAR(50)
AS
	SELECT SiglaCarrera, NumeroEnfasis
	FROM Tiene_Usuario_Perfil_Enfasis
	WHERE CorreoInstitucional= @Correo
GO

--Inserciones

INSERT INTO Persona
VALUES	('116720500', 'Jose Andrés', NULL,'Mejías', 'Rojas'),
		('115003456', 'Daniel', NULL, 'Escalante', 'Perez'),
		('117720910', 'Jose Andrés', NULL, 'Mejías', 'Rojas'),
		('236724507', 'Jose Andrés', NULL, 'Mejías', 'Rojas'),
		--Agregado de datos para visualizacion a cargo de CX Solutions
		('100000001', 'CX', NULL, 'Solutions', 'S.A.'),
		('100000002', 'Marta', NULL, 'Rojas', 'Sanches'),--Profesora
		--Estudiantes
		('100000003', 'Juan', NULL, 'Briceño', 'Lupon'),
		('100000005', 'Pepito', NULL, 'Fonsi', 'Monge'),
		('100000004', 'Maria', NULL, 'Fallas', 'Merdi'),
		('117720912', 'Jorge', NULL, 'Solano', 'Carrillo'),
		('236724501', 'Carolina', NULL, 'Gutierrez', 'Lozano'),
		('123456789', 'Ortencia', NULL, 'Cañas', 'Griezman');

INSERT INTO Estudiante VALUES 
 ('116720500', 'B11111')
,('115003456', 'B22222')
,('117720910', 'B33333') 
,('236724501', 'B44444');

--INSERT INTO Responde (ItemId,TituloSeccion, FechaRespuesta, CodigoFormularioResp, CedulaPersona, CedulaProfesor, AnnoGrupoResp, SemestreGrupoResp, NumeroGrupoResp, SiglaGrupoResp)
--VALUES (3,'Titulo Seccion 1','8-12-1994','CodF01','123456789','987654321',54,01,21,'SG1234'),
--	   (1,'Titulo Seccion 2','8-12-1998','CodF02','123789659','987678951',59,01,20,'SG2345'),
--	   (2,'Titulo Seccion 3','8-12-1997','CodF03','135786789','982455321',51,01,15,'SG3456');

EXEC SP_AgregarUsuario @Correo='jose.mejiasrojas@ucr.ac.cr', @Contrasenna='123456', @Cedula='116720500'
EXEC SP_AgregarUsuario @Correo='daniel.escalanteperez@ucr.ac.cr', @Contrasenna='Danielito', @Cedula='115003456'
EXEC SP_AgregarUsuario @Correo='rodrigo.cascantejuarez@ucr.ac.cr', @Contrasenna='contrasena', @Cedula='117720910'
EXEC SP_AgregarUsuario @Correo='luis.quesadaborbon@ucr.ac.cr', @Contrasenna='LigaDeportivaAlajuelense', @Cedula='236724501'
EXEC SP_AgregarUsuario @Correo='admin@ucr.ac.cr', @Contrasenna='adminUCR2019', @Cedula='123456789'
EXEC SP_AgregarUsuario @Correo= 'cx@cx.solutions', @Contrasenna= 'CXSolutions', @Cedula= '100000001'



--Script JJAPH

--Unidad academica
INSERT INTO Unidad_Academica (Codigo, Nombre)
VALUES ('UC-023874', 'ECCI')

INSERT INTO Unidad_Academica (Codigo, Nombre)
VALUES ('UC-485648', 'Derecho')

INSERT Curso
VALUES  ('CI1213', 'Ingenieria de Software', 1, 'UC-023874'),
('CI1223', 'Bases de Datos', 1, 'UC-023874'),
 ('CI1211', 'Proyecto Integrador', 1, 'UC-023874')

--Escuela
--INSERT INTO Escuela(CodigoUnidadAcademica,CodigoFacultad)
--VALUES ('UC-023874','UC-023874')

--INSERT INTO Escuela(CodigoUnidadAcademica,CodigoFacultad)
--VALUES ('UC-485648','UC-485648')

--Facultad
INSERT INTO Facultad (CodigoUnidadAcademica)
VALUES ('UC-023874')

INSERT INTO Facultad (CodigoUnidadAcademica)
VALUES ('UC-485648')

--Carrera
INSERT INTO Carrera(Sigla, Nombre, CodigoUnidadAcademica)
VALUES ('SC-01234', 'Ciencias de la Computación e Informática','UC-023874')

INSERT INTO Enfasis
VALUES	(0, 'SC-01234'),
		(1, 'SC-01234')

INSERT INTO Carrera(Sigla, Nombre, CodigoUnidadAcademica)
VALUES ('SC-01235', 'Computación con varios Énfasis','UC-023874')

INSERT INTO Carrera(Sigla, Nombre, CodigoUnidadAcademica)
VALUES ('SC-89457', 'Derecho','UC-485648')

--Cursos
INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('CI1330', 'Ingenieria de software', 1,'UC-023874')

INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('CI1331', 'Bases de datos', 1,'UC-023874')

INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('CI1327', 'Programacion 1', 1,'UC-023874')

INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('CI1328', 'Programacion Paralela y concurrente', 1,'UC-023874')

INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('DE1001', 'INTRODUCCIÓN AL ESTUDIO DEL DERECHO I', 1,'UC-485648')

INSERT INTO Curso (Sigla, Nombre, Tipo,CodigoUnidad)
VALUES ('DE2001', 'PRINCIPIOS DEL DERECHO PRIVADO I', 1,'UC-485648')

----Grupos
insert into Ciclo_Lectivo (Anno, Semestre)
values (2018, 1), (2018, 2), (2019, 1);

insert into Grupo (SiglaCurso, Numero, AnnoGrupo, SemestreGrupo)
values 
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 1, 2018, 1),
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 2, 2018, 1),
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 1, 2018, 2),
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 2, 2018, 2),
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 1, 2019, 1),
	((select c.Sigla from Curso c where c.Sigla = 'CI1327'), 2, 2019, 1),
--INSERT INTO Grupo(SiglaCurso, Numero, AnnoGrupo, SemestreGrupo)
--VALUES ('CI1330', 2, 2018, 1)

	((select c.Sigla from Curso c where c.Sigla = 'CI1328'), 1, 2018, 2),
	((select c.Sigla from Curso c where c.Sigla = 'CI1328'), 2, 2018, 2),
	((select c.Sigla from Curso c where c.Sigla = 'CI1328'), 1, 2019, 1),

	((select c.Sigla from Curso c where c.Sigla = 'CI1330'), 1, 2019, 1),

	((select c.Sigla from Curso c where c.Sigla = 'CI1331'), 1, 2019, 1),

	((select c.Sigla from Curso c where c.Sigla = 'DE1001'), 1, 2018, 1),
	((select c.Sigla from Curso c where c.Sigla = 'DE1001'), 1, 2019, 1),

	((select c.Sigla from Curso c where c.Sigla = 'DE2001'), 1, 2018, 2);

----Enfasis
INSERT INTO Enfasis(Numero, SiglaCarrera)
VALUES (100, 'SC-01234'), 
	   (101, 'SC-01234'),
	   (12, 'SC-89457');

----Curso-Enfasis
INSERT INTO Se_Encuentra_Curso_Enfasis(SiglaCurso, CodigoEnfasis, SiglaCarrera)
VALUES ('CI1330', 100, 'SC-01234'), 
	   ('CI1331', 100, 'SC-01234'),
	   ('CI1327', 101, 'SC-01234'),
	   ('CI1328', 101, 'SC-01234'),
	   ('DE1001', 12, 'SC-89457'),
	   ('DE2001', 12, 'SC-89457');

--DROP PROCEDURE CursosSegunCarrera
--Obtiene la lista de cursos que pertenecen a cierta carrera

IF OBJECT_ID('CursosSegunCarrera') IS NOT NULL
	DROP PROCEDURE CursosSegunCarrera
GO
CREATE PROCEDURE CursosSegunCarrera
@siglaCarrera NVARCHAR(10)
AS
BEGIN
SELECT C.Nombre, C.Sigla, C.Tipo, C.CodigoUnidad
FROM Curso C
WHERE C.Sigla IN (SELECT S.SiglaCurso
				FROM Se_Encuentra_Curso_Enfasis S
				WHERE S.SiglaCarrera = @siglaCarrera)
END
GO

--Obtiene la lista de cursos que pertenecen a cierto semestre
IF OBJECT_ID('CursosSegunSemestre') IS NOT NULL
	DROP PROCEDURE CursosSegunSemestre
GO
CREATE PROCEDURE CursosSegunSemestre
@semestre TINYINT
AS
BEGIN
SELECT C.Nombre, C.Sigla, C.Tipo, C.CodigoUnidad
FROM Curso C
WHERE C.Sigla IN (SELECT G.SiglaCurso
				FROM Grupo G
				WHERE G.SemestreGrupo = @semestre)
END
GO

--Obtiene la lista de cursos que pertenecen a cierto año
IF OBJECT_ID('CursosSegunAnno') IS NOT NULL
	DROP PROCEDURE CursosSegunAnno
GO
CREATE PROCEDURE CursosSegunAnno
@anno SMALLINT
AS
BEGIN
SELECT C.Nombre, C.Sigla, C.Tipo, C.CodigoUnidad
FROM Curso C
WHERE C.Sigla IN (SELECT G.SiglaCurso
				FROM Grupo G
				WHERE G.AnnoGrupo = @anno)
END
GO


--Script C.X. Solutions

--Ciclo Lectivo
INSERT INTO Ciclo_Lectivo (Anno, Semestre)
VALUES  (2017, 2);

--Grupo
INSERT INTO Grupo(SiglaCurso, Numero, AnnoGrupo, SemestreGrupo)
VALUES ('CI1330', 1, 2017, 2);

--Categoria
INSERT INTO Categoria
VALUES  ('Reglamento'),
		('Curso'),
		('Opinion');

--Item
INSERT INTO Item(ItemId, TextoPregunta, TieneObservacion, TipoPregunta, NombreCategoria)
VALUES  ('PRE303', '¿El profesor repuso clases cuando fue necesario?', 1, 3, 'Reglamento'),
		('PRE404', '¿El profesor entrego la carta del estudiante en las fechas indicadas por el reglamento?', 1, 3, 'Reglamento'),
		('PRE101', '¿Que opina del curso?', 0, 1, 'Opinion'),
		('PRE202', '¿Que opina del profesor?', 0, 1, 'Opinion'),
		---Se agregó
		('PRE505', 'Año de carrera que cursa', 0, 4, 'Opinion'),
		('PRE606', 'Condicion laboral', 0, 4, 'Opinion'),
		--Escalar y Escalar Estrella
		('PRE707', '¿Se prepara adecuadamente para las evaluaciones?', 1, 5, 'Opinion'),
		('PRE808', '¿Propone actividades que involucren investigacion?', 1, 6, 'Reglamento');

--Item-Texto Libre
INSERT INTO Texto_Libre (ItemId)
VALUES  ('PRE101'),
		('PRE202');

--Item-Si/no
INSERT INTO Seleccion_Unica (ItemId, IsaLikeDislike)
VALUES  ('PRE303', 1),
		('PRE404', 1);

--Seccion
INSERT INTO Seccion (Titulo, Descripcion)
VALUES  ('Evaluación de aspectos reglamentarios del profesor', 'Conteste a las preguntas relacionadas a aspectos reglamentarios que el profesor debe cumplir.'),
		('Opinion general del curso', 'Describa las opiniones que le han generado el profesor con respecto al curso tratado.'),
		--Nueva Seccion
		('Información del o la estudiante', 'Datos del estudiante'),
		('Tematicas transversales de la Universidad de Costa Rica', ' '),
		('Evaluacion de la participacion estudiantil', 'Autoevaluacion estudiantil');

--Formulario
INSERT INTO Formulario (CodigoFormulario, Nombre)
VALUES  ('131313', 'Evaluación de Profesores');

--Profesor
INSERT INTO Profesor (CedulaProfesor)
VALUES  ('100000002');

--Formulario Respuesta
INSERT INTO Formulario_Respuesta (Fecha, CodigoFormulario, CedulaPersona, CedulaProfesor, AnnoGrupo, SemestreGrupo, NumeroGrupo, SiglaGrupo, Completado)
VALUES  ('2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', 1),
		('2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', 1),
		('2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', 1),
		('2017-3-20', '131313', '117720912', '100000002', 2017, 2, 1, 'CI1330', 1),
		('2017-3-20', '131313', '236724501', '100000002', 2017, 2, 1, 'CI1330', 1),
		('2017-3-21', '131313', '123456789', '100000002', 2017, 2, 1, 'CI1330', 1);

 --Conformado_Item_Sec_Form
INSERT INTO Conformado_Item_Sec_Form (ItemId, CodigoFormulario, TituloSeccion, NombreFormulario)
VALUES	('PRE101', '131313', 'Opinion general del curso', 'Evaluación de Profesores'),
		('PRE202', '131313', 'Opinion general del curso', 'Evaluación de Profesores'),
		('PRE303', '131313', 'Evaluación de aspectos reglamentarios del profesor', 'Evaluación de Profesores'),	
		('PRE404', '131313', 'Evaluación de aspectos reglamentarios del profesor', 'Evaluación de Profesores'),
		('PRE505', '131313', 'Información del o la estudiante', 'Evaluación de Profesores'),
		('PRE606', '131313', 'Información del o la estudiante', 'Evaluación de Profesores'),
		('PRE707', '131313', 'Evaluacion de la participacion estudiantil', 'Evaluación de Profesores'),
		('PRE808', '131313', 'Tematicas transversales de la Universidad de Costa Rica', 'Evaluación de Profesores');

--Responde
INSERT INTO Responde (ItemId, TituloSeccion, FechaRespuesta, CodigoFormularioResp, CedulaPersona, CedulaProfesor, AnnoGrupoResp, SemestreGrupoResp, NumeroGrupoResp, SiglaGrupoResp, Respuesta, Observacion)
VALUES  ('PRE303', 'Evaluación de aspectos reglamentarios del profesor', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', '3', 'Nunca tuvimos que reponer clases'),
		('PRE404', 'Evaluación de aspectos reglamentarios del profesor', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', '2', 'La profesora olvido enviar la carta del estudiante pero si la revisamos en la primera semana de clases'),
		('PRE101', 'Opinion general del curso', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', '', 'La materia estuvo muy interesante y espero poder aplicarla en el futuro en el trabajo'),
		('PRE202', 'Opinion general del curso', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', '', 'La profesora tardo mucho para devolver las evaluaciones'),
		--Segunda evaluacion
		('PRE303', 'Evaluación de aspectos reglamentarios del profesor', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', '2', 'No fue necesario reponer clases'),
		('PRE404', 'Evaluación de aspectos reglamentarios del profesor', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', '1', 'Revisamos la carta del estudiante en la primera semana'),
		('PRE101', 'Opinion general del curso', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', '', 'No estoy seguro de si en el ambiente laboral me servira la materia'),
		('PRE202', 'Opinion general del curso', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', '', 'La profesora logro que las clases fueran muy entretenidas y dinámicas'),
		--Tercera evaluacion
		('PRE303', 'Evaluación de aspectos reglamentarios del profesor', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', '1', 'Me repuso una clase a la que falte'),
		('PRE404', 'Evaluación de aspectos reglamentarios del profesor', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', '1', 'Sí se reviso'),
		('PRE101', 'Opinion general del curso', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', '', 'Entretenido'),
		('PRE202', 'Opinion general del curso', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', '', 'Muy buena profesora'),

		--Agregado
		--Cuarta Multiple
		('PRE505', 'Información del o la estudiante', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', 'Primero', ''),
		('PRE606', 'Información del o la estudiante', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', 'No Trabajo', ''),
		('PRE505', 'Información del o la estudiante', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', 'Segundo', ''),
		('PRE505', 'Información del o la estudiante', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', 'Tercero', ''),
		('PRE606', 'Información del o la estudiante', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', 'Trabajo mas de 20 horas semanales', ''),
		('PRE606', 'Información del o la estudiante', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', 'Trabajo menos de 20 horas semanales', ''),
		--Escalar 5 y 10
		('PRE707', 'Evaluacion de la participacion estudiantil', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', 'Demasiado', 'Soy un sapazo'),
		('PRE707', 'Evaluacion de la participacion estudiantil', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', 'Poco', 'Me da pereza estudiar'),
		('PRE707', 'Evaluacion de la participacion estudiantil', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', 'A veces', 'Siempre le pongo'),
		('PRE707', 'Evaluacion de la participacion estudiantil', '2017-3-20', '131313', '117720912', '100000002', 2017, 2, 1, 'CI1330', 'Poco', 'Sí se reviso'),
		--1 a 10
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-4-18', '131313', '100000005', '100000002', 2017, 2, 1, 'CI1330', '8', 'Me encanta la materia'),
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-3-20', '131313', '117720912', '100000002', 2017, 2, 1, 'CI1330', '4', 'Mucho que investigar'),
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-3-6', '131313', '100000004', '100000002', 2017, 2, 1, 'CI1330', '3', 'Soy muy vago'),
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-4-5', '131313', '100000003', '100000002', 2017, 2, 1, 'CI1330', '1', 'Demasiado trabajo'),
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-3-20', '131313', '236724501', '100000002', 2017, 2, 1, 'CI1330', '7', 'Me encanta la materia'),
		('PRE808', 'Tematicas transversales de la Universidad de Costa Rica', '2017-3-21', '131313', '123456789', '100000002', 2017, 2, 1, 'CI1330', '5', 'Mucho que investigar');

GO
IF OBJECT_ID('SP_ContarRespuestasPorGrupo') IS NOT NULL
	DROP PROCEDURE SP_ContarRespuestasPorGrupo

--REQ: La Base de datos creada.
--EFE: Retorna la cantidad de respuestas por pregunta de un grupo especifico.
--MOD:--
GO
CREATE PROCEDURE SP_ContarRespuestasPorGrupo
	@codigoFormulario	CHAR(6),
	@cedulaProfesor		CHAR(9),
	@annoGrupo			SMALLINT,
	@semestreGrupo		TINYINT,
	@numeroGrupo		TINYINT,
	@siglaCurso			CHAR(6),
	@itemId				NVARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
	SELECT e.Respuesta, COUNT(e.Respuesta) AS cntResp
	FROM Responde as e
	WHERE e.CodigoFormularioResp= @codigoFormulario AND e.CedulaProfesor= @cedulaProfesor AND e.AnnoGrupoResp= @annoGrupo AND e.SemestreGrupoResp= @semestreGrupo AND e.NumeroGrupoResp= @numeroGrupo AND e.SiglaGrupoResp= @siglaCurso AND e.ItemId= @itemId
	GROUP BY e.CodigoFormularioResp, e.CedulaProfesor, e.AnnoGrupoResp, e.SemestreGrupoResp, e.NumeroGrupoResp, e.SiglaGrupoResp, e.ItemId, e.Respuesta
END
GO

GO
IF OBJECT_ID('SP_DevolverObservacionesPorGrupo') IS NOT NULL
	DROP PROCEDURE SP_DevolverObservacionesPorGrupo

--REQ: La base de datos creada.
--EFE: Retorna las observaciones por pregunta de un grupo especifico.
--MOD:--
GO
CREATE PROCEDURE SP_DevolverObservacionesPorGrupo
	@codigoFormulario CHAR(6),
	@cedulaProfesor CHAR(9),
	@annoGrupo SMALLINT,
	@semestreGrupo TINYINT,
	@numeroGrupo TINYINT,
	@siglaCurso CHAR(6),
	@itemId NVARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
	SELECT e.Observacion
	FROM Responde as e
	WHERE e.CodigoFormularioResp= @codigoFormulario AND e.CedulaProfesor= @cedulaProfesor AND e.AnnoGrupoResp= @annoGrupo AND e.SemestreGrupoResp= @semestreGrupo AND e.NumeroGrupoResp= @numeroGrupo AND e.SiglaGrupoResp= @siglaCurso AND e.ItemId= @itemId
END
GO


--Permisos
INSERT INTO Permiso
VALUES	(1, 'Hacer todo'),
		(2, 'Asignar formulario'),
		(3, 'Calificar cursos'),
		(4, 'Ver cursos'),
		(202, 'VerInformacionPersonas'),
		(203, 'InsertarUsuario'),
		(204, 'AsignarFormulario'),
		(205, 'VisualizarResultadosDeEvaluaciones'),
		(206, 'VerSecciones'),
		(207, 'VerItems'),
		(208, 'InsertarFormulario'),
		(209, 'Eliminar perfiles');

INSERT INTO Perfil
VALUES	('Estudiante', 'Calificar y ver evaluaciones.'),
		('Administrador', 'Puede hacer cualquier cosa como asignar permisos.'),
		('Profesor', 'Ver sus evaluaciones.')


INSERT INTO Tiene_Usuario_Perfil_Enfasis
VALUES	('jose.mejiasrojas@ucr.ac.cr', 0, 'SC-01234', 'Estudiante'),
		('admin@ucr.ac.cr', 0, 'SC-01234', 'Administrador'),
		('jose.mejiasrojas@ucr.ac.cr', 0, 'SC-01234', 'Profesor'),
		('jose.mejiasrojas@ucr.ac.cr', 0, 'SC-01234', 'Administrador')


INSERT INTO Posee_Enfasis_Perfil_Permiso
VALUES	(0, 'SC-01234', 'Estudiante', 3),
		(0, 'SC-01234', 'Administrador', 1),
		(0, 'SC-01234', 'Administrador', 2),
		(0, 'SC-01234', 'Profesor', 2),
		(0,'SC-01234', 'Administrador', 202),
		(0,'SC-01234', 'Administrador', 203),
		(0,'SC-01234', 'Administrador', 204),
		(0,'SC-01234', 'Administrador', 205),
		(0,'SC-01234', 'Administrador', 206),
		(0,'SC-01234', 'Administrador', 207),
		(0,'SC-01234', 'Profesor', 204),
		(0,'SC-01234', 'Profesor', 205),
		(0,'SC-01234', 'Estudiante', 205),
		(0,'SC-01234', 'Administrador', 208),
		(0,'SC-01234', 'Profesor', 208),
		(0, 'SC-01234', 'Administrador', 209)


		
--Función:
--Retorna Unique Identifier [Ver SP_agregarPersonaUsuario]
IF OBJECT_ID('SP_GenerarContrasena') IS NOT NULL
	DROP PROCEDURE SP_GenerarContrasena
GO
CREATE PROCEDURE SP_GenerarContrasena
@resultado	NVARCHAR(10) OUTPUT 
AS
BEGIN
	DECLARE @contrasenaRandom NVARCHAR(10);
	DECLARE @infoBinario VARBINARY(10);
	DECLARE @datosCaracteres NVARCHAR(10);

	SELECT @infoBinario = randomvalue FROM ValorRandom;

	SET @datosCaracteres = CAST ('' as xml).value('xs:base64Binary(sql:variable("@InfoBinario"))', 'varchar (max)');

	SET @resultado = @datosCaracteres;

END
GO

--Genera un Id único
IF OBJECT_ID('SP_GenerarIdUnico') IS NOT NULL
	DROP PROCEDURE SP_GenerarIdUnico
GO
CREATE PROCEDURE SP_GenerarIdUnico
@id	UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
	SET @id = NEWID()
END
GO

--Devuelve un GUID generado por la base
IF OBJECT_ID('SP_GenerarContrasenaHash') IS NOT NULL
	DROP PROCEDURE SP_GenerarContrasenaHash
GO
CREATE PROCEDURE SP_GenerarContrasenaHash
@id	NVARCHAR(50),
@contrasena	NVARCHAR(10),
@contrasenaHash VARBINARY(50) OUTPUT
AS
BEGIN
	SET @contrasenaHash = HASHBYTES('SHA2_512', @contrasena+CAST(@id AS NVARCHAR(36)))
END
GO

IF OBJECT_ID('TR_InsertaUsuario') IS NOT NULL
	DROP TRIGGER TR_InsertaUsuario
GO
CREATE TRIGGER TR_InsertaUsuario
ON Usuario INSTEAD OF INSERT
AS
BEGIN
	DECLARE @correoInstitucional NVARCHAR(51)
	DECLARE @cedula CHAR(10)

	SET @correoInstitucional	= (SELECT CorreoInstitucional FROM inserted)
	SET @cedula					= (SELECT Cedula FROM inserted)

	IF((@correoInstitucional LIKE '%@ucr.ac.cr') AND (@correoInstitucional NOT LIKE '') AND (@cedula NOT LIKE '') AND (LEN(@correoInstitucional) <= 50) AND  (LEN(@cedula) = 9))
	BEGIN
		INSERT INTO Usuario (Cedula, CorreoInstitucional)
		VALUES (@cedula, @correoInstitucional)
	END
	ELSE
	BEGIN
		RAISERROR('Hay campos no pueden estar vacíos o exceder el tamaño adecuado', 16, 1)
		RETURN
	END
END;

IF OBJECT_ID('TR_InsertaPersona') IS NOT NULL
	DROP TRIGGER TR_InsertaPersona
GO
CREATE TRIGGER TR_InsertaPersona
ON Persona INSTEAD OF INSERT
AS
BEGIN
	DECLARE @cedula CHAR(10)
	DECLARE @nombre1 NVARCHAR(51)
	DECLARE @nombre2 NVARCHAR(51)
	DECLARE @apellido1 NVARCHAR(51)
	DECLARE @apellido2 NVARCHAR(51)
	--DECLARE @correoInstitucional NVARCHAR(51)

	--SET @correoInstitucional	= (SELECT CorreoInstitucional FROM inserted)
	
	SET @cedula					= (SELECT Cedula FROM inserted)
	SET @nombre1				= (SELECT Nombre1 FROM inserted)
	SET @nombre2				= (SELECT Nombre2 FROM inserted)
	SET @apellido1				= (SELECT Apellido1 FROM inserted)
	SET @apellido2				= (SELECT Apellido2 FROM inserted)

	IF((@cedula NOT LIKE '') AND  (LEN(@cedula) = 9) AND (@nombre1 NOT LIKE '') AND (LEN(@nombre1) <= 50) 
	AND  (LEN(@nombre2) <= 50)  AND (@apellido1 NOT LIKE '') AND (LEN(@apellido1) <= 50)  
	AND (@apellido2 NOT LIKE '') AND (LEN(@apellido2) <= 50))
	BEGIN
		INSERT INTO PerPersona(Cedula, nombre1, nombre2, apellido1, apellido2)
		VALUES (@cedula, @nombre1, @nombre2, @apellido1, @apellido2)
	END
	ELSE
	BEGIN
		RAISERROR('Hay campos no pueden estar vacíos o exceder el tamaño adecuado', 16, 1)
		RETURN
	END
END;

--select de prueba para la cnt de respuestas
--SELECT e.Respuesta, COUNT(e.Respuesta) as cantidadRespuestas
--FROM Responde as e
--WHERE e.CodigoFormularioResp= '131313' AND e.CedulaProfesor= '100000002' AND e.AnnoGrupoResp= 2017 AND e.SemestreGrupoResp= 2 AND e.NumeroGrupoResp= 1 AND e.SiglaGrupoResp= 'CI1330' AND e.ItemId= 2
--GROUP BY e.CodigoFormularioResp, e.CedulaProfesor, e.AnnoGrupoResp, e.SemestreGrupoResp, e.NumeroGrupoResp, e.SiglaGrupoResp, e.ItemId, e.Respuesta

--select de prueba para obtener las observaciones
--SELECT e.Observacion
--FROM Responde as e
--WHERE e.CodigoFormularioResp= '131313' AND e.CedulaProfesor= '100000002' AND e.AnnoGrupoResp= 2017 AND e.SemestreGrupoResp= 2 AND e.NumeroGrupoResp= 1 AND e.SiglaGrupoResp= 'CI1330' AND e.ItemId= 1
--GROUP BY e.CodigoFormularioResp, e.CedulaProfesor, e.AnnoGrupoResp, e.SemestreGrupoResp, e.NumeroGrupoResp, e.SiglaGrupoResp, e.ItemId, e.Observacion--, e.Respuesta

--Fin Por el momento de script CX Solutions