CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

DELIMITER //
CREATE TRIGGER insere_auditoria_clienteAFTER INSERT ON ClientesFOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Novo cliente: ', NEW.nome, ' em ', NOW()));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER tentativa_exclusaoBEFORE DELETE ON ClientesFOR EACH ROW BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Tentativa exclusão cliente: ', OLD.nome, ' em ', NOW()));
END;
//
DELIMITER ;
