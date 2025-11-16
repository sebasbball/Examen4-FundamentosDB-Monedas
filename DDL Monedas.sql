CREATE DATABASE Monedas
GO

USE Monedas
GO

/* Crear tabla MONEDA */
CREATE TABLE Moneda( 
	Id int IDENTITY NOT NULL, 
	CONSTRAINT pkMoneda_Id PRIMARY KEY (Id),
	Moneda VARCHAR(100) NOT NULL,
	Sigla VARCHAR(5) NOT NULL,
	Simbolo VARCHAR(5) NULL,
	Emisor VARCHAR(100) NULL,
	Imagen VARBINARY(MAX) NULL
	);

/* Crear indice para MONEDA
	ordenado por MONEDA */
CREATE UNIQUE INDEX ixMoneda
	ON Moneda(Moneda);

/* Crear tabla CAMBIOMONEDA */
CREATE TABLE CambioMoneda( 
	Id int IDENTITY NOT NULL,
	CONSTRAINT pkCambioMoneda_Id PRIMARY KEY (Id),
	IdMoneda int NOT NULL,
	CONSTRAINT fkCambioMoneda_IdMoneda FOREIGN KEY (IdMoneda)
		REFERENCES Moneda(Id),
	Fecha datetime NOT NULL,
	Cambio float NOT NULL
);

/* Crear indice para CAMBIOMONEDA
	ordenado por MONEDA, FECHA */
CREATE UNIQUE INDEX ixCambioMoneda
	ON CambioMoneda(IdMoneda, Fecha);

/* Crear tabla PAIS */
CREATE TABLE Pais(
	Id int IDENTITY NOT NULL,
	CONSTRAINT pkPais_Id PRIMARY KEY (Id),
	Pais varchar(50) not null,
	CodigoAlfa2 varchar(5) not null,
	CodigoAlfa3 varchar(5) not null, 
	IdMoneda int NOT NULL,
	CONSTRAINT fkPais_IdMoneda FOREIGN KEY (IdMoneda)
		REFERENCES Moneda(Id),
	Mapa VARBINARY(MAX) NULL,
	Bandera VARBINARY(MAX) NULL
	);

/* Crear indice para PAIS
	ordenado por PAIS */
CREATE UNIQUE INDEX ixPais
	ON Pais(Pais);
    
