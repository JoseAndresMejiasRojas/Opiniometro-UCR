﻿CREATE TABLE [dbo].[Formulario_Respuesta]
(
	[Fecha] DATE NOT NULL,
	[CodigoFormulario] CHAR(6) NOT NULL DEFAULT('000000'),
	[CedulaPersona] CHAR(9) NOT NULL,
	[CedulaProfesor] CHAR(9) NOT NULL,
	[AñoGrupo] SMALLINT NOT NULL,
	[SemestreGrupo] TINYINT NOT NULL,
	[NumeroGrupo] TINYINT NOT NULL,
	[SiglaGrupo] CHAR(6) NOT NULL,
	[Completado] BIT,
	CONSTRAINT [PK_Formulario_Respuesta] PRIMARY KEY([Fecha], [CodigoFormulario], [CedulaPersona], [CedulaProfesor], [AñoGrupo], [SemestreGrupo], [NumeroGrupo], [SiglaGrupo])
	--CONSTRAINT [FK_ForRes_For] FOREIGN KEY ([CodigoFormulario])
	--REFERENCES [Formulario] ([CodigoFormulario]) ON DELETE SET DEFAULT ON UPDATE CASCADE,
	--CONSTRAINT [FK_ForRes_Pro] FOREIGN KEY ([CedulaProfesor])
	--REFERENCES [Profesor] ([CedulaProfesor]) ON DELETE CASCADE ON UPDATE CASCADE
	--CONSTRAINT [FK_ForRes_Per] FOREIGN KEY ([CedulaPersona])
	--REFERENCES [Persona] ([Cedula]) ON DELETE CASCADE ON UPDATE CASCADE
	--CONSTRAINT [FK_ForRes_Gru] FOREIGN KEY ([AñoGrupo], [SemestreGrupo], [NumeroGrupo], [SiglaGrupo])
	--REFERENCES [Grupo] ([AñoGrupo], [SemestreGrupo], [Numero], [SiglaCurso]) ON DELETE NO ACTION ON UPDATE CASCADE
)