﻿CREATE TABLE [dbo].[SeleccionUnica]
(
	[ItemID] INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Isa_LikeDislike bit

	CONSTRAINT FKItem FOREIGN KEY (ItemID) REFERENCES Item(ItemID)
)
