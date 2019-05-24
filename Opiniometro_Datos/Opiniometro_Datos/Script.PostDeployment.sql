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
	VALUES (@Correo, HASHBYTES('SHA2_512', @Contrasenna+CAST(@Id AS NVARCHAR(36))), 1, @Cedula, @Id)
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
	@Correo				NVARCHAR(50),
	@Contrasenna_Nueva	NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CorreoBuscar NVARCHAR(50)
	
	-- Buscar que el correo y la contrasenna sean correctos con lo que hay en la tabla Usuario.
	SET @CorreoBuscar =	(SELECT CorreoInstitucional 
						FROM Usuario
						WHERE CorreoInstitucional=@Correo)

	IF(@CorreoBuscar IS NOT NULL)	-- Si existe el correo
		UPDATE Usuario
		SET Contrasena = HASHBYTES('SHA2_512', @Contrasenna_Nueva+CAST(Id AS NVARCHAR(36)))
		
END
GO

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
	@Cedula			CHAR(9),
	@Nombre			NVARCHAR(50),
	@Apellido1		NVARCHAR(50),
	@Apellido2		NVARCHAR(50),
	@Direccion		NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Id UNIQUEIDENTIFIER=NEWID()
	DECLARE @Contrasenna NVARCHAR(10)

	INSERT INTO Persona
	VALUES (@Cedula, @Nombre, @Apellido1, @Apellido2, @Direccion)
	SET @Contrasenna = (SELECT dbo.SF_GenerarContrasena());
	INSERT INTO Usuario
	VALUES (@Correo, HASHBYTES('SHA2_512', @Contrasenna+CAST(@Id AS NVARCHAR(36))), 1, @Cedula, @Id)
END
GO

EXEC SP_AgregarPersonaUsuario @Correo='barryallen@correo.com', @Contrasenna='12345678', @Cedula='123456789', @Nombre='Barry', @Apellido1='Allen', @Apellido2='Garcia', @Direccion='Central City';



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
	SELECT Nombre, Apellido1, Apellido2, Carne
	FROM Persona P JOIN Estudiante E ON P.Cedula = E.CedulaEstudiante;
GO

--Pantalla 2 solo el nombre para bienvenida
GO
CREATE PROCEDURE NombrePersona 
@Cedula VARCHAR(9)
AS
	SELECT Nombre
	FROM Persona
	WHERE Cedula = @Cedula;

--Pantalla 3, informacion de un estudiante
GO
CREATE PROCEDURE DatosEstudiante
@Cedula VARCHAR(9)
AS
	SELECT CONCAT(Nombre, ' ' ,Apellido1, ' ', Apellido2) as 'Nombre Completo', Carne, Cedula
	FROM Persona P JOIN Estudiante E ON P.Cedula = E.CedulaEstudiante
	WHERE Cedula = @Cedula;
GO

--Inserciones

INSERT INTO Persona
VALUES	('116720500', 'Jose Andrés', 'Mejías', 'Rojas', 'Desamparados de Alajuela.'),
		('115003456', 'Daniel', 'Escalante', 'Perez', 'Desamparados de San José.'),
		('117720910', 'Jorge', 'Solano', 'Carrillo', 'La Fortuna de San Carlos.'),
		('236724501', 'Carolina', 'Gutierrez', 'Lozano', 'Sarchí, Alajuela.'),
		('123456789', 'Ortencia', 'Cañas', 'Griezman', 'San Pedro de Montes de Oca');

INSERT INTO Estudiante VALUES 
 ('116720500', 'B11111')
,('115003456', 'B22222')
,('117720910', 'B33333') 
,('236724501', 'B44444');

EXEC SP_AgregarUsuario @Correo='jose.mejiasrojas@ucr.ac.cr', @Contrasenna='123456', @Cedula='116720500'
EXEC SP_AgregarUsuario @Correo='daniel.escalanteperez@ucr.ac.cr', @Contrasenna='Danielito', @Cedula='115003456'
EXEC SP_AgregarUsuario @Correo='rodrigo.cascantejuarez@ucr.ac.cr', @Contrasenna='contrasena', @Cedula='117720910'
EXEC SP_AgregarUsuario @Correo='luis.quesadaborbon@ucr.ac.cr', @Contrasenna='LigaDeportivaAlajuelense', @Cedula='236724501'
EXEC SP_AgregarUsuario @Correo='admin@ucr.ac.cr', @Contrasenna='adminUCR2019', @Cedula='123456789'


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
--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1330', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1330', 2, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1331', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1331', 2, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1327', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1327', 2, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1328', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('CI1328', 2, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('DE1001', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('DE1001', 2, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('DE2001', 1, 2019, 1)

--INSERT INTO Grupo(Numero, SiglaCurso, Anno, Semestre)
--VALUES ('DE2001', 2, 2019, 1)

--JOFFI
MERGE INTO Preguntas AS Target
USING (VALUES
(1, 'Pregunta1', 'SiNo', 'Profesor'),
(2, 'Pregunta2', 'SeleccionUnica', 'Profesor'),
(3, 'Pregunta3', 'SeleccionMultiple', 'Curso')
)
AS Source ([Numero], Planteamiento, TipoPregunta, Categoria)
ON Target.Planteamiento = Source.Planteamiento
WHEN NOT MATCHED BY TARGET THEN
INSERT(Numero, Planteamiento, TipoPregunta, Categoria)
VALUES(Numero, Planteamiento, TipoPregunta, Categoria);
